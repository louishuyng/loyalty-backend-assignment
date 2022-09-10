FactoryBot.define do
  factory :user do
    user_name { FFaker::Internet.user_name }
    password { FFaker::Internet.password }
  end
end
