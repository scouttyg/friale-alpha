ActiveAdmin.register Company do
  menu priority: 5

  permit_params :name, :website, :description, :firm_account_id, location_ids: []

  index do
    selectable_column
    id_column
    column :name
    column :firm_account
    column :website do |company|
      link_to company.website, company.website, target: "_blank", rel: "noopener noreferrer"
    end
    column "Locations" do |company|
      company.locations.map { |loc| link_to(loc.full_name, admin_location_path(loc)) }.join(" | ").html_safe
    end
    column "Positions" do |company|
      company.positions.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :firm_account
  filter :website
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :firm_account
      row :website do |company|
        link_to company.website, company.website, target: "_blank", rel: "noopener noreferrer"
      end
      row :description
      row :created_at
      row :updated_at
    end

    panel "Locations" do
      table_for company.locations do
        column("Location") { |location| link_to [ location.city, location.region, location.country ].compact.join(", "), admin_location_path(location) }
        column :city
        column :region
        column :country
      end
    end

    panel "Positions" do
      table_for company.positions.includes(:fund) do
        column("Fund") { |position| link_to position.fund.name, admin_fund_path(position.fund) }
        column("Invested Capital") { |position| number_to_currency(position.invested_capital / 100.0) if position.invested_capital }
        column("Returned Capital") { |position| number_to_currency(position.returned_capital / 100.0) if position.returned_capital }
        column :open_date
        column :close_date
      end
    end

    panel "Assets" do
      table_for company.assets.includes(:position) do
        column("Position") { |asset| link_to "#{asset.position.fund.name} Position", admin_position_path(asset.position) }
        column :asset_type
        column :quantity
        column :current
        column("Cap") { |asset| number_to_currency(asset.cap / 100.0) if asset.cap }
      end
    end

    panel "Notes" do
      table_for company.company_notes do
        column :active
        column :note
        column :performance
        column :stage
        column :url
      end
    end
  end

  form do |f|
    f.inputs "Company Details" do
      f.input :name
      f.input :firm_account, as: :select, collection: FirmAccount.all.order(:name)
      f.input :website
      f.input :description
    end

    f.inputs "Locations" do
      f.input :locations, as: :check_boxes, collection: Location.all.order(:country, :region, :city).map { |l| [ [ l.city, l.region, l.country ].compact.join(", "), l.id ] }
    end

    f.actions
  end
end
