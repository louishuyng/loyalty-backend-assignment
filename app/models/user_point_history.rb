class UserPointHistory < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  belongs_to :user

  ################################ VALIDATION ################################
  validates :point, presence: true
end
