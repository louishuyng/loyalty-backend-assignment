FactoryBot.define do
  factory :user_loyalty do
    user

    trait :gold do
      tier { UserLoyalty.tiers[:gold] }
    end

    trait :platinum do
      tier { UserLoyalty.tiers[:platinum] }
    end
  end
end
