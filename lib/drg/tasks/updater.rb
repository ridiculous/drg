module DRG
  module Tasks
    class Updater
      def perform
        report = `bundle outdated`
        report.scan(/\s\*\s(.+)\s/).each do |gem|

        end

        if system('rake')
          # tests pass, update gemfile
        end
      end
    end
  end
end
