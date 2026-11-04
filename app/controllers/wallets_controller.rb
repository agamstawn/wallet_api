class WalletsController < ApplicationController
  before_action :set_wallet
  before_action :authorize_source!, only: %i[withdraw transfer]

  def show
    render json: wallet_json
  end

  def balance
    render json: { wallet_id: @wallet.id, balance: @wallet.balance }
  end

  def deposit
    render json: transaction_json(@wallet.deposit!(amount_param)), status: :created
  end

  def withdraw
    render json: transaction_json(@wallet.withdraw!(amount_param)), status: :created
  end

  def transfer
    target = Wallet.find(params.require(:target_wallet_id))
    render json: transaction_json(@wallet.transfer_to!(target, amount_param)), status: :created
  end

  private

  def set_wallet
    @wallet = Wallet.find(params[:id])
  end

  def amount_param
    params.require(:amount)
  end

# User's wallet may only be debited by the owner. 
# Team/Stock wallets are considered system wallets.
  def authorize_source!
    owner = @wallet.owner
    return if !owner.is_a?(User) || owner == current_user
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def wallet_json
    { id: @wallet.id, owner_type: @wallet.owner_type, owner_id: @wallet.owner_id,
      balance: @wallet.balance }
  end

  def transaction_json(txn)
    { id: txn.id, type: txn.type, amount: txn.amount,
      source_wallet_id: txn.source_wallet_id, target_wallet_id: txn.target_wallet_id,
      created_at: txn.created_at }
  end
end
