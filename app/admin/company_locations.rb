ActiveAdmin.register CompanyLocation do
  menu parent: "Companies"

  permit_params :company_id, :location_id

  index do
    selectable_column
    id_column
    column "Company" do |cl|
      link_to cl.company.name, admin_company_path(cl.company)
    end
    column "Location" do |cl|
      location_display = [ cl.location.city, cl.location.region, cl.location.country ].compact.join(", ")
      link_to location_display, admin_location_path(cl.location)
    end
    column "Firm Account" do |cl|
      cl.company.firm_account.name
    end
    column :created_at
    actions
  end

  filter :company
  filter :location
  filter :created_at

  show do
    attributes_table do
      row :id
      row("Company") { link_to company_location.company.name, admin_company_path(company_location.company) }
      row("Location") do
        location_display = [ company_location.location.city, company_location.location.region, company_location.location.country ].compact.join(", ")
        link_to location_display, admin_location_path(company_location.location)
      end
      row("Firm Account") { company_location.company.firm_account.name }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Company Location Details" do
      f.input :company, as: :select, collection: Company.all.order(:name).map { |c| [ "#{c.name} (#{c.firm_account.name})", c.id ] }
      f.input :location, as: :select, collection: Location.all.order(:country, :region, :city).map { |l| [ [ l.city, l.region, l.country ].compact.join(", "), l.id ] }
    end

    f.actions
  end
end
