class Stock < ApplicationRecord
  include Walletable

  validates :name, :symbol, presence: true
  validates :symbol, uniqueness: true
end
