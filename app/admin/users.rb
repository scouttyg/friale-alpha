ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :first_name, :last_name,
                :confirmed_at, :confirmation_sent_at

  index do
    selectable_column
    id_column
    column :email
    column :full_name
    column :status do |user|
      if user.confirmed_at?
        status_tag "Confirmed", class: :ok
      else
        status_tag "Unconfirmed", class: :warning
      end
    end
    column :accounts_count do |user|
      user.accounts.count
    end
    column :notifications_count do |user|
      user.notifications.count
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :first_name
  filter :last_name
  filter :confirmed_at
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :full_name
      row :display_name
      row :initials
      row :status do |user|
        if user.confirmed_at?
          status_tag "Confirmed", class: :ok
        else
          status_tag "Unconfirmed", class: :warning
        end
      end
      row :confirmed_at
      row :confirmation_sent_at
      row :unconfirmed_email
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :sign_in_count
      row :remember_created_at
      row :reset_password_sent_at
      row :created_at
      row :updated_at
    end

    panel "Avatar" do
      if user.avatar.attached?
        image_tag user.avatar, style: "max-width: 200px; max-height: 200px;"
      else
        para "No avatar uploaded"
      end
    end

    panel "Accounts" do
      table_for user.accounts do
        column :id
        column :name
        column :type
        column :role do |account|
          member = user.account_members.find_by(source: account)
          member&.access_level&.humanize
        end
        column :created_at
        column :actions do |account|
          link_to "View", admin_account_path(account), class: "button"
        end
      end
    end

    panel "Personal Account" do
      if user.personal_account
        attributes_table_for user.personal_account do
          row :id
          row :name
          row :slug
          row :subscription do |account|
            account.subscription&.plan&.name
          end
          row :actions do |account|
            link_to "View", admin_account_path(account), class: "button"
          end
        end
      else
        para "No personal account found"
      end
    end

    panel "Notifications" do
      table_for user.notifications.recent.limit(10) do
        column :id
        column :title
        column :status do |notification|
          if notification.read?
            status_tag "Read", class: :ok
          else
            status_tag "Unread", class: :warning
          end
        end
        column :created_at
        column :actions do |notification|
          link_to "View", admin_notification_path(notification), class: "button"
        end
      end
      if user.notifications.count > 10
        para link_to "View all #{user.notifications.count} notifications", admin_notifications_path(q: { user_id_eq: user.id })
      end
    end

    panel "Push Subscriptions" do
      table_for user.push_subscriptions do
        column :id
        column :vendor
        column :status do |ps|
          if ps.active?
            status_tag "Active", class: :ok
          else
            status_tag "Expired", class: :error
          end
        end
        column :created_at
        column :actions do |ps|
          link_to "View", admin_push_subscription_path(ps), class: "button"
        end
      end
    end

    panel "Actions" do
      if !resource.confirmed_at?
        link_to "Confirm User", confirm_admin_user_path(resource), method: :patch, class: "button"
      end
      if resource.confirmed_at?
        link_to "Unconfirm User", unconfirm_admin_user_path(resource), method: :patch, class: "button", confirm: "Are you sure?"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :password
      f.input :password_confirmation
      f.input :confirmed_at, as: :datetime_picker
      f.input :confirmation_sent_at, as: :datetime_picker
    end
    f.actions
  end

  member_action :confirm, method: :patch do
    resource.update!(confirmed_at: Time.current)
    redirect_to admin_user_path(resource), notice: "User confirmed"
  end

  member_action :unconfirm, method: :patch do
    resource.update!(confirmed_at: nil)
    redirect_to admin_user_path(resource), notice: "User unconfirmed"
  end

  scope :all, default: true
  scope :confirmed
  scope :unconfirmed
end
