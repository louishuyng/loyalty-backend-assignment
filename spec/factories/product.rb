FactoryBot.define do
  factory :product do
    transactions

    name { FFaker::Internet.user_name }
    price { FFaker::Number.number(digits: 3) }
  end
end
