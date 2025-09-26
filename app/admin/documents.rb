ActiveAdmin.register Document do
  menu priority: 8

  permit_params :name, :date, :firm_account_id, :fund_id, :investor_account_id, :company_id, :file

  index do
    selectable_column
    id_column
    column :name
    column :date
    column :firm_account
    column :fund
    column :investor
    column :company
    column "File" do |document|
      filename = document.file.filename.to_s rescue "Unknown file"
      if document.file.attached?
        div do
          link_to filename, rails_blob_path(document.file, disposition: "attachment"), class: "button"
        end
      else
        "No file attached"
      end
    end
    column "File Size" do |document|
      number_to_human_size(document.file_size) if document.file.attached?
    end
    column :created_at
    actions
  end

  filter :name
  filter :date
  filter :firm_account
  filter :fund
  filter :investor_account
  filter :company
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :date
      row :firm_account
      row :fund
      row :investor_account
      row :company
      row "File" do |document|
        filename = document.file.filename.to_s rescue "Unknown file"
        if document.file.attached?
          div do
            link_to filename, rails_blob_path(document.file, disposition: "attachment"), class: "button"
          end
        else
          "No file attached"
        end
      end
      row "File Size" do |document|
        number_to_human_size(document.file_size) if document.file.attached?
      end
      row "Content Type" do |document|
        document.content_type if document.file.attached?
      end
      row :created_at
      row :updated_at
    end

    # Show file preview for images
    if resource.file.attached? && resource.file.image?
      panel "File Preview" do
        image_tag rails_blob_path(resource.file), style: "max-width: 500px; max-height: 400px;"
      end
    end

    # Show PDF preview for PDF files
    if resource.file.attached? && resource.file.content_type&.include?("pdf")
      panel "PDF Preview" do
        div style: "width: 100%; height: 800px; border: 1px solid #ddd;" do
          tag.iframe(
            src: rails_blob_path(resource.file, disposition: "inline"),
            width: "100%",
            height: "100%",
            style: "border: none;"
          )
        end
        div style: "margin-top: 10px;" do
          link_to "Open PDF in new tab", rails_blob_path(resource.file, disposition: "inline"),
                  target: "_blank", class: "button"
        end
      end
    end
  end

  form do |f|
    f.inputs "Document Details" do
      f.input :name
      f.input :date, as: :datepicker
      f.input :file, as: :file, hint: f.object.file.attached? ? "Current file: #{f.object.filename}" : "No file uploaded"
    end

    f.inputs "Associations" do
      f.input :firm_account, as: :select, collection: FirmAccount.all.order(:name), include_blank: "Select a firm (optional)"
      f.input :fund, as: :select, collection: Fund.includes(:firm_account).order("accounts.name, funds.name"), include_blank: "Select a fund (optional)" do |fund|
        "#{fund.firm_account.name} - #{fund.name}"
      end
      f.input :investor_account, as: :select, collection: InvestorAccount.all.order(:name), include_blank: "Select an investor account (optional)" do |investor_account|
        investor_account.user.email
      end
      f.input :company, as: :select, collection: Company.includes(:firm_account).order("accounts.name, companies.name"), include_blank: "Select a company (optional)" do |company|
        "#{company.firm_account.name} - #{company.name}"
      end
    end

    f.actions
  end

  # Custom action to download file
  member_action :download, method: :get do
    if resource.file.attached?
      redirect_to rails_blob_path(resource.file, disposition: "attachment")
    else
      redirect_to admin_document_path(resource), alert: "No file attached to this document"
    end
  end

  action_item :download, only: :show do
    if resource.file.attached?
      link_to "Download File", download_admin_document_path(resource), class: "button"
    end
  end
end
