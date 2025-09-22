ActiveAdmin.register PlanPeriod do
  menu parent: "Plans"

  permit_params :plan_id, :interval, :price_cents, :price_currency, :stripe_price_id

  index do
    selectable_column
    id_column
    column :plan do |pp|
      link_to pp.plan.name, admin_plan_path(pp.plan)
    end
    column :interval
    column :price do |pp|
      pp.price.format
    end
    column :price_currency
    column :stripe_price_id
    column :subscriptions_count do |pp|
      PlanPeriod.joins(:plan).joins("LEFT JOIN subscriptions ON subscriptions.plan_period_id = plan_periods.id")
                 .where(id: pp.id).count
    end
    column :created_at
    actions
  end

  filter :plan, as: :select, collection: -> { Plan.all.map { |p| [ p.name, p.id ] } }
  filter :interval, as: :select, collection: -> { PlanPeriod.intervals.keys.map { |key| [ key.humanize, key ] } }
  filter :price_cents
  filter :price_currency
  filter :stripe_price_id
  filter :created_at

  show do
    attributes_table do
      row :id
      row :plan do |pp|
        link_to pp.plan.name, admin_plan_path(pp.plan)
      end
      row :interval
      row :price do |pp|
        pp.price.format
      end
      row :price_cents
      row :price_currency
      row :stripe_price_id
      row :created_at
      row :updated_at
    end

    panel "Associated Subscriptions" do
      subscriptions = Subscription.where(plan_period: resource)
      if subscriptions.any?
        table_for subscriptions do
          column :id
          column :account do |sub|
            link_to sub.account.name, admin_account_path(sub.account)
          end
          column :created_at
          column :actions do |sub|
            link_to "View", admin_subscription_path(sub), class: "button"
          end
        end
      else
        para "No subscriptions using this plan period"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :plan, as: :select, collection: Plan.all.map { |p| [ p.name, p.id ] }
      f.input :interval, as: :select, collection: PlanPeriod.intervals.keys.map { |key| [ key.humanize, key ] }
      f.input :price_cents, label: "Price (in cents)"
      f.input :price_currency
      f.input :stripe_price_id
    end
    f.actions
  end
end
