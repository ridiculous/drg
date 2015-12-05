require 'fileutils'

module DRG
  module Tasks
    class SpecRunner
      include Log

      attr_reader :file

      # @param [Pathname] file
      def initialize(file)
        @file = Pathname.new(file)
      end

      def perform
        fail ArgumentError, %Q(File or directory does not exist: "#{file}") if !File.exists?(file) && !File.exists?("#{file}.rb")
        ruby_files.each do |ruby_file|
          rspec_file = Pathname.new(spec_file(ruby_file))
          spec_file_path = rspec_file.to_s[%r|/(spec/.+)|, 1]
          next if rspec_file.exist?.tap { |exists| log "- #{spec_file_path} - already exists", :gray if exists }
          spec = generate_spec(ruby_file)
          next unless spec
          log "+ #{spec_file_path}"
          FileUtils.mkdir_p(rspec_file.parent)
          File.open(rspec_file, 'wb') do |f|
            f << spec.join("\n")
          end
        end
      end

      #
      # Private
      #

      def generate_spec(ruby_file)
        spec = DRG::Spec.new Pathname.new(File.expand_path(ruby_file))
        if spec.funcs.any?
          spec.perform
        else
          log "- #{ruby_file} - no methods", :gray
          nil
        end
      rescue => e
        log "! #{ruby_file} - #{e.inspect.gsub /^#<|>$/, ''}", :red
      end

      def ruby_files
        if File.directory?(file)
          Dir[File.join(file, '**', '*.rb')]
        else
          if file.extname.empty?
            ["#{file}.rb"]
          else
            [file]
          end
        end
      end

      # @note subbing out /app/ is Rails specific
      def spec_file(ruby_file)
        File.join(spec_path, "#{specify(ruby_file)}").sub '/app/', '/'
      end

      def specify(file_name)
        file_name.sub('.rb', '_spec.rb')
      end

      def spec_path
        if File.directory?(File.expand_path('spec'))
          File.expand_path('spec')
        else
          fail "Couldn't find spec directory"
        end
      end
    end
  end
end
