ActiveAdmin.register Location do
  menu priority: 2

  permit_params :city, :region, :country, :time_zone, :latitude, :longitude, :slug

  index do
    selectable_column
    id_column
    column :city
    column :region
    column :country
    column :slug
    column "Companies" do |location|
      location.companies.count
    end
    column :created_at
    actions
  end

  filter :city
  filter :region
  filter :country
  filter :slug
  filter :created_at

  show do
    attributes_table do
      row :id
      row :city
      row :region
      row :country
      row :time_zone
      row :latitude
      row :longitude
      row :slug
      row :created_at
      row :updated_at
    end

    panel "Associated Companies" do
      table_for location.companies do
        column("Company") { |company| link_to company.name, admin_company_path(company) }
        column("Firm Account") { |company| company.firm_account.name }
        column("Website") { |company| company.website }
      end
    end
  end

  form do |f|
    f.inputs "Location Details" do
      f.input :city
      f.input :region
      f.input :country, as: :select,
              collection: ISO3166::Country.all.sort_by(&:common_name).map { |c| [ c.common_name, c.alpha2 ] },
              include_blank: "Select a country..."
      f.input :time_zone, as: :select, collection: ActiveSupport::TimeZone.all.map { |tz| [ tz.to_s, tz.name ] },
              include_blank: "Select a timezone...", input_html: { class: "select2" }
      f.input :latitude
      f.input :longitude
      f.input :slug
    end

    f.actions
  end
end
