class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :website
      t.text :description
      t.references :firm_account, index: true, null: true, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end
end
