$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'simplecov'
require 'codecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

code_coverage_token = ENV['CODECOV_TOKEN'] || false

# If the environment variable is present, format for Codecov
if code_coverage_token
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/wpmreleasetoolkit' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

RSpec.configure do |config|
  config.filter_run_when_matching :focus
end

def set_circle_env(define_ci)
  is_ci = ENV.key?('CIRCLECI')
  orig_circle_ci = ENV['CIRCLECI']
  if (define_ci)
    ENV['CIRCLECI'] = 'CircleCI'
  else
    ENV.delete 'CIRCLECI'
  end 

  yield
ensure
  if (is_ci)
    ENV['CIRCLECI'] = orig_circle_ci
  else
    ENV.delete 'CIRCLECI'
  end
end