module DRG
  module Tasks
    module Log
      module_function

      def log(msg = nil)
        say %Q(  * <%= color('#{msg}', :green) %>)
      end
    end
  end
end
