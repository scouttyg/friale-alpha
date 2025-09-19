Hashid::Rails.configure do |config|
  # The salt to use for generating hashid. Prepended with pepper (table name).
  config.salt = "#{Rails.env}44d61715fa4b48b08b55f7db9dc9eb2f"

  # config.pepper = table_name

  # The minimum length of generated hashids
  config.min_hash_length = 20

  # The alphabet to use for generating hashids
  # config.alphabet = 'abcdefghijklmnopqrstuvwxyz' \
  #                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
  #                  '1234567890'

  # Whether to override the `find` method
  # config.override_find = true

  # Whether to override the `to_param` method
  config.override_to_param = false

  # Whether to sign hashids to prevent conflicts with regular IDs (see https://github.com/jcypret/hashid-rails/issues/30)
  # config.sign_hashids = true
end
