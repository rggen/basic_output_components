# frozen_string_literal: true

RSpec.describe RgGen::SystemVerilog::Common::Utility::Identifier do
  let(:name) { :foo }

  let(:identifier) { described_class.new(name) }

  def match_identifier(expectation)
    be_instance_of(described_class).and match_string(expectation)
  end

  describe '#[]' do
    context 'nilが与えられた場合' do
      it '自分自身を返す' do
        expect(identifier[nil]).to be identifier
      end
    end

    context 'ビット選択がされた場合' do
      let(:index) { rand(15) }

      it 'ビット選択がされた識別子を返す' do
        expect(identifier[index]).to match_identifier("#{name}[#{index}]")
      end
    end

    context 'パート選択がされた場合' do
      let(:lsb) { rand(0..15) }

      let(:width) { rand(1..(16 - lsb)) }

      it 'パート選択された識別子を返す' do
        expect(identifier[lsb, width]).to match_identifier("#{name}[#{lsb}+:#{width}]")
      end
    end

    context '配列選択がされて' do
      let(:width) { [16, :WIDTH] }

      let(:array_size) { [[2, 3, 4], [:FOO_SIZE, :BAR_SIZE, :BAZ_SIZE]] }

      let(:array_index) { [[0, 1, 2], [:i, :j, :k]] }

      def apply_array_attributes(width, array_size, array_format)
        identifier.__width__(width)
        identifier.__array_size__(array_size)
        identifier.__array_format__(array_format)
      end

      context '配列の形式がpackedの場合' do
        let(:array_format) { :packed }

        it '配列形式で選択された識別子を返す' do
          apply_array_attributes(width[0], array_size[0], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[0], array_size[0], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")

          apply_array_attributes(width[0], array_size[1], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[0], array_size[1], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")

          apply_array_attributes(width[1], array_size[0], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[1], array_size[0], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")

          apply_array_attributes(width[1], array_size[1], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[1], array_size[1], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")
        end
      end

      context '配列の形式がunpackedの場合' do
        let(:array_format) { :unpacked }

        it '配列形式で選択された識別子を返す' do
          apply_array_attributes(width[0], array_size[0], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[0], array_size[0], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")

          apply_array_attributes(width[0], array_size[1], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[0], array_size[1], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")

          apply_array_attributes(width[1], array_size[0], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[1], array_size[0], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")

          apply_array_attributes(width[1], array_size[1], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[0][1][2]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[0][1][2][1+:2]")

          apply_array_attributes(width[1], array_size[1], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[i][j][k]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[i][j][k][1+:2]")
        end
      end

      context '配列の形式がserializedの場合' do
        let(:array_format) { :serialized }

        it 'ベクトル形式で選択された識別子を返す' do
          apply_array_attributes(width[0], array_size[0], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[96+:16]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[97+:2]")

          apply_array_attributes(width[0], array_size[0], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[16*(12*i+4*j+k)+:16]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[16*(12*i+4*j+k)+1+:2]")

          apply_array_attributes(width[0], array_size[1], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[16*(BAR_SIZE*BAZ_SIZE*0+BAZ_SIZE*1+2)+:16]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[16*(BAR_SIZE*BAZ_SIZE*0+BAZ_SIZE*1+2)+1+:2]")

          apply_array_attributes(width[0], array_size[1], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[16*(BAR_SIZE*BAZ_SIZE*i+BAZ_SIZE*j+k)+:16]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[16*(BAR_SIZE*BAZ_SIZE*i+BAZ_SIZE*j+k)+1+:2]")

          apply_array_attributes(width[1], array_size[0], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[WIDTH*6+:WIDTH]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[WIDTH*6+1+:2]")

          apply_array_attributes(width[1], array_size[0], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[WIDTH*(12*i+4*j+k)+:WIDTH]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[WIDTH*(12*i+4*j+k)+1+:2]")

          apply_array_attributes(width[1], array_size[1], array_format)
          expect(identifier[array_index[0]]).to match_identifier("#{name}[WIDTH*(BAR_SIZE*BAZ_SIZE*0+BAZ_SIZE*1+2)+:WIDTH]")
          expect(identifier[array_index[0], 1, 2]).to match_identifier("#{name}[WIDTH*(BAR_SIZE*BAZ_SIZE*0+BAZ_SIZE*1+2)+1+:2]")

          apply_array_attributes(width[1], array_size[1], array_format)
          expect(identifier[array_index[1]]).to match_identifier("#{name}[WIDTH*(BAR_SIZE*BAZ_SIZE*i+BAZ_SIZE*j+k)+:WIDTH]")
          expect(identifier[array_index[1], 1, 2]).to match_identifier("#{name}[WIDTH*(BAR_SIZE*BAZ_SIZE*i+BAZ_SIZE*j+k)+1+:2]")
        end
      end
    end
  end

  describe '下位階層識別子' do
    before do
      identifier.__sub_identifiers__([:bar, :baz])
    end

    specify '#__sub_identifiers__で指定された下位階層識別子を取得できる' do
      expect(identifier.bar).to match_identifier('foo.bar')
      expect(identifier.baz).to match_identifier('foo.baz')
    end

    specify 'ビット選択、配列選択された識別子も下位階層識別子を取得できる' do
      expect(identifier[0].bar).to match_identifier('foo[0].bar')
      expect(identifier[0][1].baz).to match_identifier('foo[0][1].baz')
    end
  end
end
