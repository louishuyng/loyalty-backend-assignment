class UserLoyalty < ApplicationRecord
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
  validates :tier, :accumulate_point, presence: true
end
