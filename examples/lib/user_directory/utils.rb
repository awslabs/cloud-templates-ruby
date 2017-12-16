require 'aws/templates/utils'

module UserDirectory
  ##
  # Auxilliary utils
  module Utils
    ##
    # Custom constraint for phone number
    #
    # Checks if value passed is a valid phone number
    def self.phone_number
      Aws::Templates::Utils::Parametrized::Constraint::SatisfiesCondition
        .new('Should be a valid phone number') do |phone|
          phone =~ /^[+]?[0-9\-]+$/
        end
    end
  end
end
