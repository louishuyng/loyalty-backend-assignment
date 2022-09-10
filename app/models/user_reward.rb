class UserReward < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  belongs_to :user
  belongs_to :reward

  ################################ VALIDATION ################################
  validates :usage_amount, presence: true
end
