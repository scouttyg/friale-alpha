class CreatePositions < ActiveRecord::Migration[8.0]
  def change
    create_table :positions do |t|
      t.monetize :invested_capital, amount: { limit: 8 }
      t.monetize :returned_capital, amount: { limit: 8 }
      t.datetime :open_date
      t.datetime :close_date
      t.references :company, null: false, foreign_key: true
      t.references :fund, null: false, foreign_key: true

      t.timestamps
    end
  end
end
