module Dashboard
  class FundsController < BaseController
    before_action :set_fund, only: [ :show ]

  def index
    # Get base funds query
    funds_relation = Fund.joins(:fund_investor_investments)
                         .where(fund_investor_investments: { investor_account: current_account })
                         .includes(:fund_investor_investments, :positions)
                         .distinct

    # Apply sorting
    sort_column = params[:sort] || "name"
    sort_direction = params[:direction] || "asc"

    # Validate sort parameters - allow both database and calculated columns
    db_sortable_columns = %w[name]
    calculated_sort_columns = %w[initial_capital deployed_capital gross_capital gross_multiple]
    all_allowed_columns = db_sortable_columns + calculated_sort_columns
    sort_column = "name" unless all_allowed_columns.include?(sort_column)
    sort_direction = "asc" unless %w[asc desc].include?(sort_direction)

    # Only name can be sorted via database
    @funds = funds_relation.order("funds.name #{sort_direction}")

    # For calculated fields, we need to sort in memory after loading
    if calculated_sort_columns.include?(params[:sort])
      @funds_array = @funds.to_a

      case params[:sort]
      when "initial_capital"
        @funds_array.sort_by! { |fund| fund.initial_capital.cents }
      when "deployed_capital"
        @funds_array.sort_by! { |fund| fund.deployed_capital.cents }
      when "gross_capital"
        @funds_array.sort_by! { |fund| fund.gross_capital.cents }
      when "gross_multiple"
        @funds_array.sort_by! { |fund| fund.gross_multiple }
      end

      @funds_array.reverse! if sort_direction == "desc"

      # Convert back to Kaminari-compatible paginated collection
      @funds = Kaminari.paginate_array(@funds_array).page(params[:page]).per(10)
    else
      # Apply pagination for database-sorted results
      @funds = @funds.page(params[:page]).per(10)
    end

    # Store current sort for view (use the actual requested sort, not the validated one)
    @current_sort = { column: params[:sort] || "name", direction: sort_direction }
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
