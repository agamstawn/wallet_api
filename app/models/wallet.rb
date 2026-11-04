class Wallet < ApplicationRecord
  belongs_to :owner, polymorphic: true

  has_many :credits, class_name: "Transaction", foreign_key: :target_wallet_id,
                     inverse_of: :target_wallet
  has_many :debits,  class_name: "Transaction", foreign_key: :source_wallet_id,
                     inverse_of: :source_wallet

  validates :owner_id, uniqueness: { scope: :owner_type }

  def balance
    credits.sum(:amount) - debits.sum(:amount)
  end

  def deposit!(amount)
    ActiveRecord::Base.transaction do
      lock!
      Deposit.create!(target_wallet: self, amount: amount)
    end
  end

  def withdraw!(amount)
    ActiveRecord::Base.transaction do
      lock!
      Withdrawal.create!(source_wallet: self, amount: amount)
    end
  end

  def transfer_to!(other, amount)
    ActiveRecord::Base.transaction do
      [ self, other ].sort_by(&:id).each(&:lock!)
      Transfer.create!(source_wallet: self, target_wallet: other, amount: amount)
    end
  end
end
