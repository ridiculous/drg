require 'delegate'

module DRG
  module Tasks
    class AutoPinner
      attr_reader :active_pinner

      def initialize(*args)
        @active_pinner = ActivePinner.new *args
      end

      def commit
        active_pinner.write
      end

      def rollback
        active_pinner.gemfile.rollback
      end

      # @todo keep track of gems we installed so we can uninstall them if need be with something like:
      #   def uninstall
      #     require 'rubygems/command_manager'
      #     Gem::CommandManager.new.run ["uninstall", spec.name, "-v", latest_version]
      #   end
      def perform
        Updater.new.perform do |gems|
          @active_pinner.versions = DRG::VersionFetcher.new.perform gems
          gems.each do |gem_name|
            spec, latest_version = @active_pinner.update(gem_name)
            if latest_version
              commit
              update(spec, latest_version)
            else
              rollback
            end
          end
        end
      end

      def update(spec, latest_version)
        spec_pattern = %r[(gems/#{Regexp.escape(spec.name)}-[0-9.]+/.*)]
        current_load_path = find_load_path(spec_pattern)
        unless current_load_path
          DRG.ui.warn "Path not found, skipping ..."
          commit
          return
        end
        install_dir = current_load_path.sub spec_pattern, ''
        $LOAD_PATH.delete_if { |x| x =~ spec_pattern }
        $LOAD_PATH << install_dir
        install_with_lock(spec.name, latest_version, install_dir)
        DRG.ui.say "Running bundle update ..."
        puts `bundle update #{spec.name}`
        DRG.ui.say "Running specs ..."
        if system("rspec")
          DRG.ui.say "Specs passed!"
        else
          DRG.ui.warn %Q(Specs failed!)
          DRG.ui.warn %Q(You may want to run "bundle clean --force")
          rollback
        end
      end

      # @description Prevents bundler from throwing errors while we "Building native extensions. This could take a while..."
      def install_with_lock(*args)
        Bundler.settings[:frozen] = true
        install(*args)
      ensure
        Bundler.settings[:frozen] = false
      end

      def install(name, version, install_dir)
        opts = {
          install_dir: install_dir,
          bin_dir: RbConfig::CONFIG['bindir']
        }
        require 'rubygems/dependency_installer'
        inst = Gem::DependencyInstaller.new opts
        inst.install name, version
        inst.installed_gems
      end

      def find_load_path(spec_pattern)
        load_paths = $LOAD_PATH + Bundler::RubygemsIntegration.new.loaded_gem_paths
        load_paths.find { |x| x =~ spec_pattern }
      end
    end
  end
end
