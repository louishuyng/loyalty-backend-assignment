module PointRewardable
  extend ActiveSupport::Concern

  included do
    after_create :reward_in_one_calendar_month

    private

    def reward_in_one_calendar_month
      return if UserPointHistory.total_point_in_current_month(user) < 100

      reward = Reward.find_by!(name: 'free_coffee')

      user_rewards = user.user_rewards.this_month.where(reward:)

      return if user_rewards.any?(&:is_one_month_issue)

      issue_reward_in_month(reward)
    end

    def issue_reward_in_month(reward)
      reward = user.user_rewards.create!(reward:)
      reward.is_one_month_issue = true
      reward.save!
    end
  end
end
