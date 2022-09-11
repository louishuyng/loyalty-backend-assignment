class Transaction < ApplicationRecord
  ################################ CONSTANT ################################
  FEE_TO_ACHIVE_STANDARD_POINT = 100

  ################################ SCOPE ################################
  scope :in_quarter, -> (user, quarter) {
    selected_period = Date.new(Time.now.year.to_i, 3 * quarter.to_i - 2).all_quarter

    where(created_at: selected_period, user:)
  }

  ################################ ASSOCIATIONS ################################
  belongs_to :user
  belongs_to :record, polymorphic: true

  ################################## SETTINGS ##################################
  include TransactionRewardable

  enum(
    status: {
      pending: 'pending',
      reject: 'reject',
      fulfill: 'fulfill',
    }.freeze,
    _prefix: true,
  )

  # NOTE: only allow the list currency below instead of freedom text
  enum(
    currency: {
      # Local currency
      sgd: 'sgd',

      # Foreign currency
      vnd: 'vnd',
      usd: 'usd',
    }.freeze,
    _prefix: true
  )
  ################################ CALLBACK ################################
  after_create :update_user_loyalty # NOTE: we can save transaction even can not record loyalty point

  ################################ VALIDATION ################################
  validates :fee, :status, :currency, presence: true

  ################################ METHODS ################################
  class << self
    def total_fee_in_quarter(user, quarter)
      in_quarter(user, quarter).sum(:fee)
    end
  end

  def update_user_loyalty
    unless local_currency?
      user.loyalty.receive_point(UserLoyalty::STANDARD_POINT * 2)
      return
    end

    user.loyalty.receive_point(fee / FEE_TO_ACHIVE_STANDARD_POINT)
  end

  private

  def local_currency?
    currency_sgd?
  end
end
