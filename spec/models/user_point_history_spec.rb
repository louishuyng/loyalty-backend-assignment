require 'rails_helper'

RSpec.describe UserPointHistory do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:point) }
  end

  describe 'callback' do
    describe 'after_create' do
      context '#reward_in_one_calendar_month' do
        let(:user) { create(:user) }
        let(:reward) { Reward.find_by(name: 'free_coffee') }

        context 'when user does not accumulates 100 points in current month' do
          before do
            user.point_histories.create(point: 30)
            user.point_histories.create(point: 50)
            user.point_histories.create(point: 90, created_at: 1.month.from_now)
          end

          it 'user should not receive free coffee reward' do
            expect(user.user_rewards.count).to eq(0)
          end
        end

        context 'when user accumulates 100 points in current month' do
          let!(:reward_none_one_month_issue_tag) { create(:user_reward, reward:, user:) }

          subject do
            user.point_histories.create(point: 30)
            user.point_histories.create(point: 80)
            user.point_histories.create(point: 20, created_at: 1.month.from_now)
          end

          context 'and reward has already issued' do
            before do
              reward = user.user_rewards.create(reward:)
              reward.is_one_month_issue = true
              reward.save
            end

            it 'user should not receive more free coffee reward' do
              expect do
                subject
              end.not_to change(user, :user_rewards)
            end
          end

          context 'and reward did not issue' do
            it 'user should receive more free coffee reward' do
              expect do
                subject
              end.to change(user.user_rewards, :count).by(1)
            end

            it 'free coffee reward should be create with correct info' do
              subject

              expect(user.rewards.last).to eq(reward)
              expect(user.user_rewards.last.is_one_month_issue).to be_truthy
            end
          end
        end
      end
    end
  end
end
