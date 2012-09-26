module Flatpack
  module Client
    class FlatpackRequest < Request
      
      attr_accessor :entity
      
      def process_response(response)
        @api.flatpack.unpacker.unpack(parse_json(response))
      end
      
      def payload
        @api.flatpack.packer.pack(@entity)
      end
      
    end
  end
end