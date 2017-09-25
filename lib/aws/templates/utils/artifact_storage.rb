require 'aws/templates/artifact'
require 'set'

module Aws
  module Templates
    module Utils
      ##
      # Arifact storage
      #
      # It mimics behavior of Hash providing additional ability to search
      # through elements checking for different types of matches:
      # * labels
      # * classes
      # * parameters
      # It is also able to perform recursive deep search and de-duplication of artifact objects
      class ArtifactStorage < Hash
        include Enumerable

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

        ##
        # Artifacts list
        def artifacts
          @set.to_a
        end

        ##
        # Artifacts' labels list
        def labels
          @map.keys
        end

        ##
        # If the label is present
        def label?(l)
          @map.key?(l)
        end

        ##
        # Extract object by label
        def [](k)
          @map[k]
        end

        ##
        # Associate label to the object
        def []=(k, v)
          raise 'nil artifacts are not supported' if v.nil?
          @set << v unless @set.include?(v)
          @map[k] = v
        end

        alias values artifacts
        alias keys labels
        alias key? label?
        alias include? label?

        def each(&blk)
          @map.each(&blk)
        end

        def each_pair(&blk)
          @map.each_pair(&blk)
        end

        def map(&blk)
          @map.map(&blk)
        end

        def select(&blk)
          @map.select(&blk)
        end

        def reject(&blk)
          @map.reject(&blk)
        end

        def initialize
          @map = {}
          @set = Set.new
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
