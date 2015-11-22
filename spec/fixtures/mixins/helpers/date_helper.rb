module Mixins
  module Helpers
    class DateHelper
      attr_reader :date

      def initialize(date)
        @date = date
      end

      def perform
        date.strftime('%M') if date
      end

      private

      def something_hidden
        if @some_var
          true
        end
      end
    end
  end
end
