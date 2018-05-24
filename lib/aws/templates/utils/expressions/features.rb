module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Features namespace
        #
        # "Features" are mixins which provide appropriate interface for particular expression types.
        # For instance, arithmetic expressions would contain comparison and arithmetic operators;
        # whereas logical expressions would support conjunction, disjunction and negation.
        module Features
        end
      end
    end
  end
end
