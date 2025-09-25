# == Schema Information
#
# Table name: companies
#
#  id              :bigint           not null, primary key
#  description     :text
#  name            :string
#  website         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  firm_account_id :bigint
#
# Indexes
#
#  index_companies_on_firm_account_id  (firm_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (firm_account_id => accounts.id)
#
class Company < ApplicationRecord
  belongs_to :firm_account, class_name: "FirmAccount"

  has_many :company_locations, dependent: :destroy
  has_many :locations, through: :company_locations

  has_many :positions, dependent: :destroy
  has_many :assets, through: :positions, dependent: :destroy

  has_many :documents, dependent: :destroy
  has_many :company_notes, dependent: :destroy

  # Get the current stage from the most recent active company note
  def current_stage
    latest_note = company_notes.where(active: true)
                              .where.not(stage: nil)
                              .order(stage: :desc)
                              .first
    latest_note&.stage
  end

  # Get the current performance from the most recent active company note
  def current_performance
    latest_note = company_notes.where(active: true)
                              .where.not(performance: nil)
                              .order(created_at: :desc)
                              .first
    latest_note&.performance
  end

  # Format stage for display
  def current_stage_display
    stage = current_stage
    return "N/A" unless stage

    case stage.to_s
    when "SEED"
      "Seed"
    when "SERIES_A"
      "Series A"
    when "SERIES_B"
      "Series B"
    when "SERIES_C"
      "Series C"
    when "SERIES_D"
      "Series D"
    when "SERIES_E"
      "Series E"
    when "SERIES_F"
      "Series F"
    when "AQUIRED"
      "Acquired"
    else
      stage.humanize
    end
  end

  # Format performance for display
  def current_performance_display
    performance = current_performance
    return "N/A" unless performance

    case performance.to_s
    when "BELOW"
      "Underperforming"
    when "AVERAGE"
      "Average"
    when "ABOVE"
      "Good"
    when "HIGH"
      "Very Good"
    else
      performance.humanize
    end
  end
end
