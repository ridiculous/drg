module DRG
  module Tasks
    class GemfileLine < Struct.new(:line, :index)
      alias to_s line
      alias to_int index

      def ==(other)
        line.to_s == other.to_s
      end

      # @param [String] version is the new value for the gem (add/replace)
      def update(version)
        if line =~ /,.+\n?/
          if line =~ /,\s*['"].+['"]/
            line[/,\s*['"].+['"]/] = ", '#{version.to_s}'"
          else
            line[/,\s*/] = ", '#{version.to_s}', "
          end
        elsif line.end_with?("\n")
          line.sub!("\n", ", '#{version.to_s}'\n")
        else
          line << ", '#{version.to_s}'\n"
        end
        line
      end

      # @note not used
      def version
        line[/, (.+)\n?/, 1]
      end
    end
  end
end
