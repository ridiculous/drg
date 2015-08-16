module DRG
  module Tasks
    class Gemfile
      attr_accessor :file

      def initialize
        @file = ::Bundler.default_gemfile
      end

      def update(gem, version)
        lines[gem] = gem.update(version)
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
        @lines ||= File.readlines file
      end

      def write
        File.open(file, 'wb') do |f|
          lines.each do |line|
            f << line
          end
        end
      end

    end
  end
end
