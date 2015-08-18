module DRG
  module Tasks
    class GemfileLine < Struct.new(:line, :index, :name)
      alias to_s line
      alias to_int index

      def ==(other)
        line.to_s == other.to_s
      end

      # @param [String] version is the new value for the gem (add/replace)
      # @return [String] line
      def update(version)
        swap_version(", '#{version.to_s}'")
      end

      # @return [String] line
      def remove_version
        swap_version('')
      end

      # @return [String] line
      def swap_version(full_version)
        comment = line =~ /#/ ? " #{line.slice!(/#.*/).strip}" : ''
        if line =~ /,.+\n?/
          if line =~ /,\s*['"].+['"]/
            line[/,\s*['"].+['"]/] = full_version
          else
            line[/,\s*/] = "#{full_version}, "
            line[/\n/] = "#{comment}\n"
          end
        elsif line.end_with?("\n")
          line.sub!("\n", "#{full_version}#{comment}\n")
        else
          line << full_version  << comment << "\n"
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
