module DRG
  class FileReader
    # = Class
    # Needs to keep track of the context of the file as we scan each line (e.g. what class the
    # current method is defined). As well as an efficient way to loop through the lines
    # @todo add SpecReader
    #

    include Enumerable

    def initialize(file_path)
      @file_path = file_path
    end

    def each
      return to_enum unless block_given?
      File.open(@file_path) do |f|
        while line = f.gets
          yield line
        end
      end
    end

    def each_with_context
      return enum_for __method__ unless block_given?
      @context = nil
      each_with_index do |line, i|
        current_line = context.add(line, i)
        yield current_line, context
      end
    end

    def read
      @context = nil
      each_with_index do |line, i|
        context.add(line, i)
      end
    end

    def context
      @context ||= FileContext.new
    end
  end
end
