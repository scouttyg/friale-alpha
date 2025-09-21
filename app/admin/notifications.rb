ActiveAdmin.register Notification do
  menu parent: "Users"

  permit_params :title, :body, :user_id

  index do
    selectable_column
    id_column
    column :title
    column :body, sortable: false do |notification|
      truncate(notification.body, length: 100)
    end
    column :user do |notification|
      link_to notification.user.display_name, admin_user_path(notification.user)
    end
    column :status do |notification|
      if notification.read?
        status_tag "Read", class: :ok
      else
        status_tag "Unread", class: :warning
      end
    end
    column :read_at
    column :created_at
    actions
  end

  filter :title
  filter :body
  filter :user, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }
  filter :read_at
  filter :created_at

  show do
    attributes_table do
      row :id
      row :title
      row :body
      row :user do |notification|
        link_to notification.user.display_name, admin_user_path(notification.user)
      end
      row :status do |notification|
        if notification.read?
          status_tag "Read", class: :ok
        else
          status_tag "Unread", class: :warning
        end
      end
      row :read_at
      row :created_at
      row :updated_at
    end

    panel "Actions" do
      if resource.unread?
        link_to "Mark as Read", mark_as_read_admin_notification_path(resource), method: :patch, class: "button"
      else
        link_to "Mark as Unread", mark_as_unread_admin_notification_path(resource), method: :patch, class: "button"
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :body, as: :text
      f.input :user, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }
    end
    f.actions
  end

  member_action :mark_as_read, method: :patch do
    resource.mark_as_read!
    redirect_to admin_notification_path(resource), notice: "Notification marked as read"
  end

  member_action :mark_as_unread, method: :patch do
    resource.mark_as_unread!
    redirect_to admin_notification_path(resource), notice: "Notification marked as unread"
  end
end
