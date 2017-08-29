require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'
require 'pathname'

module UserDirectory
  ##
  # Parameter mixin containing universal fields for file objects
  #
  # It contains "path" field with constraint checking if the path
  # passed is absolute.
  module Pathed
    include Aws::Templates::Utils::Parametrized

    parameter :path,
              description: 'Path',
              transform: ->(_, s) { Pathname.new(s) },
              constraint: all_of(
                not_nil,
                satisfies('The path is a valid absolute path', &:absolute?)
              )
  end
end
