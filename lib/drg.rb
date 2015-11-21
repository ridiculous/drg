require 'ostruct'
require 'set'
require 'bundler'
require 'duck_puncher'
require 'highline/import'

# defines Object#clone!
DuckPuncher.punch! :Object

require 'drg/version'

module DRG
  module Tasks
    autoload :Updater, 'drg/tasks/updater'
    autoload :Pinner, 'drg/tasks/pinner'
    autoload :ActivePinner, 'drg/tasks/active_pinner'
    autoload :Gemfile, 'drg/tasks/gemfile'
    autoload :GemfileLine, 'drg/tasks/gemfile_line'
    autoload :Log, 'drg/tasks/log'
  end

  autoload :Ruby, 'drg/ruby'
  autoload :Decorators, 'drg/decorators'
  autoload :Spec, 'drg/spec'
end

load 'tasks/drg.rake'
