require 'user_directory/render/etc/user_view'

module UserDirectory
  module Render
    module Etc
      ##
      # Person render
      #
      # The same as POSIX user but with customized GECOS field.
      class PersonView < UserView
        artifact UserDirectory::Person

        def user_info
          in_instance { "#{cn},,#{phone}" }
        end
      end
    end
  end
end
