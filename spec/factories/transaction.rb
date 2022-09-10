FactoryBot.define do
  factory :transaction do
    fee { FFaker::Number.number(digits: 3) }

    trait :reject do
      status { Transaction.statuses[:reject] }
    end

    trait :fulfill do
      status { Transaction.statuses[:fulfill] }
    end
  end
end
