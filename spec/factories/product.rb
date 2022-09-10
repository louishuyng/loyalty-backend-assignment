FactoryBot.define do
  factory :product do
    name { FFaker::Internet.user_name }
    price { FFaker::Number.number(digits: 3) }
    category { 'sample_category' }
  end
end
