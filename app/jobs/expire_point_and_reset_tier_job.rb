class ExpirePointAndResetTierJob < ApplicationJob
  queue_as :audit_point

  def perform
    UserLoyalty.reset_point

    # TODO: reset tier for all user
  end
end
