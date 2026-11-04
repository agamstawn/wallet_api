class Transaction < ApplicationRecord
  belongs_to :source_wallet, class_name: "Wallet", optional: true
  belongs_to :target_wallet, class_name: "Wallet", optional: true

  validates :type, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :source_has_enough_balance, on: :create

  private

  def source_has_enough_balance
    return if source_wallet.nil? || amount.blank? || amount <= 0
    errors.add(:amount, "exceeds available balance") if source_wallet.balance < amount
  end
end
