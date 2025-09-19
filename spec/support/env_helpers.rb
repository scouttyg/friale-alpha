# frozen_string_literal: true

def temporary_env(temporary_env_hash)
  set_temporary_env(temporary_env_hash)
  begin
    yield
  ensure
    remove_temporary_env
  end
end

# rubocop:disable Naming/AccessorMethodName
def set_temporary_env(temporary_env_hash)
  @old_env = ENV.to_hash
  ENV.update(temporary_env_hash.to_h { |k, v| [k.to_s, v.to_s] })
end
# rubocop:enable Naming/AccessorMethodName

def remove_temporary_env
  ENV.replace(@old_env)
end

def reset_and_reload_class(klass)
  # Remove constants that may include ENV variables
  source_location = nil
  klass.constants(false).each do |sym_constant|
    source_location = klass.const_source_location(sym_constant)[0]
    # rubocop:disable RSpec/RemoveConst
    klass.send(:remove_const, sym_constant)
    # rubocop:enable RSpec/RemoveConst
  end

  # Get filepath of class
  source_location = klass.instance_method(:initialize).source_location[0] if source_location.nil?

  absolute_file_path_of_class = source_location
  relative_file_path_of_class = absolute_file_path_of_class.delete_prefix(Rails.root.to_s)
  final_file_path = if relative_file_path_of_class.start_with?("/")
                      relative_file_path_of_class.delete_prefix("/")
                    else
                      relative_file_path_of_class
                    end

  # Load class again via filepath to reload constants after removing them
  load final_file_path
end
