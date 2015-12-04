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

    desc 'Pins all gems [or the requested gem] to the latest version'
    task :latest, [:gem_name] do |_, options|
      DRG::Tasks::ActivePinner.new(:available).perform(options[:gem_name])
    end

    desc 'Pins all gems [or the requested gem] to the latest available patch version'
    task :minor_latest, [:gem_name] do |_, options|
      DRG::Tasks::ActivePinner.new(:minor).perform(options[:gem_name])
    end

    desc 'Pins all gems [or the requested gem] to the latest available minor version'
    task :patch_latest, [:gem_name] do |_, options|
      DRG::Tasks::ActivePinner.new(:patch).perform(options[:gem_name])
    end

    # aliases
    task latest_minor: :minor_latest
    task latest_patch: :patch_latest
  end

  task :spec, [:file_name] => :environment do |_, args|
    DRG::Tasks::SpecRunner.new(args.file_name).perform
  end

  task :environment do
    # no-op hook task
  end if !Rake::Task.task_defined?(:environment) and !defined?(Rails)
end
