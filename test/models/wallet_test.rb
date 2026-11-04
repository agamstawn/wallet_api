require "test_helper"

class WalletTest < ActiveSupport::TestCase
  setup do
    @alice = User.create!(name: "Alice", email: "a@example.com", password: "password123")
    @bob   = User.create!(name: "Bob",   email: "b@example.com", password: "password123")
  end

  test "wallet is created automatically for every walletable" do
    assert_not_nil @alice.wallet
    assert_not_nil Team.create!(name: "T").wallet
    assert_not_nil Stock.create!(name: "S", symbol: "SYM").wallet
  end

  test "balance is sum of credits minus debits" do
    @alice.wallet.deposit!(100)
    @alice.wallet.withdraw!(30)
    assert_equal 70, @alice.wallet.balance
  end

  test "transfer moves money between wallets" do
    @alice.wallet.deposit!(100)
    @alice.wallet.transfer_to!(@bob.wallet, 40)
    assert_equal 60, @alice.wallet.balance
    assert_equal 40, @bob.wallet.balance
  end

  test "cannot withdraw more than balance" do
    assert_raises(ActiveRecord::RecordInvalid) { @alice.wallet.withdraw!(10) }
  end

  test "amount must be positive" do
    assert_raises(ActiveRecord::RecordInvalid) { @alice.wallet.deposit!(0) }
    assert_raises(ActiveRecord::RecordInvalid) { @alice.wallet.deposit!(-5) }
  end

  test "deposit must not have a source wallet" do
    txn = Deposit.new(source_wallet: @alice.wallet, target_wallet: @bob.wallet, amount: 5)
    assert_not txn.valid?
  end

  test "withdrawal must not have a target wallet" do
    txn = Withdrawal.new(source_wallet: @alice.wallet, target_wallet: @bob.wallet, amount: 5)
    assert_not txn.valid?
  end

  test "transfer to the same wallet is invalid" do
    @alice.wallet.deposit!(10)
    assert_raises(ActiveRecord::RecordInvalid) { @alice.wallet.transfer_to!(@alice.wallet, 5) }
  end
end
