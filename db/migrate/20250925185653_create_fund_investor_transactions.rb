class CreateFundInvestorTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :fund_investor_transactions do |t|
      t.date :date
      t.integer :status
      t.monetize :amount
      t.references :bank_account, null: true, foreign_key: { to_table: :payment_methods }
      t.references :fund_distribution, null: true, foreign_key: true
      t.references :fund_investor_investment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
