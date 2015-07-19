$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pathname'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end

FIXTURE_ROOT = Pathname.new(File.join File.expand_path('..', __FILE__), 'fixtures')
require 'drg'
