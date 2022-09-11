class UserLoyalty < ApplicationRecord
  ################################ CONSTANTS ################################
  STANDARD_POINT = 10

  MIN_GOLD_POINT = 1000
  MIN_PLATINUM_POINT = 5000

  ################################ ASSOCIATIONS ################################
  belongs_to :user

  ################################## SETTINGS ##################################
  include LoyaltyRewardable
  include AASM

  enum(
    tier: {
      standard: 'standard',
      gold: 'gold',
      platinum: 'platinum',
    }.freeze,
    _prefix: true
  )

  ################################# STATE MACHINE ################################
  aasm(:tier, column: 'tier', enum: true) do
    state :standard, initial: true
    state :gold, :platinum

    event :tier_up_gold, after: :issue_gold_reward do
      transitions from: :standard, to: :gold do
        guard do
          UserLoyalty.point_match_with_tier?(current_point, :gold)
        end
      end
    end

    event :tier_up_platinum do
      transitions from: %i[standard gold], to: :platinum do
        guard do
          UserLoyalty.point_match_with_tier?(current_point, :platinum)
        end
      end
    end
  end

  ################################ CALLBACK ################################
  # NOTE: can be asynchronous handle and send a message
  # while success up to a new tier through message broker such as kafka to notify FE integration
  after_commit :up_tier_process, on: [:create, :update]

  ################################ VALIDATION ################################
  validates :tier, :current_point, :accumulate_point, presence: true

  ################################ METHODS ################################
  class << self
    def reset_point
      find_each(batch_size: 100) do |user_loyalty|
        user_loyalty.update_columns(current_point: 0)
      end
    end

    def reset_tier
      find_each(batch_size: 100) do |user_loyalty|
        total_point_cycle_one = UserPointHistory.total_point_in_cycle(user_loyalty.user, 1)
        total_point_cycle_two = UserPointHistory.total_point_in_cycle(user_loyalty.user, 2)

        point_to_set_tier = [total_point_cycle_one, total_point_cycle_two].max

        user_loyalty.update_columns(tier: :gold) if point_match_with_tier?(point_to_set_tier, :gold)
        user_loyalty.update_columns(tier: :platinum) if point_match_with_tier?(point_to_set_tier, :platinum)
      end
    end

    def point_match_with_tier?(point, tier)
      point >= "#{name}::MIN_#{tier.upcase}_POINT".constantize
    end
  end

  def receive_point(point)
    future_point = accumulate_point + point
    added_point = 0

    if future_point >= STANDARD_POINT
      added_point = (future_point.to_i / STANDARD_POINT) * STANDARD_POINT

      self.current_point += added_point
      self.accumulate_point = future_point - added_point
    else
      self.accumulate_point += point
    end

    record_user_point_history(added_point) unless added_point.zero?

    save!
  end

  private

  def up_tier_process
    if tier_platinum?
      nil
    elsif tier_standard?
      tier_up_gold! if UserLoyalty.point_match_with_tier?(current_point, :gold)
    elsif tier_gold?
      tier_up_platinum! if UserLoyalty.point_match_with_tier?(current_point, :platinum)
    end
  end

  def record_user_point_history(point)
    user.point_histories.create!(point:)
  end
end
