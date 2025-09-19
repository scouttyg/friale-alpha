module Dashboard
  module Settings
    class BillingsController < BaseController
      def plan
        @current_plan = current_account.plan
        @subscription = current_account.subscription

        @plans = Plan.active
      end

      def overview
        @subscription = current_account.subscription
        @current_plan = current_account.plan
      end
    end
  end
end
