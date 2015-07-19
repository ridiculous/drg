require_relative 'let'

module DRG
  class Scanner
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def lets
      _lets = []
      continuation = false
      File.readlines(file).each do |line|
        if continuation && continuation = line.strip != 'end'
          _lets[-1].value << line
        elsif line =~ /\A\s+let\(?:(\w+)\)?\s*do\s*\n/
          continuation = true
          _lets << Let.new($1.strip, '')
        elsif line =~ /\A\s+let\(?:(\w+)\)?\s*\{(.+)\}/m
          _lets << Let.new($1.strip, $2.strip)
        end
      end
      _lets
    end

    def indentation
      line = nil
      File.open(file) do |f|
        previous_line = nil
        until indent_size(previous_line) != indent_size(line = f.gets)
          previous_line = line
        end
      end
      indent_size(line)
    end

    def methods
      items = []
      klasses = Set.new
      File.readlines(file).each do |line|
        if line =~ /class (\w+)/
          klasses << $1
        end
        case line.to_s.chomp.strip
        when /#?\s*private/i
          break
        when /def (self)?(\.?[a-z0-9_]+)/
          method_name = $2
          if method_name !~ /\A\./
            method_name = "##{method_name}"
          end
          items << "#{klasses.to_a.join('::')}#{method_name}"
        else
          nil
        end
      end
      items
    end

    def describes
      File.readlines(file).map { |line| $2 if line =~ /(describe|context)\s*['"%](.+)\s*['"%]/ }.compact
    end

    def indent_size(line)
      line.to_s.chomp.rstrip[/\s{0,}/].size.to_i
    end
  end
end
