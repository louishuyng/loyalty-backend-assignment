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
end
