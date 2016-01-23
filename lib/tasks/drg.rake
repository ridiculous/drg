require 'rake'

namespace :drg do
  desc "Pin the gems in your Gemfile to the current version in the Gemfile.lock"
  task :pin do
    DRG::Tasks::Pinner.new.perform
  end

  desc 'Unpin the gems in your the Gemfile'
  task :unpin do
    DRG::Tasks::Pinner.new.unpin
  end

  namespace :pin do
    desc 'Add the approximate minor version of your gems (rails, "~> 4.2")'
    task :minor do
      DRG::Tasks::Pinner.new(:minor).perform
    end

    desc 'Add the approximate major version of your gems (rails, "~> 4")'
    task :major do
      DRG::Tasks::Pinner.new(:major).perform
    end

    desc 'Add the approximate patch version of your gems (rails, "~> 4.2.3")'
    task :patch do
      DRG::Tasks::Pinner.new(:patch).perform
    end

    desc 'Pin the given gem to the latest version (defaults to all gems)'
    task :latest, [:gem_name] do |_, options|
      DRG::Tasks::ActivePinner.new(:available).perform(options[:gem_name])
    end

    desc 'Pin the given gem to the latest available patch version (defaults to all gems)'
    task :minor_latest, [:gem_name] do |_, options|
      DRG::Tasks::ActivePinner.new(:minor).perform(options[:gem_name])
    end

    desc 'Pin the given gem to the latest available minor version (defaults to all gems)'
    task :patch_latest, [:gem_name] do |_, options|
      DRG::Tasks::ActivePinner.new(:patch).perform(options[:gem_name])
    end

    # aliases
    task latest_minor: :minor_latest
    task latest_patch: :patch_latest
  end
end
