require 'rake'

namespace :drg do
  desc "Pins the gems in your Gemfile to the current version in the Gemfile.lock"
  task :pin do
    DRG::Tasks::Pinner.new.perform
  end

  desc 'Unpins the gems in your the Gemfile'
  task :unpin do
    DRG::Tasks::Pinner.new.unpin
  end

  namespace :pin do
    desc 'Adds the fuzzy match operator to the minor version of your gems (e.g. rails, "~> 4.2")'
    task :minor do
      DRG::Tasks::Pinner.new(:minor).perform
    end

    desc 'Adds the fuzzy match operator to the major version of your gems (e.g. rails, "~> 4")'
    task :major do
      DRG::Tasks::Pinner.new(:major).perform
    end

    desc 'Adds the fuzzy match operator to the patch version of your gems (e.g. rails, "~> 4.2.3")'
    task :patch do
      DRG::Tasks::Pinner.new(:patch).perform
    end
  end

  desc 'Updates your gems in the Gemfile to the latest compatible version'
  task :update do
    # sh 'cd /Users/ryanbuckley/apps/dontspreadit && which ruby'
    DRG::Tasks::Updater.new.perform
  end
end
