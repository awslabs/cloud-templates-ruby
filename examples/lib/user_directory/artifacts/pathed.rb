require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Parameter mixin containing universal fields for file objects
    #
    # It contains "path" field with constraint checking if the path
    # passed is absolute.
    module Pathed
      include Aws::Templates::Utils::Parametrized

      parameter :path,
                description: 'Path',
                transform: ->(_, s) { ::Pathname.new(s) },
                constraint: all_of(
                  not_nil,
                  satisfies('The path is a valid absolute path', &:absolute?)
                )
    end
  end
end
