class AddTransactionTable < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :status, null: false, default: 'pending'
      t.integer :fee, null: false # NOTE: fee will based on default currency (sgd) as always to be consistency
      t.string :currency, null: false, default: 'sgd'

      t.references :record, polymorphic: true # NOTE: Currently we only focus on product instances but in the future we can expand to other items or services
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
  end
end
