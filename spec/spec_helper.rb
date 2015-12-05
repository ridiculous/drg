$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'byebug'
require 'drg'
require 'sexp_processor'

FIXTURE_ROOT = Pathname.new(File.join File.expand_path('..', __FILE__), 'fixtures')
Dir[
  FIXTURE_ROOT.join('**', '*.rb')
].sort.each &method(:require)

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  # config.filter_run focus: true
end
