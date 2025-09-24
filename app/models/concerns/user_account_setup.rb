module UserAccountSetup
  FakeStripeSubscription = Data.define(:id)
  extend ActiveSupport::Concern

  included do
    after_create :setup_personal_account
  end

  private

  def setup_personal_account
    return if accounts.where(type: "PersonalAccount").exists?

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

      stripe_subscription = nil

      # Create Stripe subscription
      begin
        stripe_subscription = Stripe::Subscription.create({
          customer: account.stripe_customer_id,
          items: [ {
            price: free_plan_period.stripe_price_id
          } ],
          metadata: {
            account_id: account.id
          }
        })
      rescue Stripe::InvalidRequestError
        raise unless Rails.env.development? || Rails.env.test?
      end

      if (Rails.env.development? || Rails.env.test?) && stripe_subscription.nil?
        # If you see this, you haven't setup Stripe set locally correctly
        stripe_subscription = FakeStripeSubscription.new(id: "sub_MOCK#{SecureRandom.alphanumeric(14)}")
      end

      # Create subscription for the free plan
      account.create_subscription!(
        plan: free_plan,
        plan_period: free_plan_period,
        stripe_subscription_id: stripe_subscription.id
      )
    end
  rescue Stripe::StripeError => e
    Rails.logger.error "Failed to create Stripe subscription: #{e.message}"
    raise
  end
end
