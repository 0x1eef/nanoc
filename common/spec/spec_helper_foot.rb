# frozen_string_literal: true

require_relative 'spec_helper_foot_core'

Nanoc::CLI.setup

RSpec.configure do |c|
  c.around do |example|
    Nanoc::CLI::ErrorHandler.disable
    example.run
    Nanoc::CLI::ErrorHandler.enable
  end

  c.before(:each, fork: true) do
    skip 'fork() is not supported on Windows' if Nanoc::Core.on_windows?
  end
end

RSpec::Matchers.define :raise_wrapped_error do |expected|
  supports_block_expectations

  include RSpec::Matchers::Composable

  match do |actual|
    actual.call
  rescue Nanoc::Core::Errors::CompilationError => e
    values_match?(expected, e.unwrap)
  end

  description do
    "raise wrapped error #{expected.inspect}"
  end

  failure_message do |_actual|
    "expected that proc would raise wrapped error #{expected.inspect}"
  end

  failure_message_when_negated do |_actual|
    "expected that proc would not raise wrapped error #{expected.inspect}"
  end
end

RSpec::Matchers.alias_matcher :some_textual_content, :be_some_textual_content
RSpec::Matchers.alias_matcher :some_binary_content, :be_some_binary_content
