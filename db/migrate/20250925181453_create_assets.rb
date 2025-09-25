class CreateAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :assets do |t|
      t.integer :origination
      t.integer :asset_type
      t.decimal :quantity, precision: 10, scale: 2
      t.boolean :current
      t.references :converted_asset, foreign_key: { to_table: :assets }, null: true
      t.references :position, null: false, foreign_key: true
      t.monetize :cap
      t.integer :discount

      t.timestamps
    end
  end
end
