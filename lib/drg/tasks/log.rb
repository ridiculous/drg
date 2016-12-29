module DRG
  module Tasks
    module Log
      module_function

      def log(msg = nil, color = :green)
        HighLine.new.say %Q(  <%= color('#{msg}', :#{color}) %>)
        $stdout.flush
      end
    end
  end
end
