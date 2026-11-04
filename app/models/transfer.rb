class Transfer < Transaction
  validates :source_wallet, :target_wallet, presence: true
  validate :wallets_must_differ

  private

  def wallets_must_differ
    return unless source_wallet && target_wallet
    errors.add(:target_wallet, "must differ from source wallet") if source_wallet == target_wallet
  end
end
