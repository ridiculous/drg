require 'pathname'
require 'ostruct'
require 'set'
require 'bundler'
require 'highline'
require 'duck_puncher'
require 'drg/version'

module DRG
  # defines Object#clone! which provides a deep clone
  DuckPuncher.punch! :Object

  autoload :Tasks, 'drg/tasks'
end

load 'tasks/drg.rake'
