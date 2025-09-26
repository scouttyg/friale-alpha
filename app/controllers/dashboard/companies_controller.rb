module Dashboard
  class CompaniesController < BaseController
    before_action :set_company, only: [ :show ]

    def index
      # Get all companies from funds that the current account has invested in
      @companies = Company.joins(positions: { fund: :fund_investor_investments })
                         .where(fund_investor_investments: { investor_account: current_account })
                         .includes(:locations, :company_notes, positions: [ :fund, :assets ])
                         .distinct
                         .order(:name)
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
