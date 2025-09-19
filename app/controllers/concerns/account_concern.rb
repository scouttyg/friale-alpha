module Dashboard
  module AccountConcern
    extend ActiveSupport::Concern

    included do
      helper_method :current_account
    end

    private

    def set_accounts
      @accounts = current_user.accounts
    end

    def current_account
      @current_account ||= current_user.accounts.find(session[:current_account_id])
    rescue ActiveRecord::RecordNotFound
      @current_account = current_user.accounts.first
      session[:current_account_id] = @current_account.id if @current_account

      @current_account
    end
  end
end
