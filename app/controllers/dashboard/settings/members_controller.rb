module Dashboard
  module Settings
    class MembersController < BaseController
      include Pundit::Authorization
      before_action :set_account_from_url

      def index
        @members = @account.members.order(created_at: :asc).page(params[:page]).per(10)
        @member = @account.members.new # for policy checks
      end

      def new
        @member = @account.members.new
        authorize @member
      end

      def create
        @member = @account.members.new(member_params)
        @member.creator = current_user
        authorize @member

        if @member.save
          redirect_to settings_members_path, notice: "Member invited successfully"
        else
          flash[:error] = "Member could not be invited"
          render :new
        end
      rescue Pundit::NotAuthorizedError
        redirect_to settings_members_path,
                    alert: "Cannot add more members. Please upgrade your plan to increase member limit."
      end

      def edit
        @member = @account.members.find(params[:id])
      end

      def update
        @member = @account.members.find(params[:id])
        if @member.update(member_params)
          redirect_to settings_members_path, notice: "Member updated successfully"
        else
          render :edit
        end
      end

      def destroy
        @member = @account.members.find(params[:id])
        authorize @member

        @member.destroy
        redirect_to settings_members_path, notice: "Member deleted successfully"
      rescue Pundit::NotAuthorizedError
        redirect_to settings_members_path,
                    alert: "You are not authorized to remove this member."
      end

      private

      def set_account_from_url
        @account = current_user.accounts.friendly.find(params[:id])
        # Override current_account for this controller
        @current_account = @account
      end

      def member_params
        params.require(:account_member).permit(:invite_email, :access_level)
      end

      def pundit_user
        { user: current_user, account: @account }
      end
    end
  end
end
