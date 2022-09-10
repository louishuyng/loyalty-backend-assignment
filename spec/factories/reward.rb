FactoryBot.define do
  factory :reward do
    user_rewards
    users

    name { 'sample reward' }
  end
end
