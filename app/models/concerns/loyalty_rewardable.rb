module LoyaltyRewardable
  extend ActiveSupport::Concern

  included do
    class << self
      def process_quarterly_reward
        find_each(batch_size: 100) do |user_loyalty|
          next unless receive_bonus_point_in_quarter?(user_loyalty.user)

          user_loyalty.current_point += 100
          user_loyalty.save!
        end
      end

      private

      def receive_bonus_point_in_quarter?(user)
        Transaction.total_fee_in_quarter(user, current_quarter) > 2000
      end

      def current_quarter
        1 + ((Time.now.month - 1) / 3).to_i
      end
    end

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
