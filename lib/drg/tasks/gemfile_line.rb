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

      # @return [String] line
      # @example
      #
      #   line = "gem 'duck_puncher', '> 1', '< 2', require: false   # dude"
      #   swap_version('1.5.5')
      #   line # => "gem 'duck_puncher', '1.5.5', require: false   # dude"
      #
      # @destructive Modifies @line in place
      # @todo AVOID check for comment and inline comments by ignoring those parts
      def swap_version(full_version)
        # separate code and comments
        code, *comments = line.split(/#/)
        parts = code.split(',')
        if parts.size == 1
          parts << " #{full_version}" unless full_version.empty?
        else
          # ignore the first part, which is the gem name
          parts_without_gem = parts.drop(1)
          # reject options hash
          version_parts = parts_without_gem.reject { |x| x.include?(':') }
          # remove all but the first version part from the original parts array
          version_parts.drop(1).each { |version_part| parts.delete(version_part) }
          # find the index of it
          index = parts.index(version_parts.first)
          # replace the current gem version (inside quotes)
          parts[index].sub! /['"].+['"]/, full_version
          # remove white spaces from this item if we're removing the version
          parts[index].strip! if full_version.empty?
          parts.reject!(&:empty?)
        end
        line.replace parts.join(',')
        line << "#" << comments.join if comments.any?
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
