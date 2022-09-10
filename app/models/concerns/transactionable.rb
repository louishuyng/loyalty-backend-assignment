module Transactionable
  extend ActiveSupport::Concern

  included do
    has_many :transactions, as: :record, dependent: :destroy
  end
end
