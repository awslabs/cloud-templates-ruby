require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Artifact documentation generator
        #
        # Aggregate which assembled different aspects of artifact documentation such as:
        # * help blurb
        # * parameters description
        # * defaults description
        class Artifact < Help::Aggregate
          include Rdoc::Texting

          register_in Rdoc::Processor
          for_entity Templates::Artifact

          after Templates::Help::Dsl, Templates::Utils::Parametrized, Templates::Utils::Default

          protected

          def fragment
            sub(
              text("\n*#{context.name}*"),
              text("_Parents_: #{superclasses.map(&:to_s).join('->')}")
            )
          end

          def compose(fragments)
            list(:LABEL, *fragments)
          end

          private

          def superclasses
            Enumerator.new do |y|
              s = context.superclass
              while s && s <= Templates::Artifact
                y << s
                s = s.superclass
              end
            end
          end
        end
      end
    end
  end
end
