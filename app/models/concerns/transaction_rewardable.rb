module TransactionRewardable
  extend ActiveSupport::Concern

  included do
    after_create do
      issue_five_percentage_cash_rebate_reward unless \
        user.issued_five_percentage_cash_rebate
    end

    private

    def issue_five_percentage_cash_rebate_reward
      return if number_transactions_have_amount_gt_100 < 10

      reward = Reward.find_by!(name: '5_percentage_cash_rebate')
      user.user_rewards.create!(reward:)

      user.issued_five_percentage_cash_rebate = true
      user.save!
    end

    def number_transactions_have_amount_gt_100
      user.transactions.where(Transaction.arel_table[:fee].gt(100)).count
    end
  end
end
