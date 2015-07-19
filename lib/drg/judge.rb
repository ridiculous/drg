module DRG
  class Judge
    attr_reader :spec, :file

    def initialize(file, spec)
      @file, @spec = DRG::Phile.new(file), spec
    end

    def missing_methods
      describes = DRG::Scanner.new(spec).describes
      DRG::Scanner.new(file).methods.select { |method_name|
        describes.detect { |describe_name|
          describe_name[/#{Regexp.escape(method_name.sub(/#{file.name}/, '').sub(/[^a-z0-9_]/, ''))}/i]
        }.nil?
      }
    end
  end
end
