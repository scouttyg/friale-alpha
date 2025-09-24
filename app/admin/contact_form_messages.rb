ActiveAdmin.register ContactFormMessage do
  permit_params :email, :subject, :message

  index do
    selectable_column
    id_column
    column :email
    column :subject
    column :message
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :subject
      row :message
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :subject
      f.input :message
    end
    f.actions
  end
end
