require 'pathname'
require 'ostruct'
require 'set'
require 'bundler'
require 'duck_puncher'
require 'highline/import'
require 'drg/version'

module DRG
  autoload :Tasks, 'drg/tasks'
  autoload :Ruby, 'drg/ruby'
  autoload :Decorators, 'drg/decorators'
  autoload :Spec, 'drg/spec'
end

load 'tasks/drg.rake'
