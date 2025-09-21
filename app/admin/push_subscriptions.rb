ActiveAdmin.register PushSubscription do
  menu parent: "Users"

  permit_params :user_id, :endpoint, :public_key, :auth_secret, :expires_at

  index do
    selectable_column
    id_column
    column :user do |ps|
      link_to ps.user.display_name, admin_user_path(ps.user)
    end
    column :vendor
    column :endpoint, sortable: false do |ps|
      truncate(ps.endpoint, length: 50)
    end
    column :status do |ps|
      if ps.active?
        status_tag "Active", class: :ok
      else
        status_tag "Expired", class: :error
      end
    end
    column :expires_at
    column :created_at
    actions
  end

  filter :user, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }
  filter :endpoint
  filter :expires_at
  filter :created_at

  show do
    attributes_table do
      row :id
      row :user do |ps|
        link_to ps.user.display_name, admin_user_path(ps.user)
      end
      row :vendor
      row :endpoint
      row :public_key
      row :auth_secret
      row :status do |ps|
        if ps.active?
          status_tag "Active", class: :ok
        else
          status_tag "Expired", class: :error
        end
      end
      row :expires_at
      row :created_at
      row :updated_at
    end

    panel "Vendor Information" do
      attributes_table_for resource do
        row "Detected Vendor" do |ps|
          status_tag ps.vendor.to_s.humanize, class: (ps.vendor == :unknown ? :error : :ok)
        end
        row "Valid Domains" do
          ul do
            PushSubscription::VALID_PUSH_DOMAINS_HASH.each do |domain, vendor|
              li "#{domain} (#{vendor.to_s.humanize})"
            end
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :user, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }
      f.input :endpoint, hint: "Must be from a valid push service domain"
      f.input :public_key
      f.input :auth_secret
      f.input :expires_at, as: :datetime_picker
    end
    f.actions
  end

  scope :all, default: true
  scope :active
  scope :expired
end
