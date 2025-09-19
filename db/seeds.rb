# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
raise 'NoSeedsInProductionErrror' if Rails.env.production?

admin_user = AdminUser.where(email: 'admin@example.com').first_or_initialize
if admin_user.new_record?
  admin_user.password = 'password'
  admin_user.password_confirmation = 'password'
  admin_user.save!
  puts "Imported admin_user"
end

free_plan = Plan.where(name: 'Free').first_or_initialize
if free_plan.new_record?
  free_plan.stripe_product_id = 'stripe_product_mock_123'
  free_plan.activated_at = Time.now
  free_plan.position = 1
  free_plan.save!
  puts "Imported 'Free' Plan"
end

plan_period = PlanPeriod.where(plan: free_plan, interval: 'MONTH').first_or_initialize
if plan_period.new_record?
  plan_period.stripe_price_id = 'stripe_price_mock_123'
  plan_period.save!
  puts "Imported monthly PlanPeriod for 'Free' Plan"
end
