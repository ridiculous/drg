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
      def update(new_version)
        swap_version("'#{new_version.to_s}'")
      end

      # @return [String] line
      def remove_version
        swap_version('')
      end

      # @description Replaces the gem version with the given one
      # @example
      #
      #   line = "gem 'duck_puncher', '> 1', '< 2', require: false   # dude"
      #   swap_version('1.5.5')
      #   line # => "gem 'duck_puncher', '1.5.5', require: false   # dude"
      #
      # @destructive Modifies @line in place
      # @param [String] full_version is the quoted version to update or remove from the gem line
      # @return [String] line
      def swap_version(full_version)
        code, *comments = line.split(/#/)
        parts = code.split(',')
        end_of_line = code.rstrip.end_with?(',') ? ",#{parts.last}" : ''
        if parts.size == 1
          parts[0].chomp!
          parts << " #{full_version}" unless full_version.empty?
        else
          # ignore the first part, which is the gem name
          parts_without_gem = parts.drop(1)
          # reject options hash
          version_parts = parts_without_gem.reject { |x| x.include?(':') }
          # remove all but the first version part from the original parts array
          version_parts.drop(1).each { |version_part| parts.delete(version_part) }
          # find the index of it
          if index = parts.index(version_parts.first)
            # replace the current gem version (inside quotes)
            parts[index].sub! /['"].+['"]/, full_version
          else
            parts.insert 1, " #{full_version}"
          end
          parts.reject! { |x| x.strip.empty? }
        end
        space_after_gem = parts.first[/\s+$/].to_s
        space_after_gem = space_after_gem[0, (space_after_gem.size - full_version.size) - 2] if space_after_gem.size > full_version.size
        parts.first.rstrip!
        line.replace parts.join(',')
        line << end_of_line
        line << space_after_gem << "#" << comments.join if comments.any?
        line << "\n" unless line.end_with?("\n")
        line
      end

      # @note not used
      # @deprecated
      def version
        line[/, (.+)\n?/, 1]
      end
    end
  end
end
