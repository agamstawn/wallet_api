class CreateWallets < ActiveRecord::Migration[8.1]
  def change
    create_table :wallets do |t|
      t.references :owner, polymorphic: true, null: false, index: false
     
      t.timestamps
    end
    
    add_index :wallets, [:owner_type, :owner_id], unique: true
  end
end
