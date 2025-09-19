class CreatePlanPeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :plan_periods do |t|
      t.references :plan, null: false, foreign_key: true
      t.monetize :price
      t.integer :interval
      t.string :stripe_price_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
