class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :slug
      t.string :type
      t.string :stripe_customer_id

      t.timestamps
    end
  end
end
