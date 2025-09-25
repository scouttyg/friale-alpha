class CreateCompanyNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :company_notes do |t|
      t.boolean :investor_visible
      t.text :note
      t.boolean :active
      t.integer :performance
      t.integer :stage
      t.references :company, null: false, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
