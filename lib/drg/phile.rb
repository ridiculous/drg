require 'delegate'

module DRG
  class Phile < DelegateClass(File)
    def name
      if basename.to_s[/\w+/] =~ /\A(\w)/
        basename.to_s.sub(/\A(\w)/, $1.upcase).sub('.rb', '')
      end
    end

    def exists?
      File.exists? self
    end
  end
end