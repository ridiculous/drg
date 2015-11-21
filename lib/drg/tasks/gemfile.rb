module DRG
  module Tasks
    class Gemfile
      attr_accessor :file

      def initialize(file = ::Bundler.default_gemfile)
        @file = file
      end

      # Saves a copy of @lines before changing it (note that #dup and #clone weren't working)
      #
      # @param [GemfileLine] gem
      # @param [String] version to update the gem line with
      def update(gem, version)
        saved_lines << lines.clone!
        lines[gem] = gem.update version
      end

      def remove_version(gem)
        saved_lines << lines.clone!
        lines[gem] = gem.remove_version
        write
      end

      def find_by_name(name)
        lines.each_with_index.each do |line, index|
          next if line =~ /^\s*#/
          next if line =~ /:?path:?\s*(=>)?\s*/
          next if line =~ /:?git(hub)?:?\s*(=>)?\s*/
          next if line =~ /@drg\s+(frozen|ignore|skip)/
          return GemfileLine.new line, index, name if line =~ /gem\s*['"]#{name}["']/
        end
        nil
      end

      def write
        File.open file, 'wb' do |f|
          lines.each do |line|
            f << line
          end
        end
      end

      def rollback
        return if saved_lines.empty?
        lines.replace saved_lines.pop
        write
      end

      def saved_lines
        @saved_lines ||= []
      end

      def lines
        @lines ||= File.readlines file
      end
    end
  end
end
