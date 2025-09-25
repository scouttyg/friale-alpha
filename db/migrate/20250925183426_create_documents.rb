class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.date :date
      t.references :firm_account, index: true, null: true, foreign_key: { to_table: :accounts }
      t.references :fund, null: true, foreign_key: true
      t.references :investor_account, index: true, null: true, foreign_key: { to_table: :accounts }
      t.references :company, null: true, foreign_key: true

      t.timestamps
    end
  end
end
