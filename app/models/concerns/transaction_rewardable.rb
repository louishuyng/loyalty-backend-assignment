module TransactionRewardable
  extend ActiveSupport::Concern

  included do
    after_create do
      issue_five_percentage_cash_rebate_reward unless \
        user.issued_five_percentage_cash_rebate

      issue_free_movie_ticket unless \
        user.issued_free_movie_ticket
    end

    private

    def issue_five_percentage_cash_rebate_reward
      return if number_transactions_have_amount_gt_100 < 10

      reward = Reward.find_by!(name: '5_percentage_cash_rebate')
      user.user_rewards.create!(reward:)

      user.issued_five_percentage_cash_rebate = true
      user.save!
    end

    def issue_free_movie_ticket
      return unless total_spent_fee_within?(60.days) > 1000

      reward = Reward.find_by!(name: 'free_movie_ticket')
      user.user_rewards.create!(reward:)

      user.issued_free_movie_ticket = true
      user.save!
    end

    def number_transactions_have_amount_gt_100
      user.transactions.where(Transaction.arel_table[:fee].gt(100)).count
    end

    def total_spent_fee_within?(time)
      first_record_created_at = user.transactions.first.created_at

      user.transactions.where(
        'created_at >= ? AND created_at < ?',
        first_record_created_at,
        first_record_created_at + time
      ).sum(:fee)
    end
  end
end
