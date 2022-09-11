module LoyaltyRewardable
  extend ActiveSupport::Concern

  included do
    private

    def issue_gold_reward
      return if user.issued_gold_reward

      reward = Reward.find_by(name: 'airport_lounge_access')

      user.user_rewards.create!(reward:, usage_amount: 4)

      user.issued_gold_reward = true
      user.save
    end
  end
end
