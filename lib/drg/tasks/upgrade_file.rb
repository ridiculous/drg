module DRG
  module Tasks
    class UpgradeFile
      include Log

      attr_accessor :file

      def initialize(file_name)
        @file = Bundler.root.join(file_name.to_s)
      end

      def call
        ruby_files.each do |ruby_file|
          contents = File.read(ruby_file)
          log %(Updating "#{ruby_file}")
          contents.gsub! /:(\w+)\s?=>/, '\1:'
          # contents.gsub!(/([A-Z]*[a-z0-9_!?.\[\]'()+=>:,&]+)\.(should)\s?==/, 'expect(\1).to eq')
          contents.gsub! /Factory\.create/, 'create'
          contents.gsub! /Factory\.build/, 'build'
          contents.gsub! /Factory\.next/, 'generate'
          contents.gsub! /Factory\(/, 'create('
          contents.gsub! /Factory\.attributes_for/, 'FactoryGirl.attributes_for'
          File.write(ruby_file, contents)
        end
        if ruby_files.empty?
          log %(No files found for "#{file}")
        end
        log 'Done.'
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
    end
  end
end
