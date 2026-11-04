class CreateStocks < ActiveRecord::Migration[8.1]
  def change
    create_table :stocks do |t|
      t.string :name, null: false
      t.string :symbol, null: false

      t.timestamps
    end

    add_index :stocks, :symbol, unique: true
  end
end
