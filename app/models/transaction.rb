class Transaction < ApplicationRecord
  ################################ CONSTANT ################################
  FEE_TO_ACHIVE_STANDARD_POINT = 100

  ################################ ASSOCIATIONS ################################
  belongs_to :user
  belongs_to :record, polymorphic: true

  ################################## SETTINGS ##################################
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
