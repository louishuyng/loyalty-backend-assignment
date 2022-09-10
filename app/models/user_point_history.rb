class UserPointHistory < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  belongs_to :user

  ################################ SCOPE ################################
  scope :this_month, -> (user) {
                       where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month, user:)
                     }

  ################################ SETTINGS ################################
  include Rewardable

  ################################ VALIDATION ################################
  validates :point, presence: true

  ################################ METHOD ################################
  class << self
    def total_point_in_current_month(user)
      this_month(user).sum(:point)
    end
  end
end
