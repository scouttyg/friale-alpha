ActiveAdmin.register Fund do
  menu priority: 4

  permit_params :name, :slug, :firm_id

  index do
    selectable_column
    id_column
    column :name
    column :firm
    column :slug
    column "Positions" do |fund|
      fund.positions.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :firm
  filter :slug
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :firm
      row :slug
      row :created_at
      row :updated_at
    end

    panel "Fund Summary" do
      table do
        tr do
          td "Initial Fund Size"
          th number_to_currency(fund.initial_capital / 100.0, precision: 0)
        end
        tr do
          td "Capital Deployed"
          th number_to_currency(fund.deployed_capital / 100.0, precision: 0)
          td "#{number_to_percentage(fund.deployment_rate * 100, precision: 0)}"
        end
        tr do
          td "Capital Returned"
          th number_to_currency(fund.returned_capital / 100.0, precision: 0)
        end
        tr do
          td "Open Position Value"
          th number_to_currency(fund.asset_value / 100.0, precision: 0)
        end
        tr do
          td "Current Gross"
          th number_to_currency(fund.gross_capital / 100.0, precision: 0)
          td do
            multiple = fund.gross_multiple
            if multiple >= 1.0
              content_tag :span, "#{number_with_precision(multiple, precision: 2)}x", class: "status_tag positive"
            else
              content_tag :span, "#{number_with_precision(multiple, precision: 2)}x", class: "status_tag negative"
            end
          end
        end
      end
    end

     panel "Open Positions" do
       table_for fund.positions.open.includes(:company) do
         column("Company") do |position|
           content = link_to position.company.name, admin_company_path(position.company)
           if position.is_new?
             content += content_tag(:span, " New", class: "status_tag info")
           end
           content.html_safe
         end
         column("Original Investment") { |position| number_to_currency(position.invested_capital / 100.0) if position.invested_capital }
         column("Current Gross") { |position| number_to_currency(position.gross_capital / 100.0) }
         column("Gross Multiple") do |position|
           multiple = position.gross_multiple
           if multiple >= 1.0
             content_tag :span, "#{number_with_precision(multiple, precision: 2)}x", class: "status_tag positive"
           else
             content_tag :span, "#{number_with_precision(multiple, precision: 2)}x", class: "status_tag negative"
           end
         end
         column("Stage") { |position| position.company.current_stage_display }
         column("Performance") do |position|
           performance = position.company.current_performance
           case performance&.to_s
           when "HIGH"
             content_tag :span, position.company.current_performance_display, class: "status_tag positive"
           when "ABOVE"
             content_tag :span, position.company.current_performance_display, class: "status_tag positive"
           when "AVERAGE"
             content_tag :span, position.company.current_performance_display, class: "status_tag"
           when "BELOW"
             content_tag :span, position.company.current_performance_display, class: "status_tag negative"
           else
             position.company.current_performance_display
           end
         end
       end
     end

    panel "Closed Positions" do
      table_for fund.positions.closed.includes(:company) do
        column("Company") { |position| link_to position.company.name, admin_company_path(position.company) }
        column("Invested Capital") { |position| number_to_currency(position.invested_capital / 100.0) if position.invested_capital }
        column("Returned Capital") { |position| number_to_currency(position.returned_capital / 100.0) if position.returned_capital }
        column("Return multiple") { |position| number_to_percentage(position.returned_capital / position.invested_capital * 100, precision: 0) if position.returned_capital }
      end
    end

    panel "Transactions" do
      table_for fund.fund_investor_transactions.where(status: :COMPLETE) do
        column("ID") { |transaction| transaction.id }
        column("Date") { |transaction| transaction.date }
        column("Amount") { |transaction| number_to_currency(transaction.amount) if transaction.amount }
        column("Notes") { |transaction| transaction.name }
      end
    end

    panel "Documents" do
      table_for fund.documents.order(date: :desc) do
        column :name
        column :date
        column :file do |document|
          filename = document.file.filename.to_s rescue "Unknown file"
          if document.file.attached?
            div do
              link_to filename, rails_blob_path(document.file, disposition: "attachment"), class: "button"
            end
          else
            "No file attached"
          end
        end
      end
    end
  end

  form do |f|
    f.inputs "Fund Details" do
      f.input :name
      f.input :firm_account, as: :select, collection: FirmAccount.all.order(:name)
      f.input :slug
    end

    f.actions
  end
end
