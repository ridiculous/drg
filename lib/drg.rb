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

require 'drg/railtie' if defined?(Rails)
