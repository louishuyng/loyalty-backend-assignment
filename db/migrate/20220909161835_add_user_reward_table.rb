class AddUserRewardTable < ActiveRecord::Migration[7.0]
  def change
    create_table :user_rewards do |t|
      t.datetime :activation_time # NOTE: in case not null then can not be using until activated time
      t.datetime :expired_time # NOTE: will not be expire if null
      t.integer :usage_amount, null: false, default: 1 # NOTE: in case saving resource we may need to add usage_amount for the same issued reward
      t.jsonb :metadata

      t.references :user, null: false, foreign_key: true
      t.references :reward, null: false, foreign_key: true

      t.timestamps
    end
  end
end
