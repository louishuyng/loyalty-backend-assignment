class AddUserLoyaltyTable < ActiveRecord::Migration[7.0]
  def change
    create_table :user_loyalties do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.integer :accumulate_point, null: false, default: 0
      t.string :tier, null: false, default: 'standard'

      t.timestamps
    end
  end
end
