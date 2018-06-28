require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Lazy provider-entity routing
        #
        # It is used to avoid loading too much code into the memory even when it's not required.
        module Routing
          extend Templates::Processor::Routing

          register Templates.lazy::Help::Dsl, Rdoc.lazy::Dsl
          register Templates.lazy::Artifact, Rdoc.lazy::Artifact
          register Templates.lazy::Composite, Rdoc.lazy::Composite

          register Templates.lazy::Utils::Default, Rdoc.lazy::Default::Provider
          register Templates.lazy::Utils::Default::Definition, Rdoc.lazy::Default::Definition
          register Templates.lazy::Utils::Default::Definition::Empty,
                   Rdoc.lazy::Default::Definition::Empty
          register Templates.lazy::Utils::Default::Definition::Pair,
                   Rdoc.lazy::Default::Definition::Pair
          register Templates.lazy::Utils::Default::Definition::Calculable,
                   Rdoc.lazy::Default::Definition::Calculable
          register Templates.lazy::Utils::Default::Definition::Scheme,
                   Rdoc.lazy::Default::Definition::Scheme

          register Templates.lazy::Utils::Parametrized, Rdoc.lazy::Parametrized::Provider
          register Templates.lazy::Utils::Parametrized::Parameter,
                   Rdoc.lazy::Parametrized::Parameter
          register Templates.lazy::Utils::Parametrized::Nested, Rdoc.lazy::Parametrized::Nested
          register Templates.lazy::Utils::Parametrized::Constraint,
                   Rdoc.lazy::Parametrized::Constraint
          register Templates.lazy::Utils::Parametrized::Constraint::AllOf,
                   Rdoc.lazy::Parametrized::Constraints::AllOf
          register Templates.lazy::Utils::Parametrized::Constraint::DependsOnValue,
                   Rdoc.lazy::Parametrized::Constraints::DependsOnValue
          register Templates.lazy::Utils::Parametrized::Constraint::Enum,
                   Rdoc.lazy::Parametrized::Constraints::Enum
          register Templates.lazy::Utils::Parametrized::Constraint::Matches,
                   Rdoc.lazy::Parametrized::Constraints::Matches
          register Templates.lazy::Utils::Parametrized::Constraint::NotNil,
                   Rdoc.lazy::Parametrized::Constraints::NotNil
          register Templates.lazy::Utils::Parametrized::Constraint::Requires,
                   Rdoc.lazy::Parametrized::Constraints::Requires
          register Templates.lazy::Utils::Parametrized::Constraint::SatisfiesCondition,
                   Rdoc.lazy::Parametrized::Constraints::SatisfiesCondition
          register Templates.lazy::Utils::Parametrized::Constraint::IsModule::Baseless,
                   Rdoc.lazy::Parametrized::Constraints::IsModule::Baseless
          register Templates.lazy::Utils::Parametrized::Constraint::IsModule::Based,
                   Rdoc.lazy::Parametrized::Constraints::IsModule::Based
          register Templates.lazy::Utils::Parametrized::Constraint::Is,
                   Rdoc.lazy::Parametrized::Constraints::Is
          register Templates.lazy::Utils::Parametrized::Constraint::Has,
                   Rdoc.lazy::Parametrized::Constraints::Has

          register Templates.lazy::Utils::Parametrized::Constraint::Condition,
                   Rdoc.lazy::Parametrized::Constraints::Condition
          register Templates.lazy::Utils::Parametrized::Constraint::Condition::Equal,
                   Rdoc.lazy::Parametrized::Constraints::Condition::Equal
          register Templates.lazy::Utils::Parametrized::Constraint::Condition::Conditional,
                   Rdoc.lazy::Parametrized::Constraints::Condition::Conditional

          register Templates.lazy::Utils::Parametrized::Getter,
                   Rdoc.lazy::Parametrized::Getter

          register Templates.lazy::Utils::Parametrized::Transformation,
                   Rdoc.lazy::Parametrized::Transformation
          register Templates.lazy::Utils::Parametrized::Transformation::AsBoolean,
                   Rdoc.lazy::Parametrized::Transformations::AsBoolean
          register Templates.lazy::Utils::Parametrized::Transformation::AsChain,
                   Rdoc.lazy::Parametrized::Transformations::AsChain
          register Templates.lazy::Utils::Parametrized::Transformation::AsHash,
                   Rdoc.lazy::Parametrized::Transformations::AsHash
          register Templates.lazy::Utils::Parametrized::Transformation::AsInteger,
                   Rdoc.lazy::Parametrized::Transformations::AsInteger
          register Templates.lazy::Utils::Parametrized::Transformation::AsFloat,
                   Rdoc.lazy::Parametrized::Transformations::AsFloat
          register Templates.lazy::Utils::Parametrized::Transformation::AsList,
                   Rdoc.lazy::Parametrized::Transformations::AsList
          register Templates.lazy::Utils::Parametrized::Transformation::AsModule,
                   Rdoc.lazy::Parametrized::Transformations::AsModule
          register Templates.lazy::Utils::Parametrized::Transformation::AsObject,
                   Rdoc.lazy::Parametrized::Transformations::AsObject
          register Templates.lazy::Utils::Parametrized::Transformation::AsRendered,
                   Rdoc.lazy::Parametrized::Transformations::AsRendered
          register Templates.lazy::Utils::Parametrized::Transformation::AsParsed,
                   Rdoc.lazy::Parametrized::Transformations::AsParsed
          register Templates.lazy::Utils::Parametrized::Transformation::AsString,
                   Rdoc.lazy::Parametrized::Transformations::AsString
          register Templates.lazy::Utils::Parametrized::Transformation::AsJson,
                   Rdoc.lazy::Parametrized::Transformations::AsJson

          register Templates.lazy::Utils::Parametrized::Concept,
                   Rdoc.lazy::Parametrized::Concept
          register Templates.lazy::Utils::Parametrized::Concept::Chain,
                   Rdoc.lazy::Parametrized::Concept::Chain

          register Templates.lazy::Utils::Contextualized, Rdoc.lazy::Contextualized::Provider
          register Templates.lazy::Utils::Contextualized::Filter,
                   Rdoc.lazy::Contextualized::Filter
          register Templates.lazy::Utils::Contextualized::Filter::Add,
                   Rdoc.lazy::Contextualized::Filters::Add
          register Templates.lazy::Utils::Contextualized::Filter::Chain,
                   Rdoc.lazy::Contextualized::Filters::Chain
          register Templates.lazy::Utils::Contextualized::Filter::Copy,
                   Rdoc.lazy::Contextualized::Filters::Copy
          register Templates.lazy::Utils::Contextualized::Filter::Identity,
                   Rdoc.lazy::Contextualized::Filters::Identity
          register Templates.lazy::Utils::Contextualized::Filter::Override,
                   Rdoc.lazy::Contextualized::Filters::Override
          register Templates.lazy::Utils::Contextualized::Filter::Proxy,
                   Rdoc.lazy::Contextualized::Filters::Proxy
          register Templates.lazy::Utils::Contextualized::Filter::Remove,
                   Rdoc.lazy::Contextualized::Filters::Remove
          register Templates.lazy::Utils::Contextualized::Filter::Scoped,
                   Rdoc.lazy::Contextualized::Filters::Scoped
        end
      end
    end
  end
end
