class InvitationsController < ApplicationController
  before_action :find_member_by_token, only: [ :show, :accept ]
  before_action :check_invitation_eligibility, only: [ :show, :accept ]

  def show
    @account = @member.source
    @creator = @member.creator
  end

  def accept
    # If user is signed in, use current user
    if user_signed_in?
      @member.accept!(current_user)
      redirect_to account_path(@member.source), notice: "Invitation accepted! Welcome to the team."
    else
      # Check if user with this email already exists
      existing_user = User.find_by(email: @member.invite_email)

      if existing_user
        # User exists, sign them in and accept invitation
        sign_in(existing_user)
        @member.accept!(existing_user)
        redirect_to account_path(@member.source), notice: "Invitation accepted! Welcome to the team."
      else
        # Store invitation info in session and redirect to sign up
        session[:invitation_token] = @member.invite_token
        session[:invitation_email] = @member.invite_email
        redirect_to new_user_registration_path, notice: "Please create your account to complete the invitation."
      end
    end
  end

  def decline
    @member = Member.find_by(invite_token: params[:token])

    if @member.nil?
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    if @member.accepted?
      redirect_to root_path, alert: "This invitation has already been accepted."
      return
    end

    # Check if signed-in user is trying to decline someone else's invitation
    if user_signed_in? && current_user.email != @member.invite_email
      redirect_to root_path, alert: "You cannot decline an invitation for a different email address."
      return
    end

    @member.destroy
    redirect_to root_path, notice: "Invitation declined."
  end

  private

  def find_member_by_token
    @member = Member.find_by(invite_token: params[:token]) if params[:token].present?
  end

  def check_invitation_eligibility
    if @member.nil?
      redirect_to root_path, alert: "Invalid invitation link."
      return
    end

    if @member.accepted?
      redirect_to root_path, alert: "This invitation has already been accepted."
      return
    end

    # If user is signed in, check if they"re trying to accept someone else"s invitation
    if user_signed_in? && current_user.email != @member.invite_email
      redirect_to root_path, alert: "This invitation is for a different email address. Please sign out first if you want to accept this invitation."
      nil
    end
  end
end
