require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Late bound namespace
      #
      # Late bound is a value which can't be calculated during template evaluation but only can
      # be obtained at remote side (CloudFormation reference, SQL field value, etc). This module
      # is a namespace for late bound functionality with a few static utility methods. Late bound
      # object carries infromation about its' type and constraints so it can be properly
      # type-checked.
      module LateBound
        ##
        # Create a builder from the link
        #
        # Value builder is a special object which is handled differently from a regular value.
        # It hooks into the process of value calculation through apply_concept method and produces
        # late bound value with attached constraint and transformation.
        def self.build_from(link)
          Builder.new(link)
        end

        ##
        # Create method link
        #
        # Links are special objects which contain late bound value's binding information.
        # Effectively they are links to the point of origin for late bound value.
        def self.as_method(name, parent, origin = nil, meta = nil)
          MethodLink.new(name, parent, origin, meta)
        end
      end
    end
  end
end
