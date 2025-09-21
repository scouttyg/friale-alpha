ActiveAdmin.register Plan do
  permit_params :name, :description, :position, :activated_at, :deactivated_at, :stripe_product_id,
                :member_limit

  index do
    selectable_column
    id_column
    column :name
    column :description, sortable: false do |plan|
      truncate(plan.description, length: 100) if plan.description
    end
    column :position
    column :status do |plan|
      if plan.active?
        status_tag "Active", class: :ok
      elsif plan.activated? && plan.deactivated?
        status_tag "Deactivated", class: :error
      elsif !plan.activated?
        status_tag "Not Activated", class: :warning
      else
        status_tag "Unknown", class: :error
      end
    end
    column :member_limit
    column :plan_periods_count do |plan|
      plan.plan_periods.count
    end
    column :subscriptions_count do |plan|
      plan.subscriptions.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :description
  filter :position
  filter :activated_at
  filter :deactivated_at
  filter :stripe_product_id
  filter :member_limit
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :position
      row :status do |plan|
        if plan.active?
          status_tag "Active", class: :ok
        elsif plan.activated? && plan.deactivated?
          status_tag "Deactivated", class: :error
        elsif !plan.activated?
          status_tag "Not Activated", class: :warning
        else
          status_tag "Unknown", class: :error
        end
      end
      row :activated_at
      row :deactivated_at
      row :stripe_product_id
      row :member_limit
      row :usage_limits do |plan|
        if plan.usage_limits.present?
          pre JSON.pretty_generate(plan.usage_limits)
        else
          "None"
        end
      end
      row :created_at
      row :updated_at
    end

    panel "Plan Periods" do
      table_for plan.plan_periods do
        column :id
        column :interval
        column :price do |pp|
          pp.price.format
        end
        column :stripe_price_id
        column :created_at
        column :actions do |pp|
          link_to "View", admin_plan_period_path(pp), class: "button"
        end
      end
    end

    panel "Subscriptions" do
      table_for plan.subscriptions do
        column :id
        column :account do |sub|
          link_to sub.account.name, admin_account_path(sub.account)
        end
        column :plan_period do |sub|
          sub.plan_period.name
        end
        column :created_at
        column :actions do |sub|
          link_to "View", admin_subscription_path(sub), class: "button"
        end
      end
    end

    panel "Actions" do
      if !resource.activated?
        link_to "Activate", activate_admin_plan_path(resource), method: :patch, class: "button"
      end
      if resource.activated? && !resource.deactivated?
        link_to "Deactivate", deactivate_admin_plan_path(resource), method: :patch, class: "button", confirm: "Are you sure?"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description, as: :text
      f.input :position
      f.input :activated_at, as: :datetime_picker
      f.input :deactivated_at, as: :datetime_picker
      f.input :stripe_product_id
      f.input :member_limit
    end
    f.actions
  end

  member_action :activate, method: :patch do
    resource.activate!
    redirect_to admin_plan_path(resource), notice: "Plan activated"
  end

  member_action :deactivate, method: :patch do
    resource.deactivate!
    redirect_to admin_plan_path(resource), notice: "Plan deactivated"
  end
end
