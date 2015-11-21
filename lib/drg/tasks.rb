module DRG
  module Tasks
    autoload :Updater, 'drg/tasks/updater'
    autoload :Pinner, 'drg/tasks/pinner'
    autoload :ActivePinner, 'drg/tasks/active_pinner'
    autoload :Gemfile, 'drg/tasks/gemfile'
    autoload :GemfileLine, 'drg/tasks/gemfile_line'
    autoload :Log, 'drg/tasks/log'
    autoload :SpecRunner, 'drg/tasks/spec_runner'
  end
end
