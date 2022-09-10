FactoryBot.define do
  factory :user_reward do
    user
    reward

    usage_amount { FFaker::Number.number(digits: 1) }
  end
end
