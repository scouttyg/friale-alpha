class RemoveBrandFromColumnsOnPaymentMethod < ActiveRecord::Migration[8.0]
  def up
    safety_assured { remove_column :payment_methods, :brand, :string }
  end

  def down
    safety_assured { add_column :payment_methods, :brand, :string }
  end
end
