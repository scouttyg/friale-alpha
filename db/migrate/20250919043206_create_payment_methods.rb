class CreatePaymentMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_methods do |t|
      t.string :brand
      t.boolean :default, default: false
      t.datetime :deleted_at
      t.jsonb :metadata
      t.string :type
      t.references :account, null: false, foreign_key: true
      t.string :stripe_payment_method_id, null: false

      t.timestamps
    end
  end
end
