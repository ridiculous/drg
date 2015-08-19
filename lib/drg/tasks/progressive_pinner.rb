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

      def update_handler(gems)
        load_versions gems.map &:name
        gems.each do |gem|
          update ::Bundler.locked_gems.specs.find { |spec| spec.name == gem.name }
        end
      end

      # @note calls #latest_minor_version and #latest_patch_version
      def update(spec)
        gem = gemfile.find_by_name spec.name
        if gem
          latest_version = public_send("latest_#{type}_version", spec.name, spec.version)
          if latest_version
            log %Q(Updating "#{spec.name}" from #{spec.version.to_s} to #{latest_version})
            gemfile.update gem, latest_version
            updated_gems << gem.name
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
        @versions[name] ||= begin
          log %Q(Searching for latest #{type} version of "#{name}" ...)
          `gem query -radn ^#{name}$`.scan(/([\d.]+),/).flatten.uniq
        end
      end

      def load_versions(gems)
        load_gem_versions(gems).scan(/^(#{Array(gems).join('|')})\s\(([\d.\s,\w\-]+)\)$/).each do |gem_name, versions|
          @versions[gem_name] = versions.to_s.split(', ')
        end
      end

      def load_gem_versions(gems)
        log %Q(Searching for latest #{type} versions of #{gems.join(' ')} ...)
        `gem query -ra #{gems.join(' ')}`
      end

      # @param [Array] list of a gem version's segments
      # @param [Array] other_list of another gem version's segments
      def higher?(list, other_list)
        list[0].to_i > other_list[0].to_i || list[1].to_i > other_list[1].to_i || list[2].to_i > other_list[2].to_i
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
