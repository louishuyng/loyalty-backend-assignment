class AddUserPointHistoryTable < ActiveRecord::Migration[7.0]
  def change
    create_table :user_point_histories do |t|
      t.references :user, foreign_key: true, null: false
      t.integer :point, null: false

      t.timestamps
    end
  end
end
