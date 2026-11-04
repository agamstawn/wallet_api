module Walletable
  extend ActiveSupport::Concern

  included do
    has_one :wallet, as: :owner, dependent: :destroy
    after_create :create_wallet!
  end
end
