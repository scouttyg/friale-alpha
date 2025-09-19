module RegistrationConcern
  extend ActiveSupport::Concern

  included do
    helper_method :sign_up_disabled?
    helper_method :check_if_sign_up_disabled
  end

  private

  def check_if_sign_up_disabled
    return unless sign_up_disabled?

    flash[:alert] = "Sign up is currently disabled. Please try again later."
    redirect_to root_path
  end

  def sign_up_disabled?
    ActiveRecord::Type::Boolean.new.cast(ENV.fetch("SIGN_UP_DISABLED", false)) == true
  end
end
