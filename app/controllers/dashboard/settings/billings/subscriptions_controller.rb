module Dashboard
  module Settings
    module Billings
      class SubscriptionsController < SecureController
        before_action :set_plan, only: [ :new, :create ]
        before_action :set_plan_period, only: [ :create ]
        before_action :set_payment_methods, only: [ :new, :create ]

        before_action :ensure_payment_method_exists, only: [ :new ]

        def new
          @subscription = current_account.build_subscription(plan: @plan)
          @plan_period = @plan.plan_periods.find_by(id: params[:plan_period_id])
          @plan_periods = @plan_period.present? ? [ @plan_period ] : @plan.plan_periods
        end

        def create
          stripe_subscription = Stripe::Subscription.create(
            customer: current_account.stripe_customer_id,
            items: [ {
              price: @plan_period.stripe_price_id
            } ],
            default_payment_method: payment_method.stripe_payment_method_id,
            payment_behavior: "default_incomplete",
            expand: [ "latest_invoice.payment_intent" ]
          )

          @subscription = current_account.create_subscription!(
            plan: @plan,
            plan_period: @plan_period,
            stripe_subscription_id: stripe_subscription.id
          )

          redirect_to plan_settings_billings_path(current_account),
                      notice: "Subscription was successfully created."
        rescue Stripe::StripeError => e
          flash.now[:error] = e.message
          render :new, status: :unprocessable_entity
        rescue ActiveRecord::RecordInvalid => e
          # If local subscription creation fails, cancel the Stripe subscription
          Stripe::Subscription.cancel(stripe_subscription.id) if stripe_subscription
          flash.now[:error] = e.record.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end

        def cancel
          @subscription = current_account.subscription

          if @subscription
            begin
              Stripe::Subscription.update(
                @subscription.stripe_subscription_id,
                { cancel_at_period_end: true }
              )
              @subscription.update!(status: :cancelled)
              redirect_to plan_settings_billings_path(current_account),
                          notice: "Your subscription has been cancelled and will end at the current billing period."
            rescue Stripe::StripeError => e
              redirect_to plan_settings_billings_path(current_account),
                          alert: "Unable to cancel subscription: #{e.message}"
            end
          else
            redirect_to plan_settings_billings_path(current_account),
                        alert: "No active subscription found."
          end
        end

        private

        def set_plan
          @plan = Plan.find(params[:plan_id] || params[:subscription][:plan_id])
        rescue ActiveRecord::RecordNotFound
          redirect_to plan_settings_billings_path(current_account),
                      alert: "Selected plan not found."
        end

        def set_plan_period
          @plan_period = @plan.plan_periods.find(params[:subscription][:plan_period_id])
        rescue ActiveRecord::RecordNotFound
          redirect_to new_settings_subscription_path(plan_id: @plan.id),
                      alert: "Selected billing period not found."
        end

        def set_payment_methods
          @payment_methods = current_account.payment_methods.active.order(default: :desc)
        end

        def payment_method
          @payment_method ||= current_account.payment_methods.find(params[:subscription][:payment_method_id])
        end

        def ensure_payment_method_exists
          return if current_account.active_payment_methods.any?

          redirect_to settings_payment_methods_path(current_account),
                      alert: "Please add a payment method before selecting a subscription plan."
        end
      end
    end
  end
end
