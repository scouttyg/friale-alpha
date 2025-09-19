module Plans
  module Stripe
    class Importer
      attr_reader :reorder

      def self.import!(reorder: false, force: false)
        stripe_plans.each do |stripe_plan_data|
          plan = Plan.find_or_initialize_by(stripe_product_id: stripe_plan_data.id)

          if plan.new_record? || force
            metadata = stripe_plan_data.metadata

            plan.member_limit = metadata["member_limit"] if metadata["member_limit"]
            plan.webhook_endpoint_limit = metadata["webhook_endpoint_limit"] if metadata["webhook_endpoint_limit"]
            plan.api_event_limit = metadata["api_event_limit"] if metadata["api_event_limit"]
            plan.name = metadata["presentable_name"] || stripe_plan_data.name

            plan.save!
          end

          update_plan_periods(plan, stripe_plan_data)
        end

        return unless reorder

        Plan.reorder_plans!
      end

      def self.update_plan_periods(plan, stripe_plan_data)
        stripe_prices(stripe_plan_data).each do |stripe_price|
          plan_period = plan.plan_periods.find_or_initialize_by(stripe_price_id: stripe_price.id)
          plan_period.update!(
            interval: stripe_price.recurring.interval.upcase,
            price_cents: stripe_price.tiers.first.flat_amount || stripe_price.unit_amount || 0,
            price_currency: stripe_price.currency.upcase || "USD"
          )
        end
      end

      def self.stripe_plans
        @stripe_plans ||= ::Stripe::Product.search({ query: "metadata['subscription_plan']:'true'" })
      end

      def self.stripe_prices(stripe_plan_data)
        ::Stripe::Price.search({ query: "product: '#{stripe_plan_data.id}'", expand: [ "data.tiers" ] })
      end
    end
  end
end
