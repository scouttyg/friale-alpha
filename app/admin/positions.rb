ActiveAdmin.register Position do
  menu priority: 8

  permit_params :company_id, :fund_id, :invested_capital, :returned_capital, :open_date, :close_date

  index do
    selectable_column
    id_column
    column "Company" do |position|
      link_to position.company.name, admin_company_path(position.company)
    end
    column "Fund" do |position|
      link_to position.fund.name, admin_fund_path(position.fund)
    end
    column "Invested Capital" do |position|
      number_to_currency(position.invested_capital / 100.0) if position.invested_capital
    end
    column "Returned Capital" do |position|
      number_to_currency(position.returned_capital / 100.0) if position.returned_capital
    end
    column :open_date
    column :close_date
    column "Assets" do |position|
      position.assets.count
    end
    actions
  end

  filter :company
  filter :fund
  filter :open_date
  filter :close_date
  filter :created_at

  show do
    attributes_table do
      row :id
      row("Company") { link_to position.company.name, admin_company_path(position.company) }
      row("Fund") { link_to position.fund.name, admin_fund_path(position.fund) }
      row("Invested Capital") { number_to_currency(position.invested_capital / 100.0) if position.invested_capital }
      row("Returned Capital") { number_to_currency(position.returned_capital / 100.0) if position.returned_capital }
      row :open_date
      row :close_date
      row :created_at
      row :updated_at
    end

    panel "Assets" do
      table_for position.assets do
        column("Asset") { |asset| link_to "Asset ##{asset.id}", admin_asset_path(asset) }
        column :asset_type
        column :origination
        column :quantity
        column :current
        column("Cap") { |asset| number_to_currency(asset.cap / 100.0) if asset.cap }
        column("Discount") { |asset| number_to_currency(asset.discount / 100.0) if asset.discount }
      end
    end
  end

  form do |f|
    f.inputs "Position Details" do
      f.input :company, as: :select, collection: Company.all.order(:name).map { |c| [ "#{c.name} (#{c.firm_account.name})", c.id ] }
      f.input :fund, as: :select, collection: Fund.all.order(:name).map { |fund| [ "#{fund.name} (#{fund.firm_account.name})", fund.id ] }
      f.input :invested_capital, label: "Invested Capital (in cents)"
      f.input :returned_capital, label: "Returned Capital (in cents)"
      f.input :open_date, as: :datepicker
      f.input :close_date, as: :datepicker
    end

    f.actions
  end
end
