class AddProductTable < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :code # HACK: in case we want to track product make it be mandatory
      t.integer :price, null: false # HACK: we may need change to decimal in the future based on business requirement
      t.string :category, null: false # HACK: it should reference to another table but keep it simple we may use string in here

      t.timestamps
    end
  end
end
