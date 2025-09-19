module Dashboard
  module Settings
    class PaymentMethodsController < BaseController
      before_action :ensure_stripe_customer
      before_action :set_payment_method, only: [ :make_default, :destroy ]

      def index
        @payment_methods = current_account.payment_methods.active.default_first

        # Create SetupIntent for new payment method
        @setup_intent = Stripe::SetupIntent.create(
          customer: current_account.stripe_customer_id,
          usage: "off_session"
        )
      end

      def create
        stripe_payment_method = Stripe::PaymentMethod.retrieve(params[:payment_method_id])

        # Attach payment method to customer
        Stripe::PaymentMethod.attach(
          stripe_payment_method.id,
          customer: current_account.stripe_customer_id
        )

        # Create local record based on payment method type
        @payment_method = build_payment_method(stripe_payment_method)
        @payment_method.save!

        # Make default if it's the first payment method
        @payment_method.mark_as_default! if current_account.payment_methods.count == 1

        redirect_to settings_payment_methods_path(current_account), notice: "Payment method added successfully"
      rescue Stripe::StripeError => e
        redirect_to settings_payment_methods_path(current_account), alert: e.message
      rescue ActiveRecord::RecordInvalid => e
        redirect_to settings_payment_methods_path(current_account), alert: e.record.errors.full_messages.to_sentence
      end

      def make_default
        @payment_method.mark_as_default!
        redirect_to settings_payment_methods_path(current_account), notice: "Default payment method updated"
      end

      def destroy
        Stripe::PaymentMethod.detach(@payment_method.stripe_payment_method_id)
        @payment_method.soft_delete!
        redirect_to settings_payment_methods_path(current_account), notice: "Payment method removed"
      rescue Stripe::StripeError => e
        redirect_to settings_payment_methods_path(current_account), alert: e.message
      end

      private

      def ensure_stripe_customer
        current_account.send(:ensure_stripe_customer) if current_account.stripe_customer_id.blank?
      rescue Stripe::StripeError
        redirect_to settings_payment_methods_path(current_account),
                    alert: "Unable to process payment methods at this time. Please try again later."
      end

      def set_payment_method
        @payment_method = current_account.payment_methods.find(params[:id])
      end

      def build_payment_method(stripe_payment_method)
        case stripe_payment_method.type
        when "card"
          PaymentMethods::Card.new(
            account: current_account,
            stripe_payment_method_id: stripe_payment_method.id,
            metadata: {
              brand: stripe_payment_method.card.brand,
              last_four: stripe_payment_method.card.last4,
              exp_month: stripe_payment_method.card.exp_month,
              exp_year: stripe_payment_method.card.exp_year
            }
          )
        else
          raise ArgumentError, "Unsupported payment method type: #{stripe_payment_method.type}"
        end
      end
    end
  end
end
