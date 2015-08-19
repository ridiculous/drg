module DRG
  module Tasks
    class Updater
      include Log

      attr_reader :gemfile, :bundler

      def initialize
        @gemfile = Gemfile.new
        @bundler = Bundler::CLI.new [], debug: true, current_command: OpenStruct.new
        @versions = {}
      end

      # Updates the projects outdated gems listed in the Gemfile
      #
      # @todo Cleanup old gems when finished
      # @note `bundle outdated` returns lines that look like 'slop (newest 4.2.0, installed 3.6.0) in group "default"'
      # @param [#call] handler needs to be a callable object that takes an array of gems [OpenStruct] (default :update_all)
      def perform(handler = method(:update_all))
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
          handler.call gems
        else
          log 'All gems up to date!'
        end
      end

      def update_all(gems)
        gems.each &method(:update)
      end

      # @param [#name, #current_version, #latest_version, #entry] gem is the gem to update, where #entry is a GemfileLine
      def update(gem)
        log(%Q[Updating "#{gem.name}" from #{gem.current_version} to #{gem.latest_version}])
        gemfile.remove_version gem.entry
        bundler.update(gem.name)
        if $0.to_i.zero?
          log(%Q[Succeeded in installing "#{gem.name}" (#{gem.latest_version})])
          if system('rake')
            log(%Q[Tests passed! Updating Gemfile entry for "#{gem.name}" to #{gem.latest_version}])
            gemfile.update(gem.entry, gem.latest_version)
            gemfile.write
          end
        else
          fail StandardError, %Q[Failed to update "#{gem.name}"]
        end
      rescue Bundler::GemNotFound, Bundler::InstallError, Bundler::VersionConflict => e
        log %Q[Failed to find a compatible of "#{gem.name}" (#{gem.latest_version}): #{e.class} #{e.message}]
        gemfile.rollback
      rescue => e
        gemfile.rollback
        log "#{e.class}: #{e.message}\n#{e.backtrace}"
      end
    end
  end
end
