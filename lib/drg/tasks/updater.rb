module DRG
  module Tasks
    class Updater
      attr_reader :gemfile

      def initialize
        @gemfile = Gemfile.new
        @versions = {}
      end

      def perform
        `bundle outdated`.scan(/\s\*\s(.+)\s/).flatten.each &method(:try_update)
      end

      # @param [Item] item from the `bundle outdated` command (e.g. 'slop (newest 4.2.0, installed 3.6.0) in group "default"')
      def try_update(item)
        name = item[/(\w+)\s/, 1]
        gem = gemfile.find_by_name(name)
        return unless gem
        latest_version = item[/newest\s([\d.]+)/, 1]
        log(%Q(Trying to update gem "#{name}" to #{latest_version}))
        if system("bundle update #{name}")
          log(%Q[Succeeded in installing "#{name}" (#{latest_version})])
          if system('rake')
            log(%Q(Tests passed after updating "#{name}" to version #{latest_version}))
            gemfile.update(gem, latest_version)
            gemfile.write
          else
            log(%Q(Tests failed after updating "#{name}" to version #{latest_version}))
          end
        else
          log(%Q[Failed to install "#{name}" (#{latest_version})])
        end
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def new_versions(name, current_version)
        versions(name).select { |version| version > current_version }
      end

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
