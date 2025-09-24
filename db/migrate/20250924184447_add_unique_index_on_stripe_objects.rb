class AddUniqueIndexOnStripeObjects < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :accounts, :stripe_customer_id, unique: true, algorithm: :concurrently
    add_index :payment_methods, :stripe_payment_method_id, unique: true, algorithm: :concurrently
    add_index :plans, :stripe_product_id, unique: true, algorithm: :concurrently
    add_index :subscriptions, :stripe_subscription_id, unique: true, algorithm: :concurrently
  end

  def down
    remove_index :accounts, :stripe_customer_id
    remove_index :payment_methods, :stripe_payment_method_id
    remove_index :plans, :stripe_product_id
    remove_index :subscriptions, :stripe_subscription_id
  end
end
