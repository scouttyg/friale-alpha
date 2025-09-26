module Dashboard
  class AccountsController < BaseController
    before_action :set_account, only: [ :show, :switch, :edit, :update ]

    def index
      @accounts = current_user.accounts.page(params[:page]).per(20)
    end

    def show; end

    def edit; end

    def update
      @account.update(account_params)

      redirect_to(settings_account_path(@account), flash: { success: "Account updated" })
    end

    def switch
      session[:current_account_id] = @account.id
      redirect_to(dashboard_path)
    end

    private

    def account_params
      params.require(:account).permit(:name)
    end

    def set_account
      @account = current_user.accounts.friendly.find(params[:id])
    end
  end
end
