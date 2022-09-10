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

    if future_point >= STANDARD_POINT
      added_point = (future_point.to_i / STANDARD_POINT) * STANDARD_POINT

      self.current_point += added_point
      self.accumulate_point = future_point - added_point
    else
      self.accumulate_point += point
    end

    save!
  end
end
