module DRG
  class Judge
    attr_reader :spec, :file

    def initialize(file, spec)
      @file, @spec = file, spec
    end

    def missing_methods
      describes = DRG::Scanner.new(spec).describes
      DRG::Scanner.new(file).methods.select { |method_name|
        describes.detect { |describe_name|
          # turn Report.name or Report#name into .name and #name
          describe_name[/#{Regexp.escape(method_name.sub(/^\w+(\.|#)/, '\1'))}/i]
        }.nil?
      }
    end
  end
end
