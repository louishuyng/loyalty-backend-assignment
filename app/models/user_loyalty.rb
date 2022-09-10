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
    if accumulate_point + point >= STANDARD_POINT
      self.current_point += STANDARD_POINT
      self.accumulate_point = (accumulate_point + point) - STANDARD_POINT
    else
      self.accumulate_point += point
    end

    save!
  end
end
