namespace :factory_bot do
  desc "Verify that all FactoryBot factories are valid"
  task lint: :environment do
    if Rails.env.test?
      require "faker"

      # Earnable factory is abstract and contains traits shared across all earnable factories.
      # The linter would complain that it cannot be initialized.
      factories_to_lint = FactoryBot.factories

      conn = ActiveRecord::Base.connection
      conn.transaction do
        FactoryBot.lint factories_to_lint, traits: true
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      raise if $?.exitstatus.nonzero?
    end
  end
end
