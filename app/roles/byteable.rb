module Byteable
  def bytes_attr_accessor *method_names
    attr_reader *method_names
    method_names.each do |method_name|
      define_method "#{method_name.to_s}=" do |bytes|
        coerced = case bytes
                  when Bytes
                    bytes
                  else
                    Bytes.new bytes
                  end
        instance_variable_set "@#{method_name}", coerced
      end
    end
  end
end
