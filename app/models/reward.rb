class Reward < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  has_many :user_rewards, dependent: :destroy
  has_many :users, through: :user_rewards

  ################################ VALIDATION ################################
  validates :name, presence: true
end
