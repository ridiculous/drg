module DRG
  module Tasks
    class ProgessivePinner
      include Log

      attr_reader :gemfile, :type, :updated_gems
      attr_writer :versions

      # @param [Symbol] type of pin to perform. Available options are [:major, :minor, :patch]
      def initialize(type = :patch)
        @type = type
        @gemfile = Gemfile.new
        @versions = {}
        @updated_gems = Set.new
      end

      def perform(gem_name = nil)
        if gem_name
          update ::Bundler.locked_gems.specs.find { |spec| spec.name == gem_name }
        else
          update_all
        end
        gemfile.write if gemfile.saved_lines.any?
        log %Q(Done.#{' You may want run `bundle update`' if updated_gems.any?})
      end

      def update_all
        log %Q(No gem specified)
        Updater.new.perform method(:update_handler)
      end

      def update_handler(gem)
        update ::Bundler.locked_gems.specs.find { |spec| spec.name == gem.name }
      end

      def update(spec)
        gem = gemfile.find_by_name spec.name
        if gem
          log %Q[Searching for latest #{type} version of "#{spec.name}" (currently #{spec.version.to_s}) ...]
          latest_version = public_send("latest_#{type}_version", spec.name, spec.version)
          if latest_version
            if ask("  * Do you want to update to version #{latest_version} (y/n)?").to_s.downcase == 'y'
              gemfile.update gem, latest_version
              updated_gems << gem.name
            end
          else
            log %Q(No newer #{type} versions found)
          end
        end
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def latest_minor_version(name, current_version)
        new_versions(name, current_version).select { |version|
          segments = version.scan(/\d+/)
          major_version = segments[0].to_i
          minor_version = segments[1].to_i
          minor_version > current_version.segments[1] && major_version == current_version.segments[0]
        }.first
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def latest_patch_version(name, current_version)
        new_versions(name, current_version).select { |version|
          segments = version.scan(/\d+/)
          patch_version = segments[-1].to_i
          minor_version = segments[1].to_i
          patch_version > current_version.segments[-1] && minor_version == current_version.segments[1]
        }.first
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def new_versions(name, current_version)
        versions(name).select { |version| higher?(version.scan(/\d+/), current_version.segments) }
      end

      # @param [String] name of the gem
      # @return [Array] a list of available versions (e.g. ['1.2.0', '1.1.0'])
      def versions(name)
        @versions[name] ||= `gem query -radn ^#{name}$`.scan(/([\d.]+),/).flatten.uniq
      end

      def higher?(list, other_list)
        return true if list[0].to_i > other_list[0].to_i
        return true if list[1].to_i > other_list[1].to_i
        return true if list[2].to_i > other_list[2].to_i
        false
      end

      # @todo delete if not used
      #
      # @param [String] name of the gem
      # @param [String] current_version of the gem
      # def next_patch_version(name, current_version)
      #   new_versions(name, current_version).select { |version|
      #     puts segments = version.scan(/\d+/)
      #     patch_version = segments.last.to_i
      #     minor_version = segments[-2].to_i
      #     patch_version > current_version.segments[-1] && minor_version <= current_version.segments[-2]
      #   }.last
      # end
    end
  end
end
