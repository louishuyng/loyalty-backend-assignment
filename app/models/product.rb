class Product < ApplicationRecord
  ################################ SETTINGS ################################
  include Transactionable

  ################################ VALIDATION ################################
  validates :name, :price, :category, presence: true
end
