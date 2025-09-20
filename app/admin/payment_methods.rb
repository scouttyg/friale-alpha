ActiveAdmin.register PaymentMethod do
  menu parent: "Accounts"

  permit_params :account_id, :brand, :default, :stripe_payment_method_id, :type

  index do
    selectable_column
    id_column
    column :type
    column :account do |pm|
      link_to pm.account.name, admin_account_path(pm.account)
    end
    column :brand
    column :last_four
    column :default do |pm|
      status_tag pm.default? ? "Yes" : "No", pm.default? ? :ok : nil
    end
    column :stripe_payment_method_id
    column :status do |pm|
      if pm.deleted_at?
        status_tag "Deleted", :error
      else
        status_tag "Active", :ok
      end
    end
    column :created_at
    actions
  end

  filter :type, as: :select, collection: -> { PaymentMethod.distinct.pluck(:type).compact }
  filter :account, as: :select, collection: -> { Account.all.map { |a| [ a.name, a.id ] } }
  filter :brand
  filter :default, as: :select, collection: [ [ "Yes", true ], [ "No", false ] ]
  filter :stripe_payment_method_id
  filter :deleted_at
  filter :created_at

  show do
    attributes_table do
      row :id
      row :type
      row :account do |pm|
        link_to pm.account.name, admin_account_path(pm.account)
      end
      row :brand
      row :last_four
      row :default do |pm|
        status_tag pm.default? ? "Yes" : "No", pm.default? ? :ok : nil
      end
      row :stripe_payment_method_id
      row :status do |pm|
        if pm.deleted_at?
          status_tag "Deleted", :error
        else
          status_tag "Active", :ok
        end
      end
      row :deleted_at
      row :metadata do |pm|
        if pm.metadata.present?
          pre JSON.pretty_generate(pm.metadata)
        else
          "None"
        end
      end
      row :created_at
      row :updated_at
    end

    panel "Actions" do
      if !resource.default? && !resource.deleted_at?
        link_to "Mark as Default", mark_as_default_admin_payment_method_path(resource), method: :patch, class: "button"
      end
      if !resource.deleted_at?
        link_to "Soft Delete", soft_delete_admin_payment_method_path(resource), method: :patch, class: "button", confirm: "Are you sure?"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :account, as: :select, collection: -> { Account.all.map { |a| [ a.name, a.id ] } }
      f.input :type, as: :select, collection: PaymentMethod.descendants.map(&:name)
      f.input :brand
      f.input :default
      f.input :stripe_payment_method_id
    end
    f.actions
  end

  member_action :mark_as_default, method: :patch do
    resource.mark_as_default!
    redirect_to admin_payment_method_path(resource), notice: "Payment method marked as default"
  end

  member_action :soft_delete, method: :patch do
    resource.soft_delete!
    redirect_to admin_payment_method_path(resource), notice: "Payment method deleted"
  end
end
