class ExpirePointAndResetTierJob < ApplicationJob
  queue_as :audit_point

  def perform
    UserLoyalty.reset_point
    UserLoyalty.reset_tier
  end
end
