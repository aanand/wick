module Record
  def self.[](*fields)
    Class.new do
      define_method(:initialize) do |*args|
        fields.zip(args).each do |field, value|
          instance_variable_set("@#{field}", value)
        end
      end

      fields.each do |method|
        define_method(method) do |*args|
          if new_value = args.first
            new_values = fields.map { |f|
              if f == method
                new_value
              else
                self.instance_variable_get("@#{f}")
              end
            }
            self.class.new(*new_values)
          else
            self.instance_variable_get("@#{method}")
          end
        end
      end
    end
  end
end