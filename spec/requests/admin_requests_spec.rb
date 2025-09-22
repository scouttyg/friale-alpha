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

    supported_actions = [ :index, :edit, :show ]

    before do
      admin_user = create(:admin_user)
      sign_in(admin_user)

      # Load ActiveAdmin resources at runtime, not at class definition time
      # This ensures proper initialization of batch actions and other features
      Dir[Rails.root.join("app/admin/**/*.rb")].each { |f| require f }
      ActiveAdmin.application.load!
    end

    # Get valid resources dynamically after ActiveAdmin has loaded
    def get_valid_resources
      all_resources = ActiveAdmin.application.namespaces[:admin]&.resources&.values || []

      initial_resources = all_resources.filter do |resource|
        (!resource.belongs_to? || resource.belongs_to_config.optional?) &&
          !resource.is_a?(ActiveAdmin::Page) &&
          resource.resource_class.model_name.name != "ActiveAdmin::Comment"
      end

      initial_resources.uniq { |resource| resource.resource_class.model_name.name }
    end

    # Extract error details from better_errors HTML response
    def extract_error_from_html(html_body)
      return nil unless html_body.is_a?(String)

      # Look for better_errors exception header pattern
      if match = html_body.match(/<header class="exception">\s*<h2><strong>([^<]+)<\/strong>\s*<span>at ([^<]+)<\/span><\/h2>\s*<p>([^<]+)<\/p>/m)
        exception_type = decode_html_entities(match[1].strip)
        message = decode_html_entities(match[3].strip)

        # Look for the first application frame (selected frame with application context)
        app_frame_location = extract_application_frame(html_body)
        location_info = app_frame_location || decode_html_entities(match[2].strip)

        "#{exception_type}: #{message} (at #{location_info})"
      elsif match = html_body.match(/<h1>([^<]+)<\/h1>/)
        # Fallback for simpler error pages
        decode_html_entities(match[1].strip)
      else
        nil
      end
    end

    # Extract the first application frame location from better_errors
    def extract_application_frame(html_body)
      # Look for selected application frame (try multiple patterns)
      patterns = [
        # Pattern 1: class="selected" with data-context="application"
        /<li[^>]*class="selected"[^>]*data-context="application"[^>]*>.*?<span class="filename">([^<]+)<\/span>, line <span class="line">([^<]+)<\/span>/m,
        # Pattern 2: data-context="application" with class="selected"
        /<li[^>]*data-context="application"[^>]*class="selected"[^>]*>.*?<span class="filename">([^<]+)<\/span>, line <span class="line">([^<]+)<\/span>/m,
        # Pattern 3: Just look for first application context frame
        /<li[^>]*data-context="application"[^>]*>.*?<span class="filename">([^<]+)<\/span>, line <span class="line">([^<]+)<\/span>/m
      ]

      patterns.each do |pattern|
        if match = html_body.match(pattern)
          filename = decode_html_entities(match[1].strip)
          line = decode_html_entities(match[2].strip)
          return "#{filename}, line #{line}"
        end
      end

      # Debug: if no application frame found, let's see what frames exist
      if Rails.env.test? && html_body.include?('class="filename"')
        puts "DEBUG: Could not find application frame, available frames:"
        html_body.scan(/<span class="filename">([^<]+)<\/span>, line <span class="line">([^<]+)<\/span>/) do |filename, line|
          puts "  - #{decode_html_entities(filename)}, line #{decode_html_entities(line)}"
        end
      end

      nil
    end

    # Decode common HTML entities
    def decode_html_entities(text)
      text.gsub(/&#39;/, "'")
          .gsub(/&quot;/, '"')
          .gsub(/&lt;/, '<')
          .gsub(/&gt;/, '>')
          .gsub(/&amp;/, '&')
    end

    it "loads ActiveAdmin pages for all resources with all traits" do
      valid_resources = get_valid_resources
      failures = []
      total_tests = 0

      valid_resources.each do |admin_resource_class|
        defined_actions = admin_resource_class.defined_actions.filter { |action| supported_actions.include?(action) }
        member_get_actions = admin_resource_class.member_actions.filter { |action| action.http_verb == :get }.map(&:name)
        klass_name = admin_resource_class.resource_class.model_name.name

        factory_name = factory_name_for_klass_name(klass_name)
        traits_for_factory = begin
          FactoryBot.factories[factory_name].defined_traits.map(&:name) | [ nil ]
        rescue KeyError
          [ nil ] # If factory doesn't exist, just test without traits
        end

        defined_actions.each do |action|
          traits_for_factory.each do |trait|
            trait_description = trait ? " with trait :#{trait}" : ""

            puts "Testing: #{klass_name} #{action}#{trait_description}"
            total_tests += 1

            begin
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
              if !response.successful?
                error_details = extract_error_from_html(response.body) if response.status == 500
                error_msg = "#{found_path} (#{action})#{trait_description} for #{klass_name} - Status: #{response.status}"
                error_msg += "\n    #{error_details}" if error_details
                puts "  ❌ FAILED: #{error_msg}"
                failures << error_msg
              else
                puts "  ✅ PASSED: #{found_path}"
              end
            rescue => e
              error_msg = "#{klass_name} #{action}#{trait_description} - #{e.message}"
              puts "  💥 ERROR: #{error_msg}"
              failures << error_msg
            end
          end
        end

        member_get_actions.each do |action|
          traits_for_factory.each do |trait|
            trait_description = trait ? " with trait :#{trait}" : ""

            puts "Testing: #{klass_name} member #{action}#{trait_description}"
            total_tests += 1

            begin
              model_instance = trait.present? ? create(factory_name, trait) : create(factory_name)
              next unless klass_name.constantize.exists?(model_instance.id)

              found_path = path_for_member_klass(action, model_instance, admin_resource_class)

              get found_path
              if !response.status.in?([ 200, 302 ])
                error_details = extract_error_from_html(response.body) if response.status == 500
                error_msg = "#{found_path} (member #{action})#{trait_description} for #{klass_name} - Status: #{response.status}"
                error_msg += "\n    #{error_details}" if error_details
                puts "  ❌ FAILED: #{error_msg}"
                failures << error_msg
              else
                puts "  ✅ PASSED: #{found_path}"
              end
            rescue => e
              error_msg = "#{klass_name} member #{action}#{trait_description} - #{e.message}"
              puts "  💥 ERROR: #{error_msg}"
              failures << error_msg
            end
          end
        end
      end

      puts "\n" + "="*80
      puts "TEST SUMMARY:"
      puts "Total tests run: #{total_tests}"
      puts "Failures: #{failures.count}"
      puts "Success rate: #{((total_tests - failures.count).to_f / total_tests * 100).round(1)}%"

      if failures.any?
        puts "\nFAILED TESTS:"
        failures.each { |failure| puts "  - #{failure}" }
        puts "="*80

        # Fail the test with a summary
        fail "#{failures.count} out of #{total_tests} ActiveAdmin page tests failed. See details above."
      else
        puts "All tests passed! 🎉"
        puts "="*80
      end
    end
  end
end
