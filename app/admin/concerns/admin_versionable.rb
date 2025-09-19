# frozen_string_literal: true

module AdminVersionable
  class VersionAuthor
    def initialize(version)
      @version = version
    end

    def author_type
      return "No author information" if no_author?
      return "User" if user?

      "Admin User"
    end

    def email
      return "N/A" if no_author?

      author.email
    end

    def author
      return User.find(@version.whodunnit) if user?

      AdminUser.find(@version.whodunnit) if admin_user?
    end

    def no_author?
      @version.whodunnit.nil?
    end

    def user?
      @version.whodunnit_type == "User"
    end

    def admin_user?
      @version.whodunnit_type == "AdminUser"
    end
  end

  def self.extended(base)
    base.instance_eval do
      sidebar :version, partial: "admin/shared/paper_trail/version", only: :show

      before_action :initialize_versions, only: :show

      controller do
        def initialize_versions
          @resource = resource_class.includes(versions: :item).friendly.find(params[:id])
          @versions = @resource.versions
          @latest_version = @versions.last
          @latest_version_author = VersionAuthor.new(@latest_version)
          @previous_version = @versions.size <= 1 ? nil : @versions.last(2).first

          return if params[:version].nil?

          version_number = params[:version].to_i
          @current_version = @versions.find(version_number)
          @resource = @current_version.reify
          @current_version_author = VersionAuthor.new(@current_version)

          current_version_index = @versions.find_index(@current_version)
          @previous_version = current_version_index.zero? ? nil : @versions[current_version_index - 1]
        end
      end
    end
  end
end
