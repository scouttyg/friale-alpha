class CreateFundInvestorInvestments < ActiveRecord::Migration[8.0]
  def change
    create_table :fund_investor_investments do |t|
      t.monetize :capital_commitment
      t.monetize :capital_funded
      t.references :fund, null: false, foreign_key: true
      t.references :investor_account, index: true, null: true, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end
end
