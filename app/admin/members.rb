ActiveAdmin.register Member do
  menu parent: "Accounts"

  permit_params :access_level, :invite_email, :source_type, :source_id, :user_id, :creator_id

  index do
    selectable_column
    id_column
    column :type
    column :user do |member|
      member.user&.display_name || member.invite_email
    end
    column :source do |member|
      case member.source_type
      when "Account"
        link_to member.source.name, admin_account_path(member.source)
      else
        "#{member.source_type} ##{member.source_id}"
      end
    end
    column :access_level
    column :invite_email
    column :status do |member|
      if member.pending?
        status_tag "Pending", class: :warning
      elsif member.accepted?
        status_tag "Accepted", class: :ok
      else
        status_tag "Unknown", class: :error
      end
    end
    column :created_at
    actions
  end

  filter :type, as: :select, collection: -> { Member.distinct.pluck(:type).compact }
  filter :access_level, as: :select, collection: Member::ACCESS_LEVELS.keys.map { |key| [ key.to_s.humanize, key ] }
  filter :source_type, as: :select, collection: -> { Member.distinct.pluck(:source_type).compact }
  filter :invite_email
  filter :created_at
  filter :user, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }

  show do
    attributes_table do
      row :id
      row :type
      row :access_level
      row :source_type
      row :source_id
      row :source do |member|
        case member.source_type
        when "Account"
          link_to member.source.name, admin_account_path(member.source)
        else
          "#{member.source_type} ##{member.source_id}"
        end
      end
      row :user do |member|
        if member.user
          link_to member.user.display_name, admin_user_path(member.user)
        else
          "None"
        end
      end
      row :creator do |member|
        if member.creator
          link_to member.creator.display_name, admin_user_path(member.creator)
        else
          "None"
        end
      end
      row :invite_email
      row :invite_token
      row :status do |member|
        if member.pending?
          status_tag "Pending", :warning
        elsif member.accepted?
          status_tag "Accepted", :ok
        else
          status_tag "Unknown", :error
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :access_level, as: :select, collection: Member::ACCESS_LEVELS.keys.map { |key| [ key.humanize, key ] }
      f.input :invite_email
      f.input :source_type, as: :select, collection: [ "Account" ]
      f.input :source_id, as: :select, collection: -> { Account.all.map { |a| [ a.name, a.id ] } }
      f.input :user, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }, include_blank: true
      f.input :creator, as: :select, collection: -> { User.all.map { |u| [ u.display_name, u.id ] } }, include_blank: true
    end
    f.actions
  end
end
