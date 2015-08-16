require 'rake'

namespace :drg do
  desc 'Pins your gems in the Gemfile to the current version (using Gemfile.lock)'
  task :pin do
    DRG::Tasks::Pinner.new.perform
  end

  desc 'Updates your gems in the Gemfile to the latest compatible version'
  task :update do
    DRG::Tasks::Updater.new.perform
  end
end
