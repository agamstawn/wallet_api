class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.string :type, null: false
      t.references :source_wallet, foreign_key: { to_table: :wallets }
      t.references :target_wallet, foreign_key: { to_table: :wallets }
      t.decimal :amount, precision: 20, scale: 2, null: false

      t.timestamps
    end

    add_index :transactions, :type
  end
end
