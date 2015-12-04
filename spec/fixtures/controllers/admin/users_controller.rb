require_relative '../application_controller'

module Admin
  class Super
    class UsersController < ::ApplicationController
      def name()
        'ryan'
      end
    end
  end
end