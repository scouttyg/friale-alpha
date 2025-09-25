# == Schema Information
#
# Table name: documents
#
#  id                  :bigint           not null, primary key
#  date                :date
#  name                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint
#  firm_account_id     :bigint
#  fund_id             :bigint
#  investor_account_id :bigint
#
# Indexes
#
#  index_documents_on_company_id           (company_id)
#  index_documents_on_firm_account_id      (firm_account_id)
#  index_documents_on_fund_id              (fund_id)
#  index_documents_on_investor_account_id  (investor_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (firm_account_id => accounts.id)
#  fk_rails_...  (fund_id => funds.id)
#  fk_rails_...  (investor_account_id => accounts.id)
#
class Document < ApplicationRecord
  belongs_to :firm_account, class_name: "FirmAccount", optional: true
  belongs_to :fund, optional: true
  belongs_to :investor_account, class_name: "InvestorAccount", optional: true
  belongs_to :company, optional: true

  has_one_attached :file

  validates :name, presence: true
  validates :date, presence: true
  validates :file, presence: true

  # Validate that at least one association is present
  validate :at_least_one_association

  scope :for_firm_account, ->(firm) { where(firm_account: firm_account) }
  scope :for_fund, ->(fund) { where(fund: fund) }
  scope :for_investor_account, ->(investor_account) { where(investor_account: investor_account) }
  scope :for_company, ->(company) { where(company: company) }

  def filename
    file.attached? ? file.filename.to_s : nil
  end

  def file_size
    file.attached? ? file.blob.byte_size : 0
  end

  def content_type
    file.attached? ? file.blob.content_type : nil
  end

  private

  def at_least_one_association
    return if firm.present? || fund.present? || investor.present? || company.present?

    errors.add(:base, "Document must be associated with at least one firm, fund, investor, or company")
  end
end
