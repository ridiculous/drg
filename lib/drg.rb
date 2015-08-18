require 'ostruct'
require 'set'
require 'bundler'
require 'bundler/cli'
require 'drg/version'
require 'duck_puncher'
require 'highline/import'

# defines #clone!
DuckPuncher.load! :Object

module DRG
  # autoload :FileReader, 'drg/file_reader'
  # autoload :Scanner, 'drg/scanner'
  # autoload :Judge, 'drg/judge'
  # autoload :FileContext, 'drg/file_context'

  module Tasks
    autoload :Updater, 'drg/tasks/updater'
    autoload :Pinner, 'drg/tasks/pinner'
    autoload :ProgessivePinner, 'drg/tasks/progressive_pinner'
    autoload :Gemfile, 'drg/tasks/gemfile'
    autoload :GemfileLine, 'drg/tasks/gemfile_line'
    autoload :Log, 'drg/tasks/log'
  end
end

load 'tasks/drg.rake'
