class User < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  has_many :user_rewards, dependent: :destroy
  has_many :rewards, through: :user_rewards

  has_many :transactions, dependent: :destroy
  has_many :point_histories, class_name: 'UserPointHistory', dependent: :destroy, foreign_key: :user_id

  has_one :loyalty, class_name: 'UserLoyalty', foreign_key: :user_id, inverse_of: :user, dependent: :destroy

  ################################ CALLBACK ################################
  after_create :create_loyalty

  ################################ VALIDATION ################################
  # TODO: Implement JWT and Hashing password
  validates :user_name, :password, presence: true
end
