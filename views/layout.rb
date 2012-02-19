class App
  module Views
    class Layout < Mustache
      include App::Helpers

      def session
        @request && @request.session
      end
    end
  end
end
