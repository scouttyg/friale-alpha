ActiveAdmin.register Subscription do
  menu parent: "Plans"

  permit_params :account_id, :plan_id, :plan_period_id, :stripe_subscription_id

  index do
    selectable_column
    id_column
    column :account do |sub|
      link_to sub.account.name, admin_account_path(sub.account)
    end
    column :plan do |sub|
      link_to sub.plan.name, admin_plan_path(sub.plan)
    end
    column :plan_period do |sub|
      sub.plan_period.name
    end
    column :price do |sub|
      sub.plan_period.price.format
    end
    column :renewal_date
    column :stripe_subscription_id
    column :created_at
    actions
  end

  filter :account, as: :select, collection: -> { Account.all.map { |a| [ a.name, a.id ] } }
  filter :plan, as: :select, collection: -> { Plan.all.map { |p| [ p.name, p.id ] } }
  filter :plan_period, as: :select, collection: -> { PlanPeriod.joins(:plan).map { |pp| [ "#{pp.plan.name} - #{pp.interval}", pp.id ] } }
  filter :stripe_subscription_id
  filter :created_at

  show do
    attributes_table do
      row :id
      row :account do |sub|
        link_to sub.account.name, admin_account_path(sub.account)
      end
      row :plan do |sub|
        link_to sub.plan.name, admin_plan_path(sub.plan)
      end
      row :plan_period do |sub|
        link_to sub.plan_period.name, admin_plan_period_path(sub.plan_period)
      end
      row :price do |sub|
        sub.plan_period.price.format
      end
      row :renewal_date
      row :stripe_subscription_id
      row :usage_limits do |sub|
        if sub.usage_limits.present?
          pre JSON.pretty_generate(sub.usage_limits)
        else
          "None"
        end
      end
      row :created_at
      row :updated_at
    end

    panel "Account Details" do
      attributes_table_for subscription.account do
        row :id
        row :name
        row :type
        row :owner do |account|
          account.owner&.display_name
        end
        row :members_count do |account|
          account.members.count
        end
        row :stripe_customer_id
        row :actions do |account|
          link_to "View Account", admin_account_path(account), class: "button"
        end
      end
    end

    panel "Plan Details" do
      attributes_table_for subscription.plan do
        row :id
        row :name
        row :description
        row :status do |plan|
          if plan.active?
            status_tag "Active", :ok
          else
            status_tag "Inactive", :error
          end
        end
        row :member_limit
        row :actions do |plan|
          link_to "View Plan", admin_plan_path(plan), class: "button"
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :account, as: :select, collection: -> { Account.all.map { |a| [ a.name, a.id ] } }
      f.input :plan, as: :select, collection: -> { Plan.all.map { |p| [ p.name, p.id ] } }
      f.input :plan_period, as: :select, collection: -> { PlanPeriod.joins(:plan).map { |pp| [ "#{pp.plan.name} - #{pp.interval} (#{pp.price.format})", pp.id ] } }
      f.input :stripe_subscription_id
    end
    f.actions
  end
end
