require 'rake'

namespace :drg do
  desc 'Pins your gems in the Gemfile to the current version (using Gemfile.lock)'
  task :pin do
    DRG::Tasks::Pinner.new.perform
  end
end
