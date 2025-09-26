ActiveAdmin.register Mark do
  menu parent: %w[Positions Assets]

  permit_params :asset_id, :mark_date, :price, :source, :notes

  index do
    selectable_column
    id_column
    column "Asset" do |mark|
      if mark.asset
        link_to "Asset ##{mark.asset.id} (#{mark.asset.company.name})", admin_asset_path(mark.asset)
      else
        "No Asset"
      end
    end
    column :mark_date
    column "Price" do |mark|
      number_to_currency(mark.price) if mark.price
    end
    column :source
    column :notes
    column :created_at
    actions
  end

  filter :asset
  filter :mark_date
  filter :price
  filter :source, as: :select, collection: Mark.sources.map { |key, value| [ key.humanize, value ] }, include_blank: "Any"
  filter :created_at

  show do
    attributes_table do
      row :id
      row("Asset") do |mark|
        if mark.asset
          link_to "Asset ##{mark.asset.id} (#{mark.asset.company.name})", admin_asset_path(mark.asset)
        else
          "No Asset"
        end
      end
      row :mark_date
      row("Price") do |mark|
        number_to_currency(mark.price) if mark.price
      end
      row :source
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Mark Details" do
      f.input :asset, as: :select, collection: Asset.includes(:company).map { |a| [ "Asset ##{a.id} (#{a.company.name})", a.id ] }, include_blank: true
      f.input :mark_date, as: :datepicker
      f.input :price
      f.input :source, as: :select, collection: Mark.sources.keys.map { |key| [ key.humanize, key ] }
      f.input :notes
    end

    f.actions
  end
end
