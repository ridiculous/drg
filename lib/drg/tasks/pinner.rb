module DRG
  module Tasks
    class Pinner
      attr_reader :gemfile, :type

      def initialize(type = :patch)
        @type = type
        @gemfile = Gemfile.new
      end

      def perform
        log %Q(Pinning Gemfile "#{gemfile}")
        ::Bundler.locked_gems.specs.each do |spec|
          gem = gemfile.find_by_name spec.name
          next unless gem
          gemfile.update gem, public_send(type, spec.version.to_s)
        end
        gemfile.write
        log %Q(Done)
      end

      def patch(version)
        version
      end

      def minor(version)
        v = version[/(\d+\.\d+)/, 1]
        if v == '0.0'
          version
        else
          "~> #{v}"
        end
      end

      def major(version)
        v = version[/(\d+)/, 1]
        if v == '0'
          minor(version)
        else
          "~> #{v}"
        end
      end

      private

      def log(msg = nil)
        puts %Q(  * #{msg})
      end
    end
  end
end
