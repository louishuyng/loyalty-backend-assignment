class QuarterRewardBonusPointJob < ApplicationJob
  queue_as :reward

  def perform
    UserLoyalty.process_quarterly_reward
  end
end
