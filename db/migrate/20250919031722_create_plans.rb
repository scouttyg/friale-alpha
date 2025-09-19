class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.datetime :activated_at
      t.datetime :deactivated_at
      t.text :description
      t.string :name
      t.integer :position
      t.jsonb :usage_limits
      t.string :stripe_product_id

      t.timestamps
    end
  end
end
