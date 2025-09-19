# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include Dashboard::AccountConcern
    include RegistrationConcern

    layout "dashboard", only: [ :edit, :update ]

    before_action :check_if_sign_up_disabled

    before_action :set_accounts, only: [ :edit, :update ]

    before_action :configure_sign_up_params, only: [ :create ]
    before_action :configure_account_update_params, only: [ :update ]

    # GET /resource/sign_up
    def new
      # Pre-populate email if coming from invitation
      if session[:invitation_email].present?
        build_resource(email: session[:invitation_email])
      else
        super
      end
    end

    # POST /resource
    def create
      super do |resource|
        if resource.persisted? && session[:invitation_token].present?
          # Complete the invitation process
          member = Member.find_by(invite_token: session[:invitation_token])
          if member && member.invite_email == resource.email
            member.accept!(resource)
            session.delete(:invitation_token)
            session.delete(:invitation_email)
            flash[:notice] = "Account created successfully! Welcome to the team."
          end
        end
      end
    end

    # GET /resource/edit
    def edit
      super
    end

    # PUT /resource
    def update
      super
    end

    # DELETE /resource
    def destroy
      super
    end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    def cancel
      super
    end

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(
        :sign_up,
        keys: [ :first_name, :last_name, :email, :password, :password_confirmation ]
      )
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(
        :account_update,
        keys: [ :first_name, :last_name, :email, :password, :password_confirmation, :current_password ]
      )
    end

    # The path used after sign up.
    def after_sign_up_path_for(resource)
      super(resource)
    end

    # The path used after sign up for inactive accounts.
    def after_inactive_sign_up_path_for(resource)
      super(resource)
    end
  end
end
