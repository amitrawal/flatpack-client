require 'flatpack_core'

module Flatpack
  module Client
    class BaseApi
      include Flatpack::Core::MapInitialize
      
      attr_accessor :server_base, :flatpack, :verbose
      
      # Concrete implementations that require authentication should implement 
      # this method do determine if the current session is still active.
      def session_active?
        # By default, the session is always active
        true
      end
      
      # Concrete implementations that require authentication should implement 
      # this method to refresh an expired session
      def refresh_session
      end
      
      # Concrete implementations that require authentication should implement 
      # this method if authenticated requests require custom request headers
      def auth_headers
        return {}
      end
      
      def describe_entity_get(entity)
        describe_type_uuid_get(entity.entity_name, entity.uuid)
      end
      
      def annotation_entity_get(entity)
        annotation_type_uuid_get(entity.entity_name, entity.uuid)
      end
      
    end
  end
end