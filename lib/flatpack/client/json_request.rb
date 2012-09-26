module Flatpack
  module Client
    
    # A Request that interprets the server response as JSON.
    class JsonRequest < Request
      
      def process_response(response)
        parse_json(response)
      end
      
    end
  end
end
