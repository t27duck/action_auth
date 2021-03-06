# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "bundler/setup"
require "action_auth"
require "support/config_examples"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class SpecUser
  attr_reader :pass
  attr_accessor :role_symbols

  def initialize(pass = true, roles: [])
    @pass = pass
    @role_symbols = roles
  end
end
