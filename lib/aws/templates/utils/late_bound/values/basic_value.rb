require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          ##
          # Basic late bound value class
          #
          # Basic class for all late bound values. It introduces special magic stringification and
          # inspection methods and general interface of all sub-classes.
          class BasicValue
            OPENING_SEQUENCE = "\u{e001}".freeze
            CLOSING_SEQUENCE = "\u{e007}".freeze

            attr_reader :link

            def initialize(link)
              @link = link
            end

            def to_s
              "#{OPENING_SEQUENCE}#{path}#{CLOSING_SEQUENCE}"
            end

            def inspect
              "LateBound(#{path})"
            end

            def transform_as(_transform, _instance)
              raise 'Must be overriden'
            end

            def check_constraint(_constraint, _instance)
              raise 'Must be overriden'
            end

            def path
              link.path
            end
          end
        end
      end
    end
  end
end
