# frozen_string_literal: true

RSpec.describe RgGen::SystemVerilog::Common::Component do
  let(:configuration) do
    RgGen::Core::Configuration::Component.new(nil, 'configuration', nil)
  end

  let(:register_map) do
    RgGen::Core::RegisterMap::Component.new(nil, 'register_map', nil, configuration)
  end

  let(:component) do
    described_class.new(nil, 'component', nil, configuration, register_map)
  end

  def create_child_component
    described_class.new(component, 'component', nil, configuration, register_map) do |child_component|
      component.add_child(child_component)
      yield(child_component)
    end
  end

  def create_feature(component, feature_name, &body)
    Class.new(RgGen::SystemVerilog::RAL::Feature, &body).new(feature_name, nil, component) do |feature|
      feature.build
      component.add_feature(feature)
    end
  end

  describe '#declarations' do
    before do
      create_feature(component, :foo_feature) do
        build do
          variable(:domain_0, :foo_0, data_type: :int)
          variable(:domain_1, :foo_1, data_type: :int)
          parameter(:domain_0, :FOO_0, default: 0)
          parameter(:domain_1, :FOO_1, default: 1)
        end
      end

      create_feature(component, :bar_feature) do
        build do
          variable(:domain_0, :bar_0, data_type: :bit, width: 1)
          variable(:domain_1, :bar_1, data_type: :bit, width: 2)
          parameter(:domain_0, :BAR_0, default: 2)
          parameter(:domain_1, :BAR_1, default: 3)
        end
      end

      create_child_component do |child_component|
        create_feature(child_component, :baz_feature) do
          build do
            variable(:domain_0, :baz_0, data_type: :int, array_size: [2])
            variable(:domain_1, :baz_1, data_type: :int, array_size: [3])
            parameter(:domain_0, :BAZ_0, default: 4)
            parameter(:domain_1, :BAZ_1, default: 5)
          end
        end
      end

      create_child_component do |child_component|
        create_feature(child_component, :qux_feature) do
          build do
            variable(:domain_0, :qux_0, data_type: :bit, width: 3, random: true)
            variable(:domain_1, :qux_1, data_type: :bit, width: 4, random: true)
            parameter(:domain_0, :QUX_0, default: 6)
            parameter(:domain_1, :QUX_1, default: 7)
          end
        end
      end
    end

    it '配下のフィーチャーで定義された変数などの定義を返す' do
      expect(component.declarations(:domain_0, :variable)).to match(
        [
          match_declaration('int foo_0'),
          match_declaration('bit bar_0'),
          match_declaration('int baz_0[2]'),
          match_declaration('rand bit [2:0] qux_0')
        ]
      )

      expect(component.declarations(:domain_1, :variable)).to match(
        [
          match_declaration('int foo_1'),
          match_declaration('bit [1:0] bar_1'),
          match_declaration('int baz_1[3]'),
          match_declaration('rand bit [3:0] qux_1')
        ]
      )

      expect(component.declarations(:domain_0, :parameter)).to match(
        [
          match_declaration('FOO_0 = 0'),
          match_declaration('BAR_0 = 2'),
          match_declaration('BAZ_0 = 4'),
          match_declaration('QUX_0 = 6')
        ]
      )

      expect(component.declarations(:domain_1, :parameter)).to match(
        [
          match_declaration('FOO_1 = 1'),
          match_declaration('BAR_1 = 3'),
          match_declaration('BAZ_1 = 5'),
          match_declaration('QUX_1 = 7')
        ]
      )
    end
  end

  describe '#package_imports' do
    before do
      create_feature(component, :foo_feature) do
        build do
          import_package :domain_0, :foo_0_pkg
          import_package :domain_1, :foo_1_pkg
        end
      end

      create_feature(component, :bar_feature) do
        build do
          import_package :domain_0, :bar_0_pkg
          import_package :domain_1, :bar_1_pkg
        end
      end

      create_child_component do |child_component|
        create_feature(child_component, :foo_feature) do
          build do
            import_package :domain_0, :foo_0_pkg
            import_package :domain_1, :foo_1_pkg
          end
        end
        create_feature(child_component, :baz_feature) do
          build do
            import_package :domain_0, :baz_0_pkg
            import_package :domain_1, :baz_1_pkg
          end
        end
      end
    end

    it '配下のフィーチャーでインポート指定されたパッケージ一覧を返す' do
      expect(component.package_imports(:domain_0)).to match([:foo_0_pkg, :bar_0_pkg, :baz_0_pkg])
      expect(component.package_imports(:domain_1)).to match([:foo_1_pkg, :bar_1_pkg, :baz_1_pkg])
    end
  end
end
