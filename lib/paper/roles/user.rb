module Paper
  module Roles
    module User
      
      def self.included(base)
        base.class_eval do
          field :roles, :type => Array
        end
      end
      
      ROLES = [ :write_posts, :delete_posts, :write_comments ]
      
      class InvalidRoleError < RuntimeError
        def initialize(role)
          super("invalid role: #{role}")
        end
      end
      
      def add_role(role)
        unless ROLES.include?(role)
          raise InvalidRoleError.new(role)
        end

        self.roles ||= [ ]  
        self.roles  |= [ role ]
      end

      def remove_role(role)
        unless ROLES.include?(role)
          raise InvalidRoleError.new(role)
        end

        if self.roles
          self.roles.delete(role)
        end

        self.roles = nil if self.roles.empty?
      end

      def has_role?(role)
        (self.roles || [ ]).include?(role)
      end
    end
  end
end