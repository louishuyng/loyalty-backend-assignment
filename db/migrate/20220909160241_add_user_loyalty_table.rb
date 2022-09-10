class AddUserLoyaltyTable < ActiveRecord::Migration[7.0]
  def change
    create_table :user_loyalties do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.integer :current_point, null: false, default: 0

      # NOTE: it will be reset and added to current point after reach standard point
      # we can save it on redis to keep a state. However, need to consider move to redis based on number of user
      t.decimal :accumulate_point, null: false, default: 0

      t.string :tier, null: false, default: 'standard'

      t.timestamps
    end
  end
end
