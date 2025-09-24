ActiveAdmin.register Account do
  permit_params :name, :type, :stripe_customer_id

  index do
    selectable_column
    id_column
    column :name
    column :type
    column :slug
    column :owner do |account|
      account.owner&.display_name
    end
    column :members_count do |account|
      account.members.count
    end
    column :subscription do |account|
      account.subscription&.plan&.name
    end
    column "Stripe Customer ID", :stripe_customer_id
    column :created_at
    actions
  end

  filter :name
  filter :type, as: :select, collection: -> { Account.distinct.pluck(:type).compact }
  filter :slug
  filter :stripe_customer_id, label: "Stripe Customer ID"
  filter :created_at

  show do
    attributes_table do
      row :id
      row :name
      row :type
      row :slug
      row ("Stripe Customer ID") { |account| account.stripe_customer_id }
      row :created_at
      row :updated_at
    end

    panel "Owner" do
      attributes_table_for account.owner do
        row :id
        row :email
        row :full_name
        row :created_at
      end
    end if account.owner

    panel "Members" do
      table_for account.members do
        column :id
        column :user do |member|
          member.user&.display_name || member.invite_email
        end
        column :access_level
        column :invite_email
        column :created_at
        column :actions do |member|
          link_to "View", admin_member_path(member), class: "button"
        end
      end
    end

    panel "Subscription" do
      attributes_table_for account.subscription do
        row :id
        row :plan do |sub|
          sub.plan&.name
        end
        row :plan_period do |sub|
          sub.plan_period&.name
        end
        row :created_at
      end
    end if account.subscription

    panel "Payment Methods" do
      table_for account.payment_methods do
        column :id
        column :type
        column :brand
        column :last_four
        column :default
        column :created_at
        column :actions do |pm|
          link_to "View", admin_payment_method_path(pm), class: "button"
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :type, as: :select, collection: [ "Account", "PersonalAccount" ]
      f.input :stripe_customer_id, label: "Stripe Customer ID", placeholder: "cus_..."
    end
    f.actions
  end
end
