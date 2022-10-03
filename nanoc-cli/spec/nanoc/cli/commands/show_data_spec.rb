# frozen_string_literal: true

describe Nanoc::CLI::Commands::ShowData, stdio: true do
  describe '#print_item_dependencies' do
    subject { runner.send(:print_item_dependencies, items, dependency_store) }

    let(:runner) do
      described_class.new(options, arguments, command)
    end

    let(:options) { {} }
    let(:arguments) { [] }
    let(:command) { double(:command) }

    let(:items) do
      Nanoc::Core::ItemCollection.new(
        config,
        [
          item_about,
          item_dog,
          item_other,
        ],
      )
    end

    let(:item_about) { Nanoc::Core::Item.new('About Me', {}, '/about.md') }
    let(:item_dog)   { Nanoc::Core::Item.new('About My Dog', {}, '/dog.md') }
    let(:item_other) { Nanoc::Core::Item.new('Raw Data', {}, '/other.dat') }

    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd).with_defaults }

    let(:dependency_store) do
      Nanoc::Core::DependencyStore.new(items, layouts, config)
    end

    let(:layouts) do
      Nanoc::Core::LayoutCollection.new(config)
    end

    it 'prints a legend' do
      expect { subject }.to output(%r{Item dependencies =+\n\nLegend:}).to_stdout
    end

    context 'no dependencies' do
      it 'outputs no dependencies for /about.md' do
        expect { subject }.to output(%r{^item /about.md depends on:\n  \(nothing\)$}m).to_stdout
      end

      it 'outputs no dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \(nothing\)$}m).to_stdout
      end

      it 'outputs no dependencies for /other.dat' do
        expect { subject }.to output(%r{^item /other.dat depends on:\n  \(nothing\)$}m).to_stdout
      end
    end

    context 'dependency (without props) from config to dog' do
      before do
        dependency_store.record_dependency(item_dog, config)
      end

      it 'outputs no dependencies for /about.md' do
        expect { subject }.to output(%r{^item /about.md depends on:\n  \(nothing\)$}m).to_stdout
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[  config \] \(racp\) $}m).to_stdout
      end

      it 'outputs no dependencies for /other.dat' do
        expect { subject }.to output(%r{^item /other.dat depends on:\n  \(nothing\)$}m).to_stdout
      end
    end

    context 'dependency (without props) from about to dog' do
      before do
        dependency_store.record_dependency(item_dog, item_about)
      end

      it 'outputs no dependencies for /about.md' do
        expect { subject }.to output(%r{^item /about.md depends on:\n  \(nothing\)$}m).to_stdout
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[    item \] \(racp\) /about.md$}m).to_stdout
      end

      it 'outputs no dependencies for /other.dat' do
        expect { subject }.to output(%r{^item /other.dat depends on:\n  \(nothing\)$}m).to_stdout
      end
    end

    context 'dependency (with raw_content prop) from about to dog' do
      before do
        dependency_store.record_dependency(item_dog, item_about, raw_content: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[    item \] \(r___\) /about.md$}m).to_stdout
      end
    end

    context 'dependency (with attributes prop) from about to dog' do
      before do
        dependency_store.record_dependency(item_dog, item_about, attributes: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[    item \] \(_a__\) /about.md$}m).to_stdout
      end
    end

    context 'dependency (with attributes prop) from config to dog' do
      before do
        dependency_store.record_dependency(item_dog, config, attributes: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[  config \] \(_a__\) $}m).to_stdout
      end
    end

    context 'dependency (with compiled_content prop) from about to dog' do
      before do
        dependency_store.record_dependency(item_dog, item_about, compiled_content: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[    item \] \(__c_\) /about.md$}m).to_stdout
      end
    end

    context 'dependency (with path prop) from about to dog' do
      before do
        dependency_store.record_dependency(item_dog, item_about, path: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[    item \] \(___p\) /about.md$}m).to_stdout
      end
    end

    context 'dependency (with multiple props) from about to dog' do
      before do
        dependency_store.record_dependency(item_dog, item_about, attributes: true, raw_content: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[    item \] \(ra__\) /about.md$}m).to_stdout
      end
    end

    context 'dependency onto all items' do
      before do
        dependency_store.record_dependency(item_dog, items, raw_content: true)
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[   items \] \(r___\) matching any$}m).to_stdout
      end
    end

    context 'dependency onto one specific item' do
      before do
        dependency_store.record_dependency(item_dog, items, raw_content: ['/about.*'])
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[   items \] \(r___\) matching any of /about\.\*$}m).to_stdout
      end
    end

    context 'dependency onto multiple specific items' do
      before do
        dependency_store.record_dependency(item_dog, items, raw_content: ['/about.*'])
        dependency_store.record_dependency(item_dog, items, raw_content: ['/giraffe.*'])
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[   items \] \(r___\) matching any of /about\.\*, /giraffe\.\*$}m).to_stdout
      end
    end

    context 'dependency onto one specific layout' do
      before do
        dependency_store.record_dependency(item_dog, layouts, raw_content: ['/about.*'])
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[ layouts \] \(r___\) matching any of /about\.\*$}m).to_stdout
      end
    end

    context 'dependency onto multiple specific layouts' do
      before do
        dependency_store.record_dependency(item_dog, layouts, raw_content: ['/about.*'])
        dependency_store.record_dependency(item_dog, layouts, raw_content: ['/giraffe.*'])
      end

      it 'outputs dependencies for /dog.md' do
        expect { subject }.to output(%r{^item /dog.md depends on:\n  \[ layouts \] \(r___\) matching any of /about\.\*, /giraffe\.\*$}m).to_stdout
      end
    end
  end

  describe '#print_item_rep_outdatedness' do
    subject { runner.send(:print_item_rep_outdatedness, items, outdatedness_checker, reps) }

    let(:runner) do
      described_class.new(options, arguments, command)
    end

    let(:options) { {} }
    let(:arguments) { [] }
    let(:command) { double(:command) }

    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd) }

    let(:items) do
      Nanoc::Core::ItemCollection.new(
        config,
        [
          item_about,
          item_dog,
        ],
      )
    end

    let(:item_about) { Nanoc::Core::Item.new('About Me', {}, '/about.md') }
    let(:item_dog)   { Nanoc::Core::Item.new('About My Dog', {}, '/dog.md') }

    let(:item_rep_about) { Nanoc::Core::ItemRep.new(item_about, :default) }
    let(:item_rep_dog)   { Nanoc::Core::ItemRep.new(item_dog, :default) }

    let(:site) { double(:site) }
    let(:outdatedness_checker) { double(:outdatedness_checker) }

    let(:reps) do
      {
        item_about => [item_rep_about],
        item_dog => [item_rep_dog],
      }
    end

    context 'not outdated' do
      before do
        allow(outdatedness_checker).to receive(:outdatedness_reasons_for).with(item_rep_about).and_return([])
        allow(outdatedness_checker).to receive(:outdatedness_reasons_for).with(item_rep_dog).and_return([])
      end

      example do
        expect { subject }.to output(%r{^item /about.md, rep default:\n  is not outdated$}).to_stdout
      end

      example do
        expect { subject }.to output(%r{^item /dog.md, rep default:\n  is not outdated$}).to_stdout
      end
    end

    context 'outdated' do
      before do
        reasons_about =
          [
            Nanoc::Core::OutdatednessReasons::ContentModified,
            Nanoc::Core::OutdatednessReasons::AttributesModified.new([:title]),
          ]

        reasons_dog =
          [Nanoc::Core::OutdatednessReasons::DependenciesOutdated]

        allow(outdatedness_checker).to receive(:outdatedness_reasons_for)
          .with(item_rep_about).and_return(reasons_about)

        allow(outdatedness_checker).to receive(:outdatedness_reasons_for)
          .with(item_rep_dog).and_return(reasons_dog)
      end

      example do
        expect { subject }.to output(%r{^item /about.md, rep default:\n  is outdated:\n    - The content of this item has been modified since the last time the site was compiled.\n    - The attributes of this item have been modified since the last time the site was compiled.$}).to_stdout
      end

      example do
        expect { subject }.to output(%r{^item /dog.md, rep default:\n  is outdated:\n    - This item uses content or attributes that have changed since the last time the site was compiled.$}).to_stdout
      end
    end
  end

  describe '#print_layouts' do
    subject { runner.send(:print_layouts, layouts, outdatedness_checker) }

    let(:runner) do
      described_class.new(options, arguments, command)
    end

    let(:options) { {} }
    let(:arguments) { [] }
    let(:command) { double(:command) }

    let(:config) { Nanoc::Core::Configuration.new(dir: Dir.getwd) }

    let(:layouts) do
      Nanoc::Core::LayoutCollection.new(config, [layout])
    end

    let(:layout) { Nanoc::Core::Layout.new('stuff', {}, '/default.erb') }

    let(:site) { double(:site) }
    let(:outdatedness_checker) { double(:outdatedness_checker) }

    context 'not outdated' do
      before do
        allow(outdatedness_checker).to receive(:outdatedness_reasons_for).with(layout).and_return([])
      end

      example do
        expect { subject }.to output(%r{^layout /default.erb:\n  is not outdated$}).to_stdout
      end
    end

    context 'outdated' do
      before do
        reasons =
          [
            Nanoc::Core::OutdatednessReasons::ContentModified,
            Nanoc::Core::OutdatednessReasons::AttributesModified.new([:title]),
          ]

        allow(outdatedness_checker).to receive(:outdatedness_reasons_for)
          .with(layout).and_return(reasons)
      end

      example do
        expect { subject }.to output(%r{^layout /default.erb:\n  is outdated:\n    - The content of this item has been modified since the last time the site was compiled.\n    - The attributes of this item have been modified since the last time the site was compiled.$}).to_stdout
      end
    end
  end
end
