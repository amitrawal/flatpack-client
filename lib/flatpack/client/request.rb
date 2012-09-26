require 'uri'
require 'net/https'

module Flatpack
  module Client
    class Request
      
      attr_accessor :payload
      
      def initialize(api, method, path, *args)
        @api = api
        @method = method.downcase
          
        # replace path paramters
        @path = path
        @path.scan(/[{][^}]*[}]/).each_with_index do |match, i|
          @path.gsub!(match, args[i])
        end
        
        # define default headers
        @headers = {
          'Content-Type' => 'application/json'
        }
        @headers.merge!(@api.auth_headers)
        
        # and query parameters
        @query_params = {}
      end
      
      # Execute the request.
      def execute
        
        # ensure our api session is still active
        @api.refresh_session unless @api.session_active?
        
        # build our URI
        uri = URI.parse(@api.server_base.to_s)
        uri.path = @path
        unless(@query_params.empty?) 
          uri.query = @query_params.map{ |key, value| "#{key}=#{URI::encode(value.to_s)}" }.join('&')
        end
        
        # build our request
        req = Net::HTTP.const_get(@method.capitalize).new(uri.request_uri)
        payload = self.payload
        if(payload and payload.length > 0)
          puts "payload is #{payload}" if @api.verbose
          req.body = payload 
        end
        
        # add the headers
        @headers.each do |key, value|
          req.add_field(key, value)
        end
        
        # log it
        if(@api.verbose)
          puts "requesting #{@method} to #{uri.to_s} with headers #{@headers.inspect}"
        end
        
        # and send it off
        http = Net::HTTP.new(uri.host, uri.port)
        if(uri.scheme == 'https')
          # TODO allow the certificate options to be specified 
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.use_ssl = true
        end
        response = http.start { |h| h.request(req) }
          
        # log our response
        if(@api.verbose)
          puts "response #{response.code} with payload #{response.body}"
        end
        
        process_response(response)
      end

      # Add a custom header to the request.
      def header(name, value)
        @headers[name] = value
        self
      end
    
    # log our response
      # Add a custom query parameter to the request. The generated subclasses of Request will have
      # convenience methods for setting defined query parameters.
      def query_parameter(name, value)
        @query_params[name] = value
        self
      end
      
      protected
      
      # default response processing simply returns the response
      def process_response(response)
        response
      end
      
      # Returns true for a 2XX series response code.
      def is_ok(code)
        code >= 200 and code < 300
      end
      
      def parse_json(response)
        json = {}
        begin
          json = JSON.parse(response.body)
        rescue
          puts "couldn't parse response as JSON"
        end
        json['status_code'] = response.code
        json
      end
      
    end
  end
end