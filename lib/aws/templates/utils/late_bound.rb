require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Late binding utilities
      #
      # Late binding is a technique of referencing values which don't exist at the template
      # calculation stage. Examples could be Process ID, SQL record calculated ID or AWS object
      # ARN you're creating through a script or CFN template.
      #
      # The module provides DSL for creating late binding points known as References.
      module LateBound
        include Utils::Inheritable

        ##
        # Reference
        #
        # Reference is a special placeholder object designed to point to the object reference was
        # created for with optional path and args attached.
        #
        # References are used when the final value of an object property is unknown at the template
        # calculation stage and can be extracted only when the final rendered view is submitted to
        # the target system (late binding)
        class Reference
          attr_reader :instance
          attr_reader :path
          attr_reader :arguments

          FAILURE_MESSAGES = {
            to_s: 'string',
            to_i: 'integer',
            to_f: 'float',
            to_a: 'array',
            to_h: 'hash',
            to_str: 'string',
            to_int: 'integer',
            to_ary: 'array',
            to_hash: 'hash',
            to_proc: 'proc'
          }.freeze

          FAILURE_MESSAGES.each_pair do |method_name, type_name|
            define_method(method_name) do
              raise(
                "Reference can't be transformed to #{type_name} or paricipate in any operations" \
                'References are placeholders for values which don\'t exist at the template ' \
                'calculation stage (late binding)'
              )
            end
          end

          def initialize(target_instance, target_path = nil, args = nil)
            @instance = target_instance
            @path = target_path
            @arguments = args
          end
        end

        instance_scope do
          ##
          # Create reference
          #
          # Create and return Reference object attached to the current instance with specified path
          # and arguments
          def reference(path = nil, *args)
            Reference.new(self, path, args)
          end
        end

        ##
        # Class-level DSL
        class_scope do
          ##
          # Wrap reference for postponed instantiation
          #
          # References are instance-level objects so they can be attached only to an instance, not
          # to a class. So, to be able to do that in "default" section in an artifact, for instance,
          # you need to specify a proc/lambda object for the option. This method makes the wrappin
          # unnecessary.
          def reference(path = nil, *args)
            -> { reference(path, *args) }
          end
        end
      end
    end
  end
end
