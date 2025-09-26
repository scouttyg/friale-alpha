# == Schema Information
#
# Table name: funds
#
#  id              :bigint           not null, primary key
#  name            :string
#  slug            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  firm_account_id :bigint
#
# Indexes
#
#  index_funds_on_firm_account_id  (firm_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (firm_account_id => accounts.id)
#
class Fund < ApplicationRecord
  belongs_to :firm_account, class_name: "FirmAccount"

  has_many :documents, dependent: :destroy
  has_many :fund_distributions, dependent: :destroy
  has_many :fund_investor_investments, dependent: :destroy
  has_many :fund_investor_transactions, through: :fund_investor_investments
  has_many :positions, dependent: :destroy

  def deployed_capital
    Money.new(positions.sum(:invested_capital_cents) || 0, "USD")
  end

  def returned_capital
    Money.new(positions.sum(:returned_capital_cents) || 0, "USD")
  end

  def open_positions
    positions.where(close_date: nil).order(:id)
  end

  def closed_positions
    positions.where.not(close_date: nil)
  end

  def asset_value
    # Sum the latest mark values for current assets in open positions
    value = 0
    open_positions.includes(assets: :marks).each do |position|
      position.assets.where(current: true).each do |asset|
        latest_mark = asset.marks.order(mark_date: :desc).first
        if latest_mark&.price && asset.quantity
          value += (latest_mark.price * asset.quantity * 100).to_i # Convert to cents
        end
      end
    end
    Money.new(value, "USD")
  end

  def gross_capital
    Money.new(asset_value.cents + returned_capital.cents, "USD")
  end

  def gross_multiple
    return 0 if deployed_capital.cents == 0
    gross_capital.to_f / deployed_capital.to_f
  end

  def deployment_rate
    return 0 if initial_capital.cents == 0
    deployed_capital.to_f / initial_capital.to_f
  end

  # For now, we'll use deployed capital as initial capital since we don't have
  # investor commitment tracking yet. This can be updated when that's implemented.
  def initial_capital
    # TODO: Implement investor fund investment model to track capital commitments
    # For now, return deployed capital as a proxy
    deployed_capital
  end

  # Utility method to format currency values (stored as cents)
  def format_currency(amount_in_cents)
    return "$0" if amount_in_cents.nil? || amount_in_cents == 0
    "$#{number_with_delimiter(amount_in_cents / 100.0, precision: 0)}"
  end

  private

  def number_with_delimiter(number, options = {})
    precision = options[:precision] || 2
    delimiter = options[:delimiter] || ","

    if precision == 0
      number.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{delimiter}").reverse
    else
      formatted = sprintf("%.#{precision}f", number)
      parts = formatted.split(".")
      parts[0] = parts[0].reverse.gsub(/(\d{3})(?=\d)/, "\\1#{delimiter}").reverse
      parts.join(".")
    end
  end
end
