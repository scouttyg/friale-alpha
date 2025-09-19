module StoreAccessorWithCasting
  extend ActiveSupport::Concern

  included do
    class_attribute :store_accessor_casts, instance_writer: false, default: {}
  end

  class_methods do
    def store_accessor_with_casting(store_attribute, attribute_casts)
      store_accessor store_attribute, attribute_casts.keys

      self.store_accessor_casts = (self.store_accessor_casts || {}).merge(attribute_casts)

      attribute_casts.each do |attribute, type|
        define_method("#{attribute}=") do |value|
          casted_value = cast_value(value, type)
          super(casted_value)
        end

        define_method(attribute) do
          cast_value(super(), type)
        end
      end
    end
  end

  private

  def cast_value(value, type)
    return nil if value.nil?

    active_record_type = ActiveRecord::Type.lookup(type.to_sym)
    raise if active_record_type.nil?

    active_record_type.cast(value)
  end
end
