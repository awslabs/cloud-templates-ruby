require 'aws/templates/utils'

module UserDirectory
  module Render
    module Etc
      ##
      # Person render
      #
      # The same as POSIX user but with customized GECOS field.
      class PersonView < UserView
        artifact UserDirectory::Artifacts::Person

        def user_info
          in_instance { "#{cn},,#{phone}" }
        end
      end
    end
  end
end
