# frozen_string_literal: true

RgGen.define_simple_feature(:register, :sv_rtl_top) do
  sv_rtl do
    export :index
    export :local_index
    export :loop_variables

    pre_build do
      @base_index = register_block.registers.sum(&:count)
    end

    build do
      unless register.bit_fields.empty?
        interface :bit_field_if, {
          name: 'bit_field_if',
          interface_type: 'rggen_bit_field_if',
          parameter_values: [register.width]
        }
      end
    end

    main_code :register_block do
      local_scope("g_#{register.name}") do |scope|
        scope.top_scope
        scope.loop_size loop_size
        scope.variables variables
        scope.body(&method(:body_code))
      end
    end

    def index(offset = nil)
      operands =
        register.array? ? [@base_index, offset || local_index] : [@base_index]
      if operands.all? { |operand| operand.is_a?(Integer) }
        operands.sum
      else
        operands.join('+')
      end
    end

    def local_index
      (register.array? || nil) &&
        loop_variables
          .zip(local_index_coefficients)
          .map { |v, c| [c, v].compact.join('*') }
          .join('+')
    end

    def loop_variables
      (register.array? || nil) &&
        register.array_size.map.with_index(1) do |_size, i|
          create_identifier(loop_index(i))
        end
    end

    private

    def local_index_coefficients
      coefficients = []
      register.array_size.reverse.inject(1) do |total, size|
        coefficients.unshift(coefficients.size.zero? ? nil : total)
        total * size
      end
      coefficients
    end

    def loop_size
      (register.array? || nil) &&
        loop_variables.zip(register.array_size).to_h
    end

    def variables
      register.declarations[:variable]
    end

    def body_code(code)
      register.generate_code(code, :register, :top_down)
    end
  end
end
