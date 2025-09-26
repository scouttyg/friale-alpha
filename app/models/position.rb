# == Schema Information
#
# Table name: positions
#
#  id                        :bigint           not null, primary key
#  close_date                :datetime
#  invested_capital_cents    :bigint           default(0), not null
#  invested_capital_currency :string           default("USD"), not null
#  open_date                 :datetime
#  returned_capital_cents    :bigint           default(0), not null
#  returned_capital_currency :string           default("USD"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_id                :bigint           not null
#  fund_id                   :bigint           not null
#
# Indexes
#
#  index_positions_on_company_id  (company_id)
#  index_positions_on_fund_id     (fund_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (fund_id => funds.id)
#
class Position < ApplicationRecord
  monetize :invested_capital_cents
  monetize :returned_capital_cents

  belongs_to :company
  belongs_to :fund

  has_many :assets, dependent: :destroy
  has_many :fund_distributions

  scope :open, -> { where(close_date: nil) }
  scope :closed, -> { where.not(close_date: nil) }

  # Current assets (active holdings)
  def current_assets
    assets.where(current: true)
  end

  # Asset value based on latest marks
  def asset_value
    value = 0
    current_assets.includes(:marks).each do |asset|
      latest_mark = asset.marks.order(mark_date: :desc).first
      if latest_mark&.price && asset.quantity
        value += (latest_mark.price * asset.quantity * 100).to_i # Convert to cents
      end
    end
    Money.new(value, "USD")
  end

  # Gross capital = returned capital + current asset value
  def gross_capital
    total_cents = returned_capital_cents || 0
    if close_date.nil? # Only add asset value for open positions
      total_cents += asset_value.cents
    end
    Money.new(total_cents, "USD")
  end

  # Gross multiple = gross capital / invested capital
  def gross_multiple
    return 0 if invested_capital_cents.nil? || invested_capital_cents == 0
    gross_capital.to_f / invested_capital.to_f
  end

  # Check if position is new (opened within last 30 days)
  def is_new?
    return false if open_date.nil?
    cutoff = 30.days.ago.to_date
    open_date > cutoff
  end
end
