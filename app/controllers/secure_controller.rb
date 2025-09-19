class SecureController < ApplicationController
  include AccountConcern

  before_action :authenticate_user!
  before_action :set_accounts
  before_action :set_paper_trail_whodunnit

  protected

  def info_for_paper_trail
    { whodunnit_type: "User" }
  end
end
