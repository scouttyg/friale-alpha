class CreateFundDistributions < ActiveRecord::Migration[8.0]
  def change
    create_table :fund_distributions do |t|
      t.string :name
      t.date :date
      t.monetize :amount, amount: { limit: 8 }
      t.text :notes
      t.references :fund, null: false, foreign_key: true
      t.references :position, null: true, foreign_key: true

      t.timestamps
    end
  end
end
