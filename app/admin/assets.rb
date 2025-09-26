ActiveAdmin.register Asset do
  menu parent: "Positions"

  permit_params :position_id, :converted_asset_id, :asset_type, :origination,
                :quantity, :current, :cap, :discount

  index do
    selectable_column
    id_column
    column "Company" do |asset|
      link_to asset.company.name, admin_company_path(asset.company)
    end
    column "Position" do |asset|
      link_to "#{asset.position.fund.name} Position", admin_position_path(asset.position)
    end
    column :asset_type
    column :origination
    column :quantity
    column :current
    column "Cap" do |asset|
      number_to_currency(asset.cap / 100.0) if asset.cap
    end
    column "Marks" do |asset|
      asset.marks.count
    end
    actions
  end

  filter :company
  filter :position
  filter :asset_type, as: :select, collection: Asset.asset_types.map { |key, value| [ key.humanize, value ] }, include_blank: "Any"
  filter :origination, as: :select, collection: Asset.originations.map { |key, value| [ key.humanize, value ] }, include_blank: "Any"
  filter :current
  filter :created_at

  show do
    attributes_table do
      row :id
      row("Company") { link_to asset.company.name, admin_company_path(asset.company) }
      row("Position") { link_to "#{asset.position.fund.name} Position", admin_position_path(asset.position) }
      row("Converted From") { link_to "Asset ##{asset.converted_asset.id}", admin_asset_path(asset.converted_asset) if asset.converted_asset }
      row :asset_type
      row :origination
      row :quantity
      row :current
      row("Cap") { number_to_currency(asset.cap / 100.0) if asset.cap }
      row("Discount") { number_to_currency(asset.discount / 100.0) if asset.discount }
      row :created_at
      row :updated_at
    end

    panel "Marks" do
      table_for asset.marks do
        column("Mark") { |mark| link_to "Mark #{mark.mark_date}", admin_mark_path(mark) }
        column :mark_date
        column("Price") { |mark| number_to_currency(mark.price) if mark.price }
        column :source
        column :notes
      end
    end
  end

  form do |f|
    f.inputs "Asset Details" do
      f.input :position, as: :select, collection: Position.includes(:company, :fund).map { |p| [ "#{p.company.name} in #{p.fund.name}", p.id ] }
      f.input :converted_asset, as: :select, collection: Asset.includes(:company).map { |a| [ "Asset ##{a.id} (#{a.company.name})", a.id ] }, include_blank: true
      f.input :asset_type, as: :select, collection: Asset.asset_types.keys.map { |key| [ key.humanize, key ] }
      f.input :origination, as: :select, collection: Asset.originations.keys.map { |key| [ key.humanize, key ] }
      f.input :quantity
      f.input :current
      f.input :cap, label: "Cap (in cents)"
      f.input :discount, label: "Discount (in cents)"
    end

    f.actions
  end
end
