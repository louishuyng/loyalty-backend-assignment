class AddUserRewardTable < ActiveRecord::Migration[7.0]
  def change
    create_table :user_rewards do |t|
      t.datetime :activation_time # NOTE: in case not null then can not be using until activated time
      t.datetime :expired_time # NOTE: will not be expire if null
      t.jsonb :metadata

      t.references :user, null: false, foreign_key: true
      t.references :reward, null: false, foreign_key: true

      t.timestamps
    end
  end
end
