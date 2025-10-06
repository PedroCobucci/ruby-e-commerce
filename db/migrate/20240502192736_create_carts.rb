class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.decimal :total_price, precision: 17, scale: 2, default: 0.0
      t.string :status, default: 'active', null: false

      t.timestamps
    end

    add_index :carts, :status
  end
end
