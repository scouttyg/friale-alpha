ActiveAdmin.register FirmAccount do
  menu parent: "Accounts"

  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    column "Funds" do |firm_account|
      firm_account.funds.count
    end
    column "Companies" do |firm_account|
      firm_account.companies.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :created_at
      row :updated_at
    end

    panel "Funds" do
      table_for firm_account.funds do
        column("Fund") { |fund| link_to fund.name, admin_fund_path(fund) }
        column :slug
        column :created_at
      end
    end

    panel "Companies" do
      table_for firm_account.companies do
        column("Company") { |company| link_to company.name, admin_company_path(company) }
        column :website
        column "Locations" do |company|
          company.locations.map(&:city).compact.join(", ")
        end
      end
    end
  end

  form do |f|
    f.inputs "Firm Account Details" do
      f.input :name
    end

    f.actions
  end
end
