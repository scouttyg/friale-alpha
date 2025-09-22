# frozen_string_literal: true

# This concern customizes PaperTrail's version tracking behavior based on user types:
#
# 1. Admin Users: Changes are always tracked to maintain audit logs of administrative actions
# 2. Regular Users: Changes are tracked only when either:
#    - The changed attributes match those specified in the `only` option
#    - The `admin_only` option is not set to true
#
# This approach helps manage database growth by selectively tracking changes while ensuring audit trails for administrative actions.
module AdminUserPaperTrail
  extend ActiveSupport::Concern

  included do
    class_eval do
      class_attribute :original_paper_trail_options

      # This is the name of the method I want to override. Can't change it
      # rubocop:disable Naming/PredicateName
      def self.has_paper_trail(options = {})
        self.original_paper_trail_options = options

        admin_options = {
          if: proc do |model|
            whodunnit_type = PaperTrail.request.controller_info&.dig(:whodunnit_type)

            if whodunnit_type == AdminUser::PAPER_TRAIL_WHODUNNIT_TYPE
              true
            elsif original_paper_trail_options[:only].present?
              model.saved_changes.keys.intersect?(original_paper_trail_options[:only].map(&:to_s))
            else
              !options[:admin_only]
            end
          end
        }

        super(options.except(:only, :admin_only).merge(admin_options))
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
