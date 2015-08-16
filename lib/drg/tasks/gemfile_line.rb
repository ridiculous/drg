module DRG
  module Tasks
    class GemfileLine < Struct.new(:line, :index)
      alias to_s line
      alias to_int index

      def ==(other)
        line.to_s == other.to_s
      end

      # @param [Gem::Version] version responds to version.approximate_recommendation (~> 5.0)
      def update(version)
        if line =~ /,.+\n?/
          line.sub!(/,\s*(.+)\n?/, ", '#{version.to_s}'\n")
        elsif line.end_with?("\n")
          line.sub!("\n", ", '#{version.to_s}'\n")
        else
          line << ", '#{version.to_s}'\n"
        end
        line
      end

      def version
        line[/, (.+)\n?/, 1]
      end
    end
  end
end
