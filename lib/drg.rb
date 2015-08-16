require 'ostruct'
require 'set'
require 'drg/version'

module DRG
  autoload :FileReader, 'drg/file_reader'
  autoload :Scanner, 'drg/scanner'
  autoload :Judge, 'drg/judge'
  autoload :FileContext, 'drg/file_context'

  module Tasks
    autoload :Pinner, 'drg/tasks/pinner'
    autoload :GemfileLine, 'drg/tasks/gemfile_line'
  end
end

load 'tasks/drg.rake'
