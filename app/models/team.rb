class Team < ApplicationRecord
  include Walletable
  
  validates :name, presence: true
end
