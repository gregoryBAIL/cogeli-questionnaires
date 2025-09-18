class CreateProductKits < ActiveRecord::Migration[7.2]
  def change
    create_table :product_kits do |t|
      t.string :category
      t.string :code
      t.string :name
      t.text :description
      t.text :condition_expression
      t.decimal :price
      t.integer :stock
      t.boolean :active
      t.jsonb :metadata

      t.timestamps
    end
    add_index :product_kits, :code, unique: true
  end
end
