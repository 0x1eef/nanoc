# frozen_string_literal: true

usage 'compile [options]'
summary 'compile items of this site'
description <<~EOS
  Compile all items of the current site.
EOS
flag nil, :diff, 'generate diff'

module Nanoc::CLI::Commands
  class Compile < ::Nanoc::CLI::CommandRunner
    attr_accessor :listener_classes

    def initialize(options, arguments, command)
      super
      @listener_classes = default_listener_classes
    end

    def run
      time_before = Time.now

      @site = load_site

      puts 'Compiling site…'
      compiler = Nanoc::Int::Compiler.new_for(@site)
      run_listeners_while(compiler) do
        compiler.run_all
      end

      time_after = Time.now
      puts
      puts "Site compiled in #{format('%.2f', time_after - time_before)}s."
    end

    protected

    def default_listener_classes
      [
        Nanoc::CLI::Commands::CompileListeners::DiffGenerator,
        Nanoc::CLI::Commands::CompileListeners::DebugPrinter,
        Nanoc::CLI::Commands::CompileListeners::TimingRecorder,
        Nanoc::CLI::Commands::CompileListeners::FileActionPrinter,
      ]
    end

    def setup_listeners(compiler)
      reps = reps_for(compiler)

      @listeners =
        @listener_classes
        .select { |klass| klass.enable_for?(self, @site) }
        .map    { |klass| klass.new(reps: reps) }

      @listeners.each(&:start_safely)
    end

    def listeners
      @listeners
    end

    def run_listeners_while(compiler)
      setup_listeners(compiler)
      yield
    ensure
      teardown_listeners
    end

    def teardown_listeners
      return unless @listeners
      @listeners.reverse_each(&:stop_safely)
    end

    def reps_for(compiler)
      res = compiler.run_until_reps_built
      res.fetch(:reps)
    end
  end
end

runner Nanoc::CLI::Commands::Compile
