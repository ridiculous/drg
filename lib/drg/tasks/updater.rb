module DRG
  module Tasks
    class Updater
      attr_reader :gemfile, :failures, :bundler

      def initialize
        @gemfile = Gemfile.new
        @failures = Set.new
        @bundler = Bundler::CLI.new [], debug: true, current_command: OpenStruct.new
        @versions = {}
      end

      # Updates the projects outdated gems listed in the Gemfile
      #
      # @todo Incrementally update the gem using +versions+
      # @todo Cleanup old gems when finished
      # @note `bundle outdated` returns lines that look like 'slop (newest 4.2.0, installed 3.6.0) in group "default"'
      def perform
        log 'Searching for outdated gems ....'
        outdated = `bundle outdated`.scan(/\s\*\s(.+)\s/).flatten
        gems = outdated.map do |item|
          gem = OpenStruct.new
          gem.name = item[/([\-\w0-9]+)\s/, 1]
          gem.entry = gemfile.find_by_name(gem.name)
          next unless gem.entry
          gem.latest_version = item[/newest\s([\d.\w]+)/, 1]
          gem.current_version = item[/installed\s([\d.\w]+)/, 1]
          gem
        end.compact
        if gems.any?
          gems.each &method(:try_update)
        else
          log 'All gems up to date!'
        end
      end

      # @param [OpenStruct] gem
      def try_update(gem)
        log(%Q[Updating "#{gem.name}" from #{gem.current_version} to #{gem.latest_version}])
        gemfile.remove_version gem.entry
        bundler.update(gem.name)
        if $0.to_i.zero?
          log(%Q[Succeeded in installing "#{gem.name}" (#{gem.latest_version})])
          if system('rake')
            log(%Q[Tests passed! Updating Gemfile entry for "#{gem.name}" to #{gem.latest_version}])
            gemfile.update(gem.entry, gem.latest_version)
          else
            failures << gem.name
          end
        else
          fail StandardError, %Q[Failed to update "#{gem.name}"]
        end
      rescue Bundler::GemNotFound, Bundler::InstallError, Bundler::VersionConflict => e
        log %Q[Failed to find a compatible of "#{gem.name}" (#{gem.latest_version}): #{e.class} #{e.message}]
        gemfile.rollback
        failures << gem.name
          # @todo retry it later
      rescue => e
        puts "#{e.class}: #{e.message} #{e.backtrace}"
        gemfile.rollback
      end

      # @note not used
      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def new_versions(name, current_version)
        versions(name).select { |version| version > current_version }
      end

      # @note not used
      # @param [String] name of the gem
      # @return [Array] a list of available versions (e.g. ['1.2.0', '1.1.0'])
      def versions(name)
        @versions[name] ||= `gem query -radn ^#{name}$`.scan(/([\d.]+),/).flatten
      end

      private

      def log(msg = nil)
        puts %Q(  * #{msg})
      end
    end
  end
end
