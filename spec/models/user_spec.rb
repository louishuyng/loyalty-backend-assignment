require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:user_rewards).dependent(:destroy) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
    it { is_expected.to have_many(:point_histories).class_name('UserPointHistory').dependent(:destroy) }

    it { is_expected.to have_many(:rewards).through(:user_rewards) }

    it { is_expected.to have_one(:loyalty).class_name('UserLoyalty').inverse_of(:user).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_name) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe 'callback' do
    describe 'after_create' do
      let(:birthday) { Time.now }
      let(:user) { build(:user, birthday:) }

      subject { user.save }

      context '#create_loyalty' do
        it 'create loyalty after create user' do
          subject

          expect(user.loyalty).not_to be_nil
        end
      end

      context '#issue_birthday_reward_later' do
        ActiveJob::Base.queue_adapter = :test

        context 'when birthday is over in this year' do
          let(:birthday) { Time.now - 2.months }

          it 'enqueued a job in a next year' do
            expect do
              subject
            end.to enqueue_job(BirthdayIssueRewardJob)\
              .at(user.birthday.at_beginning_of_month.next_year).with(user.id)
          end
        end

        context 'when birthday is in currenth month' do
          it 'enqueued a job now' do
            expect do
              subject
            end.to enqueue_job(BirthdayIssueRewardJob).with(user.id)
          end
        end

        context 'when birthday is not coming in this year' do
          let(:birthday) { Time.now + 1.month }

          it 'enqueued a job in the beginning of next coming months' do
            expect do
              subject
            end.to enqueue_job(BirthdayIssueRewardJob)\
              .at(user.birthday.at_beginning_of_month).with(user.id)
          end
        end
      end
    end
  end
end
