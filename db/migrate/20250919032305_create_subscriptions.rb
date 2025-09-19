class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.references :plan_period, null: false, foreign_key: true
      t.jsonb :usage_limits
      t.string :stripe_subscription_id

      t.timestamps
    end
  end
end
