class CreateFunds < ActiveRecord::Migration[8.0]
  def change
    create_table :funds do |t|
      t.string :name
      t.string :slug
      t.references :firm_account, index: true, null: true, foreign_key: { to_table: :accounts }

      t.timestamps
    end
  end
end
