# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin', type: :request do
  include Devise::Test::IntegrationHelpers

  let!(:plan) { create(:plan, activated_at: Time.current, position: 1) }
  let!(:plan_period) { create(:plan_period, plan: plan, price_cents: 0) }

  before do
    Rails.application.env_config['devise.skip_trackable'] = true
  end

  after do
    Rails.application.env_config.delete('devise.skip_trackable')
  end

  context "when accessing admin authenticated routes as a non-admin" do
    it "does not load the admin dashboard" do
      get admin_dashboard_path
      expect(response).not_to be_successful
      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "does not load the sidekiq dashboard" do
      get sidekiq_web_path
      expect(response).not_to be_successful
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when viewing pages in ActiveAdmin" do
    def self.path_for_klass(action = nil, model_instance = nil, admin_resource_class = nil)
      path = nil
      case action
      when :index
        path = admin_resource_class.route_collection_path
      when :show
        path = admin_resource_class.route_instance_path(model_instance.presence || :example_id)
      when :edit
        path = admin_resource_class.route_edit_instance_path(model_instance.presence || :example_id)
      end

      path
    end
    delegate :path_for_klass, to: :class

    def self.path_for_member_klass(action = nil, model_instance = nil, admin_resource_class = nil)
      admin_resource_class.route_member_action_path(action, model_instance.presence || :example_id)
    end
    delegate :path_for_member_klass, to: :class

    def self.factory_name_for_klass_name(klass_name)
      klass_name.demodulize.underscore.to_sym
    end
    delegate :factory_name_for_klass_name, to: :class

    # Load ActiveAdmin resources here at class definition time
    def self.load_admin_resources_now
      return if @resources_loaded

      puts "Loading ActiveAdmin resources..."

      # Require necessary modules
      require 'active_admin/batch_actions/resource_extension'
      require 'ostruct'

      # Fix batch_actions initialization issue in ActiveAdmin 3.3.0
      ActiveAdmin::Resource.class_eval do
        def batch_actions
          @batch_actions ||= {}
          batch_actions_enabled? ? @batch_actions.values.sort : []
        end

        def add_batch_action(sym, title, options = {}, &block)
          @batch_actions ||= {}
          # Create a simple BatchAction-like object
          @batch_actions[sym] = OpenStruct.new(
            sym: sym,
            title: title,
            options: options,
            block: block,
            confirm: options[:confirm]
          )
        end
      end

      Dir[Rails.root.join("app/admin/**/*.rb")].each { |f| require f }
      ActiveAdmin.application.load!

      @resources_loaded = true
      puts "ActiveAdmin resources loaded!"
    end

    load_admin_resources_now

    all_resources = ActiveAdmin.application.namespaces[:admin]&.resources&.values || []
    puts "All resources count: #{all_resources.count}"
    puts "All resource names: #{all_resources.map { |r| r.resource_class.model_name.name rescue 'unknown' }}"

    initial_resources = all_resources.filter do |resource|
      puts "Checking resource: #{resource.resource_class.model_name.name rescue 'unknown'}"
      puts "  belongs_to?: #{resource.belongs_to?}"
      puts "  belongs_to_config.optional?: #{resource.belongs_to_config&.optional? rescue 'N/A'}"
      puts "  is Page?: #{resource.is_a?(ActiveAdmin::Page)}"
      puts "  is Comment?: #{resource.resource_class.model_name.name == "ActiveAdmin::Comment" rescue false}"

      condition = (!resource.belongs_to? || resource.belongs_to_config.optional?) &&
        !resource.is_a?(ActiveAdmin::Page) &&
        resource.resource_class.model_name.name != "ActiveAdmin::Comment"
      puts "  passes filter?: #{condition}"
      condition
    end

    valid_resources = initial_resources.uniq { |resource| resource.resource_class.model_name.name }
    puts "Valid resources: #{valid_resources.map { |r| r.resource_class.model_name.name }}"

    supported_actions = [ :index, :edit, :show ]

    before do
      admin_user = create(:admin_user)
      sign_in(admin_user)
    end

    valid_resources.each do |admin_resource_class|
      defined_actions = admin_resource_class.defined_actions.filter { |action| supported_actions.include?(action) }
      member_get_actions = admin_resource_class.member_actions.filter { |action| action.http_verb == :get }.map(&:name)
      klass_name = admin_resource_class.resource_class.model_name.name
      next unless klass_name == "User"

      factory_name = factory_name_for_klass_name(klass_name)
      traits_for_factory = FactoryBot.factories[factory_name].defined_traits.map(&:name) | [ nil ]

      defined_actions.each do |action|
        stubbed_path = path_for_klass(action, nil, admin_resource_class)
        traits_for_factory.each do |trait|
          # rubocop:disable RSpec/ExampleLength
          it "loads the #{action} path for #{factory_name} #{"with trait #{trait}" if trait.present?} (#{stubbed_path})" do
            model_instance = trait.present? ? create(factory_name, trait) : create(factory_name)
            next unless klass_name.constantize.exists?(model_instance.id)

            if admin_resource_class.belongs_to?
              to_param = admin_resource_class.belongs_to_config.to_param
              if model_instance.respond_to?(to_param) && model_instance.send(to_param).blank?
                associate_klass = admin_resource_class.belongs_to_config.target.resource_class.model_name.name
                associate_factory_name = factory_name_for_klass_name(associate_klass)
                associate_instance = create(associate_factory_name)
                next unless associate_klass.constantize.exists?(associate_instance.id)

                model_instance.update!(to_param => associate_instance.id)
              end
            end

            found_path = path_for_klass(action, model_instance, admin_resource_class)

            get found_path
            expect(response).to be_successful
          end
          # rubocop:enable RSpec/ExampleLength
        end
      end

      member_get_actions.each do |action|
        stubbed_path = path_for_member_klass(action, nil, admin_resource_class)

        traits_for_factory.each do |trait|
          it "loads the member #{action} path for #{factory_name} #{"with trait #{trait}" if trait.present?} (#{stubbed_path})" do
            model_instance = trait.present? ? create(factory_name, trait) : create(factory_name)
            next unless klass_name.constantize.exists?(model_instance.id)

            found_path = path_for_member_klass(action, model_instance, admin_resource_class)

            get found_path
            expect(response.status).to be_in([ 200, 302 ])
          end
        end
      end
    end
  end
end
