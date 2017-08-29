require 'aws/templates/artifact'

module Aws
  module Templates
    module Utils
      ##
      # Arifact storage
      #
      # It's a type of Hash providing additional ability to search
      # through elements checking for different types of matches:
      # * labels
      # * classes
      # * parameters
      # It is also able to perform recursive deep search.
      class ArtifactStorage < Hash
        ##
        # Find artifacts by criteria
        #
        # The method allows flexible introspection of the artifacts
        # enclosed into the storage.
        #
        # * +search_params+ - map of search parameters:
        # ** +recursive+ - if true, search will be performed recusrsively
        #                  in nested composites
        # ** +label+ - search for artifacts which have the label
        # ** +parameters+ - search for artifacts which have specified
        #                   parameters values; it's a multi-level map so
        #                   you can check for nested values also
        def search(search_params = {})
          found = filter_artifacts(search_params)

          if search_params[:recursive]
            values
              .select { |object| object.respond_to?(:search) }
              .each { |object| found.concat(object.search(search_params)) }
          end

          found
        end

        private

        def filter_artifacts(search_params)
          found = filter_by_label(search_params[:label])

          klass = search_params[:klass]
          params_match = search_params[:parameters]

          found = found.select { |object| object.is_a?(klass) } if klass
          found = found.select { |object| check_parameters(object, params_match) } if params_match

          found
        end

        def filter_by_label(label)
          return values if label.nil?
          return [] unless key?(label)

          [self[label]]
        end

        def check_parameters(object, params)
          params.all? do |name, value|
            if object.respond_to?(name)
              if value.respond_to?(:to_hash)
                check_parameters(object.send(name), value.to_hash)
              else
                object.send(name) == value
              end
            end
          end
        end
      end
    end
  end
end
