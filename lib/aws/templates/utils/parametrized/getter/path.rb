require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Lookup value in options by path
          #
          # Looks up value from options attribute by specified path. The path
          # can be either statically specified or a block can be provided.
          # The block shouldn't have parameters and should return an array
          # containing path. The block will be executed in the instance context.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => path(:a, :b)
          #    end
          #
          #    i = Piece.new(:a => { :b => 3 })
          #    i.param1 # => 3
          class Path < self
            attr_reader :path

            def initialize(*path, &path_calculation)
              @path = _check_path(path.empty? ? path_calculation : path)
            end

            def arguments
              path
            end

            protected

            def get(_, instance)
              if path.respond_to?(:to_proc)
                instance.options[*instance.instance_eval(&path)]
              elsif path.respond_to?(:to_a)
                instance.options[*path]
              end
            end

            private

            def _check_path(path)
              _raise_wrong_path(path) unless path.respond_to?(:to_proc) || path.respond_to?(:to_a)
              path
            end

            def _raise_wrong_path(path)
              raise ArgumentError.new("Path can be either array or Proc: #{path.inspect}")
            end
          end
        end
      end
    end
  end
end
