require 'pathname'
require 'ostruct'
require 'set'
require 'bundler'
require 'highline'
require 'duck_puncher'
require 'drg/version'

module DRG
  DuckPuncher.punch! :Object, only: :clone!

  autoload :Tasks, 'drg/tasks'
end

load 'tasks/drg.rake'
