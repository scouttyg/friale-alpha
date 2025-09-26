module Dashboard
  class FundsController < BaseController
    before_action :set_fund, only: [ :show ]

    def index
      @funds = current_account.fund_investor_investments
                             .includes(:fund)
                             .map(&:fund)
                             .uniq
    end

  def show
    @fund_investment = current_account.fund_investor_investments
                                     .find_by(fund: @fund)
    @investor_transactions = @fund.fund_investor_transactions
                                  .joins(:fund_investor_investment)
                                  .where(fund_investor_investments: { investor_account: current_account }, status: :COMPLETE)
  end

    private

    def set_fund
      @fund = Fund.find(params[:id])
    end
  end
end
