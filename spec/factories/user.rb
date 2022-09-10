FactoryBot.define do
  factory :user do
    user_rewards
    rewards
    transactions
    user_loyalty

    username { FFaker::Internet.user_name }
    password { FFaker::Internet.password }
  end
end
