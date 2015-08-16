require 'bundler'

module DRG
  module Tasks
    class Pinner
      def perform
        log %Q(Pinning Gemfile "#{gemfile}")
        Bundler.locked_gems.specs.each do |spec|
          gem = find_by_name(spec.name)
          next unless gem
          lines[gem.index] = gem.update(spec.version)
        end
        write_to_gemfile
        log %Q(Done)
      end

      def write_to_gemfile
        File.open(gemfile, 'wb') do |f|
          lines.each do |line|
            f << line
          end
        end
      end

      def find_by_name(name)
        lines.each_with_index.each do |line, index|
          next if line =~ /:?path:?\s*(=>)?\s*/
          next if line =~ /:?git(hub)?:?\s*(=>)?\s*/
          if line =~ /gem\s*['"]#{name}["']/
            return GemfileLine.new line, index
          end
        end
        nil
      end

      def lines
        @lines ||= File.readlines(gemfile)
      end

      def gemfile
        Bundler.default_gemfile
      end

      private

      def log(msg = nil)
        puts %Q(  * #{msg})
      end
    end
  end
end
