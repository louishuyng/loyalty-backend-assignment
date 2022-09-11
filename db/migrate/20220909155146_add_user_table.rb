class AddUserTable < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :user_name, null: false, index: { unique: true }
      t.string :password, null: false
      t.datetime :birthday, null: false

      t.timestamps
    end
  end
end
