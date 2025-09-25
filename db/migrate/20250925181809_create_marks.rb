class CreateMarks < ActiveRecord::Migration[8.0]
  def change
    create_table :marks do |t|
      t.date :mark_date
      t.monetize :price, amount: { limit: 8 }
      t.integer :source
      t.text :notes
      t.references :asset, null: true, foreign_key: true

      t.timestamps
    end
  end
end
