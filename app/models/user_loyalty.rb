class UserLoyalty < ApplicationRecord
  ################################ CONSTANTS ################################
  STANDARD_POINT = 10

  ################################ ASSOCIATIONS ################################
  belongs_to :user

  ################################## SETTINGS ##################################
  enum(
    tier: {
      standard: 'standard',
      gold: 'gold',
      platinum: 'platinum',
    }.freeze,
  )

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

  def record_user_point_history(point)
    user.point_histories.create!(point:)
  end
end
