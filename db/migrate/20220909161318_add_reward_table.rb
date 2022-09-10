class AddRewardTable < ActiveRecord::Migration[7.0]
  def change
    create_table :rewards do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end
end
