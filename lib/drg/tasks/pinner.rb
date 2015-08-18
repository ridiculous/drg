module DRG
  module Tasks
    class Pinner
      include Log

      attr_reader :gemfile, :type

      # @param [Symbol] type of pin to perform. Available options are [:full, :major, :minor, :patch]
      def initialize(type = :full)
        @type = type
        @gemfile = Gemfile.new
      end

      def perform
        log %Q(Pinning Gemfile "#{gemfile.file}")
        ::Bundler.locked_gems.specs.each do |spec|
          gem = gemfile.find_by_name spec.name
          next unless gem
          gemfile.update gem, public_send(type, spec.version.to_s)
          gemfile.write
        end
        log %Q(Done)
      end

      def unpin
        log %Q(Unpinning Gemfile "#{gemfile.file}")
        ::Bundler.locked_gems.specs.each do |spec|
          gem = gemfile.find_by_name spec.name
          gemfile.remove_version gem if gem
        end
        log %Q(Done)
      end

      #
      # Types
      #

      def full(version)
        version
      end

      def major(version)
        v = version[/(\d+)/, 1]
        if v == '0'
          minor(version)
        else
          "~> #{v}"
        end
      end

      def minor(version)
        v = version[/(\d+\.\d+)/, 1]
        if v == '0.0'
          version
        else
          "~> #{v}"
        end
      end

      def patch(version)
        "~> #{version}"
      end
    end
  end
end
