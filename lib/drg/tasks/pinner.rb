module DRG
  module Tasks
    class Pinner
      attr_reader :gemfile

      def initialize(gemfile = Gemfile.new)
        @gemfile = gemfile
      end

      def perform
        log %Q(Pinning Gemfile "#{gemfile}")
        ::Bundler.locked_gems.specs.each do |spec|
          gem = gemfile.find_by_name(spec.name)
          next unless gem
          gemfile.update(gem, spec.version)
        end
        gemfile.write
        log %Q(Done)
      end

      private

      def log(msg = nil)
        puts %Q(  * #{msg})
      end
    end
  end
end
