class UserReward < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  belongs_to :user
  belongs_to :reward

  ################################ CALLBACK ################################
  # TODO: in the future need to remove reward after it has been used

  ################################ SCOPE ################################
  scope :this_month, -> { where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month) }

  ################################ SETTING ################################
  # NOTE: can replace one_month_issue with another data type string
  # when it is possible to have n calendar months/days requirement
  jsonb_accessor :metadata,
    is_one_month_issue: :boolean,
    is_birthday_reward: :boolean
end
