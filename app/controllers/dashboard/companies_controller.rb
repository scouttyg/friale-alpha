module Dashboard
  class CompaniesController < BaseController
    before_action :set_company, only: [ :show ]

  def index
    # Get base companies query
    companies_relation = Company.joins(positions: { fund: :fund_investor_investments })
                               .where(fund_investor_investments: { investor_account: current_account })
                               .includes(:locations, :company_notes, positions: [ :fund, :assets ])
                               .distinct

    # Apply sorting
    sort_column = params[:sort] || "name"
    sort_direction = params[:direction] || "asc"

    # Validate sort parameters - separate database vs calculated columns
    db_sortable_columns = %w[name]
    calculated_sort_columns = %w[fund stage performance gross_multiple gross_capital invested_capital]

    all_allowed_columns = db_sortable_columns + calculated_sort_columns
    sort_column = "name" unless all_allowed_columns.include?(sort_column)
    sort_direction = "asc" unless %w[asc desc].include?(sort_direction)

    # Apply database sorting for supported columns
    case sort_column
    when "name"
      @companies = companies_relation.order("companies.name #{sort_direction}")
    else
      # Default sort by name for calculated fields (we'll sort them in memory)
      @companies = companies_relation.order("companies.name ASC")
    end

    # For calculated fields, we need to sort in memory after loading
    if calculated_sort_columns.include?(params[:sort])
      @companies_array = @companies.to_a

      case params[:sort]
      when "fund"
        @companies_array.sort_by! do |company|
          position = company.positions.joins(fund: :fund_investor_investments)
                            .where(fund_investor_investments: { investor_account: current_account })
                            .includes(:fund)
                            .first
          position&.fund&.name || ""
        end
      when "stage"
        @companies_array.sort_by! { |company| company.current_stage.to_s }
      when "performance"
        @companies_array.sort_by! { |company| company.current_performance.to_s }
      when "invested_capital"
        @companies_array.sort_by! do |company|
          position = company.positions.joins(fund: :fund_investor_investments)
                            .where(fund_investor_investments: { investor_account: current_account })
                            .includes(:fund)
                            .first
          position&.invested_capital_cents || 0
        end
      when "gross_multiple"
        @companies_array.sort_by! do |company|
          position = company.positions.joins(fund: :fund_investor_investments)
                            .where(fund_investor_investments: { investor_account: current_account })
                            .includes(:fund)
                            .first
          position&.gross_multiple || 0
        end
      when "gross_capital"
        @companies_array.sort_by! do |company|
          position = company.positions.joins(fund: :fund_investor_investments)
                            .where(fund_investor_investments: { investor_account: current_account })
                            .includes(:fund)
                            .first
          position&.gross_capital&.cents || 0
        end
      end

      @companies_array.reverse! if sort_direction == "desc"

      # Convert back to Kaminari-compatible paginated collection
      @companies = Kaminari.paginate_array(@companies_array).page(params[:page]).per(10)
    else
      # Apply pagination for database-sorted results
      @companies = @companies.page(params[:page]).per(10)
    end

    # Store current sort for view (use the actual requested sort, not the validated one)
    @current_sort = { column: params[:sort] || "name", direction: sort_direction }
  end

    def show
      # Ensure the company belongs to a fund the investor has access to
      unless company_accessible_by_current_account?
        redirect_to companies_path, alert: "Company not found or access denied."
        return
      end

      # Get the position for this company in the fund the investor has access to
      @position = @company.positions
                         .joins(fund: :fund_investor_investments)
                         .where(fund_investor_investments: { investor_account: current_account })
                         .includes(:fund, :assets)
                         .first

      # Get timeline events (company notes) ordered by latest first
      @timeline_events = @company.company_notes
                                .where(active: true)
                                .order(created_at: :desc)

      # Get company documents
      @documents = @company.documents.order(date: :desc)
    end

    private

    def set_company
      @company = Company.find(params[:id])
    end

    def company_accessible_by_current_account?
      @company.positions
              .joins(fund: :fund_investor_investments)
              .where(fund_investor_investments: { investor_account: current_account })
              .exists?
    end
  end
end
