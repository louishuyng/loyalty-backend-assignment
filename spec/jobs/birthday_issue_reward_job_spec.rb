require 'rails_helper'

RSpec.describe BirthdayIssueRewardJob do
  describe 'methods' do
    context '#perform' do
      ActiveJob::Base.queue_adapter = :test

      let(:user) { create(:user) }
      let!(:reward) { create(:reward, name: 'free_coffee') }

      it 'issue a reward for user' do
        expect do
          described_class.perform_now(user.id)
        end.to change(user.user_rewards, :count).by(1)
      end

      it 'issue a reward for user with a tag issue_birthday_reward' do
        described_class.perform_now(user.id)

        expect(user.user_rewards.last.is_birthday_reward).to be_truthy
      end

      it 'enqueued a job for the next birthday year' do
        expect do
          described_class.perform_now(user.id)
        end.to enqueue_job(BirthdayIssueRewardJob)\
          .at(user.birthday.at_beginning_of_month.next_year).with(user.id)
      end
    end
  end
end
