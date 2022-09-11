class UserLoyalty < ApplicationRecord
  ################################ CONSTANTS ################################
  STANDARD_POINT = 10

  MIN_GOLD_POINT = 1000
  MIN_PLATINUM_POINT = 5000

  ################################ ASSOCIATIONS ################################
  belongs_to :user

  ################################## SETTINGS ##################################
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

    event :tier_up_gold do
      transitions from: :standard, to: :gold do
        guard do
          point_match_with_tier?(:gold)
        end
      end
    end

    event :tier_up_platinum do
      transitions from: %i[standard gold], to: :platinum do
        guard do
          point_match_with_tier?(:platinum)
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
      tier_up_gold! if point_match_with_tier?(:gold)
    elsif tier_gold?
      tier_up_platinum! if point_match_with_tier?(:platinum)
    end
  end

  def point_match_with_tier?(tier)
    current_point >= "#{self.class.name}::MIN_#{tier.upcase}_POINT".constantize
  end

  def record_user_point_history(point)
    user.point_histories.create!(point:)
  end
end
