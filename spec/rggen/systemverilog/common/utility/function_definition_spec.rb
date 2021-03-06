# frozen_string_literal: true

RSpec.describe RgGen::SystemVerilog::Common::Utility::FunctionDefinition do
  include RgGen::SystemVerilog::Common::Utility

  let(:arguments) {
    [
      argument(:foo, data_type: :bit, width: 1),
      argument(:bar, data_type: :bit, width: 2, direction: :input),
      argument(:baz, data_type: :bit, width: 3, direction: :output)
    ]
  }

  it '関数定義を行うコードを返す' do
    expect(
      function_definition(:fizz)
    ).to match_string(<<~'FUNCTION')
      function fizz();
      endfunction
    FUNCTION

    expect(
      function_definition(:fizz) do |f|
        f.return_type data_type: :void
      end
    ).to match_string(<<~'FUNCTION')
      function void fizz();
      endfunction
    FUNCTION

    expect(
      function_definition(:fizz) do |f|
        f.return_type data_type: :bit, width: 2
      end
    ).to match_string(<<~'FUNCTION')
      function bit [1:0] fizz();
      endfunction
    FUNCTION

    expect(
      function_definition(:fizz) do |f|
        f.arguments arguments
      end
    ).to match_string(<<~'FUNCTION')
      function fizz(
        bit foo,
        input bit [1:0] bar,
        output bit [2:0] baz
      );
      endfunction
    FUNCTION

    expect(
      function_definition(:fizz) do |f|
        f.body { 'baz = foo + bar;' }
      end
    ).to match_string(<<~'FUNCTION')
      function fizz();
        baz = foo + bar;
      endfunction
    FUNCTION

    expect(
      function_definition(:fizz) do |f|
        f.body { 'baz = foo + bar;' }
        f.arguments arguments
        f.return_type data_type: :bit, width: 2
      end
    ).to match_string(<<~'FUNCTION')
      function bit [1:0] fizz(
        bit foo,
        input bit [1:0] bar,
        output bit [2:0] baz
      );
        baz = foo + bar;
      endfunction
    FUNCTION
  end
end
