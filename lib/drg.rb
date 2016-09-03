require 'pathname'
require 'ostruct'
require 'set'
require 'bundler'
require 'highline'
require 'duck_puncher'
require 'drg/version'

module DRG
  autoload :Tasks, 'drg/tasks'
end

if defined?(Rails)
  require 'drg/railtie'
else
  load 'tasks/drg.rake'
end
