class UserPointHistory < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  belongs_to :user

  ################################ SCOPE ################################
  scope :this_month, -> (user) {
                       where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month, user:)
                     }
  scope :in_cycle, -> (user, cycle = 0) {
    time_cycle = Time.now - cycle.years

    where(created_at: time_cycle.at_beginning_of_year..time_cycle.at_end_of_year, user:)
  }

  ################################ SETTINGS ################################
  include PointRewardable

  ################################ VALIDATION ################################
  validates :point, presence: true

  ################################ METHOD ################################
  class << self
    def total_point_in_current_month(user)
      this_month(user).sum(:point)
    end

    def total_point_in_cycle(user, cycle = 0)
      in_cycle(user, cycle).sum(:point)
    end
  end
end
