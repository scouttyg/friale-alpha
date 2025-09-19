class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_paper_trail_whodunnit

  protected

  def user_for_paper_trail
    admin_user_signed_in? ? current_admin_user.try(:id) : "Unknown User"
  end

  def info_for_paper_trail
    admin_user_signed_in? ? { whodunnit_type: "AdminUser" } : nil
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def pundit_user
    { user: current_user, account: current_account }
  end
end
