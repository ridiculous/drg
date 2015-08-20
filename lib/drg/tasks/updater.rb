module DRG
  module Tasks
    class Updater
      include Log

      # Loads the current version of outdated gems
      #
      # @note `bundle outdated` returns lines that look like 'slop (newest 4.2.0, installed 3.6.0) in group "default"'
      # @param [#call] handler needs to be a callable object that takes an array of gems [OpenStruct] (default :update_all)
      def perform
        log 'Searching for outdated gems ....'
        outdated = `bundle outdated`.scan(/\s\*\s(.+)\s/).flatten
        gems = outdated.map { |item| OpenStruct.new(name: item[/([\-\w0-9]+)\s/, 1]) }
        if gems.any?
          yield gems
        else
          log 'All gems up to date!'
        end
      end
    end
  end
end
