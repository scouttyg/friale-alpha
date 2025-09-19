module UserAccountSetup
  extend ActiveSupport::Concern

  included do
    after_create :setup_personal_account
  end

  private

  def setup_personal_account
    ActiveRecord::Base.transaction do
      # Create personal account
      account = PersonalAccount.create!(
        name: display_name,
        owner: self
      )

      # Ensure Stripe customer is created (this will happen via callback)
      account.reload

      # Find the free plan
      free_plan = Plan.active.order(position: :asc).first
      free_plan_period = free_plan.plan_periods.first

      # Create Stripe subscription
      stripe_subscription = Stripe::Subscription.create({
        customer: account.stripe_customer_id,
        items: [ {
          price: free_plan_period.stripe_price_id
        } ],
        metadata: {
          account_id: account.id
        }
      })

      # Create subscription for the free plan
      account.create_subscription!(
        plan: free_plan,
        plan_period: free_plan_period,
        stripe_subscription_id: stripe_subscription.id
      )
    end
  rescue Stripe::StripeError => e
    Rails.logger.error "Failed to create Stripe subscription for account #{account&.id}: #{e.message}"
    raise
  end
end
