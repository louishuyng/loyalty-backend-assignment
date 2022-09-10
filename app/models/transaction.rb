class Transaction < ApplicationRecord
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
      sgd: 'sgd',
      vnd: 'vnd',
      usd: 'usd',
    }.freeze,
  )

  ################################ VALIDATION ################################
  validates :fee, :status, :currency, presence: true
end
