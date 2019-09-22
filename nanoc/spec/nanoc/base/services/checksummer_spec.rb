# frozen_string_literal: true

# NOTE: this spec checks all the bits that aren’t in Core.

describe Nanoc::Core::Checksummer do
  subject { described_class.calc(obj, Nanoc::Core::Checksummer::VerboseDigest) }

  context 'Nanoc::RuleDSL::RulesCollection' do
    let(:obj) do
      Nanoc::RuleDSL::RulesCollection.new.tap { |rc| rc.data = data }
    end

    let(:data) { 'STUFF!' }

    it { is_expected.to eql('Nanoc::RuleDSL::RulesCollection<String<STUFF!>>') }
  end

  context 'Nanoc::Core::CodeSnippet' do
    let(:obj) { Nanoc::Core::CodeSnippet.new('asdf', '/bob.rb') }

    it { is_expected.to eql('Nanoc::Core::CodeSnippet<String<asdf>>') }
  end

  context 'Nanoc::Core::CompilationItemView' do
    let(:obj) { Nanoc::Core::CompilationItemView.new(item, nil) }
    let(:item) { Nanoc::Core::Item.new('asdf', {}, '/foo.md') }

    it { is_expected.to eql('Nanoc::Core::CompilationItemView<Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<asdf>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>>') }
  end

  context 'Nanoc::Core::BasicItemRepView' do
    let(:obj) { Nanoc::Core::BasicItemRepView.new(rep, nil) }
    let(:rep) { Nanoc::Core::ItemRep.new(item, :pdf) }
    let(:item) { Nanoc::Core::Item.new('asdf', {}, '/foo.md') }

    it { is_expected.to eql('Nanoc::Core::BasicItemRepView<Nanoc::Core::ItemRep<item=Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<asdf>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>,name=Symbol<pdf>>>') }
  end

  context 'Nanoc::Core::CompilationItemRepView' do
    let(:obj) { Nanoc::Core::CompilationItemRepView.new(rep, nil) }
    let(:rep) { Nanoc::Core::ItemRep.new(item, :pdf) }
    let(:item) { Nanoc::Core::Item.new('asdf', {}, '/foo.md') }

    it { is_expected.to eql('Nanoc::Core::CompilationItemRepView<Nanoc::Core::ItemRep<item=Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<asdf>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>,name=Symbol<pdf>>>') }
  end

  context 'Nanoc::Core::BasicItemView' do
    let(:obj) { Nanoc::Core::BasicItemView.new(item, nil) }
    let(:item) { Nanoc::Core::Item.new('asdf', {}, '/foo.md') }

    it { is_expected.to eql('Nanoc::Core::BasicItemView<Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<asdf>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>>') }
  end

  context 'Nanoc::Core::LayoutView' do
    let(:obj) { Nanoc::Core::LayoutView.new(layout, nil) }
    let(:layout) { Nanoc::Core::Layout.new('asdf', {}, '/foo.md') }

    it { is_expected.to eql('Nanoc::Core::LayoutView<Nanoc::Core::Layout<content=Nanoc::Core::TextualContent<String<asdf>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>>') }
  end

  context 'Nanoc::Core::ConfigView' do
    let(:obj) { Nanoc::Core::ConfigView.new(config, nil) }
    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd, hash: { 'foo' => 'bar' }) }

    it { is_expected.to eql('Nanoc::Core::ConfigView<Nanoc::Core::Configuration<Symbol<foo>=String<bar>,>>') }
  end

  context 'Nanoc::Core::ItemCollectionWithRepsView' do
    let(:obj) { Nanoc::Core::ItemCollectionWithRepsView.new(wrapped, nil) }

    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd, hash: { 'foo' => 'bar' }) }

    let(:wrapped) do
      Nanoc::Core::ItemCollection.new(
        config,
        [
          Nanoc::Core::Item.new('foo', {}, '/foo.md'),
          Nanoc::Core::Item.new('bar', {}, '/foo.md'),
        ],
      )
    end

    it { is_expected.to eql('Nanoc::Core::ItemCollectionWithRepsView<Nanoc::Core::ItemCollection<Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<foo>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>,Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<bar>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>,>>') }
  end

  context 'Nanoc::Core::ItemCollectionWithoutRepsView' do
    let(:obj) { Nanoc::Core::ItemCollectionWithoutRepsView.new(wrapped, nil) }

    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd, hash: { 'foo' => 'bar' }) }

    let(:wrapped) do
      Nanoc::Core::ItemCollection.new(
        config,
        [
          Nanoc::Core::Item.new('foo', {}, '/foo.md'),
          Nanoc::Core::Item.new('bar', {}, '/foo.md'),
        ],
      )
    end

    it { is_expected.to eql('Nanoc::Core::ItemCollectionWithoutRepsView<Nanoc::Core::ItemCollection<Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<foo>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>,Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<bar>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>,>>') }
  end

  context 'Nanoc::RuleDSL::CompilationRuleContext' do
    let(:obj) { Nanoc::RuleDSL::CompilationRuleContext.new(rep: rep, site: site, recorder: recorder, view_context: view_context) }

    let(:rep) { Nanoc::Core::ItemRep.new(item, :pdf) }
    let(:item) { Nanoc::Core::Item.new('stuff', {}, '/stuff.md') }

    let(:site) do
      Nanoc::Core::Site.new(
        config: config,
        code_snippets: code_snippets,
        data_source: Nanoc::Core::InMemoryDataSource.new(items, layouts),
      )
    end

    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd, hash: { 'foo' => 'bar' }) }
    let(:code_snippets) { [Nanoc::Core::CodeSnippet.new('asdf', '/bob.rb')] }
    let(:items) { Nanoc::Core::ItemCollection.new(config, [item]) }
    let(:layouts) { Nanoc::Core::LayoutCollection.new(config, [Nanoc::Core::Layout.new('asdf', {}, '/foo.md')]) }

    let(:recorder) { Nanoc::RuleDSL::ActionRecorder.new(rep) }
    let(:view_context) { Nanoc::Core::ViewContextForPreCompilation.new(items: items) }

    let(:expected_item_checksum) { 'Nanoc::Core::Item<content=Nanoc::Core::TextualContent<String<stuff>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</stuff.md>>>' }
    let(:expected_item_rep_checksum) { 'Nanoc::Core::ItemRep<item=' + expected_item_checksum + ',name=Symbol<pdf>>' }
    let(:expected_layout_checksum) { 'Nanoc::Core::Layout<content=Nanoc::Core::TextualContent<String<asdf>>,attributes=Hash<>,identifier=Nanoc::Core::Identifier<String</foo.md>>>' }
    let(:expected_config_checksum) { 'Nanoc::Core::Configuration<Symbol<foo>=String<bar>,>' }

    let(:expected_checksum) do
      [
        'Nanoc::RuleDSL::CompilationRuleContext<',
        'item=',
        'Nanoc::Core::BasicItemView<' + expected_item_checksum + '>',
        ',rep=',
        'Nanoc::Core::BasicItemRepView<' + expected_item_rep_checksum + '>',
        ',items=',
        'Nanoc::Core::ItemCollectionWithoutRepsView<Nanoc::Core::ItemCollection<' + expected_item_checksum + ',>>',
        ',layouts=',
        'Nanoc::Core::LayoutCollectionView<Nanoc::Core::LayoutCollection<' + expected_layout_checksum + ',>>',
        ',config=',
        'Nanoc::Core::ConfigView<' + expected_config_checksum + '>',
        '>',
      ].join('')
    end

    it { is_expected.to eql(expected_checksum) }
  end

  context 'Sass::Importers::Filesystem' do
    let(:obj) { Sass::Importers::Filesystem.new('/foo') }

    before { require 'sass' }

    it { is_expected.to match(%r{\ASass::Importers::Filesystem<root=(C:)?/foo>\z}) }
  end
end
