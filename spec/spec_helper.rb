require 'bundler/setup'
require 'svg_drawer'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expose_dsl_globally = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
