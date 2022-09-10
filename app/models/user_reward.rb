class UserReward < ApplicationRecord
  ################################ ASSOCIATIONS ################################
  belongs_to :user
  belongs_to :reward

  ################################ SETTING ################################
  # NOTE: can replace one_month_issue with another data type string
  # when it is possible to have n calendar months/days requirement
  jsonb_accessor :metadata, usage_amount: :integer,
                 one_month_issue: :boolean
end
