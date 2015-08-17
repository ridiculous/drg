require 'rake'

namespace :drg do
  desc 'Pins your gems in the Gemfile to the current version (using Gemfile.lock)'
  task :pin do
    DRG::Tasks::Pinner.new.perform
  end

  namespace :pin do
    task :minor do
      DRG::Tasks::Pinner.new(:minor).perform
    end

    task :major do
      DRG::Tasks::Pinner.new(:major).perform
    end
  end

  desc 'Updates your gems in the Gemfile to the latest compatible version'
  task :update do
    # sh 'cd /Users/ryanbuckley/apps/dontspreadit && which ruby'
    DRG::Tasks::Updater.new.perform
  end
end
