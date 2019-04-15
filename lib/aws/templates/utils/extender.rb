require 'aws/templates/utils'
require 'facets/string/modulize'
require 'facets/module/pathize'

module Aws
  module Templates
    module Utils
      ##
      # Plugin system
      class Extender
        include Enumerable

        DEFAULT_PLUGINS_PATH = 'plugins'.freeze
        EXTENSIONS_DIR = 'extensions'.freeze
        SEPARATOR = "[\\#{File::SEPARATOR}]".freeze
        NOT_SEPARATOR = "[^\\#{File::SEPARATOR}]".freeze

        attr_reader :namespace
        attr_reader :extensions_dir

        def self.create_for(namespace, extensions_dir = nil, plugins_path = nil)
          return [] if namespace.nil?
          return [] if namespace.is_a?(Module) && namespace.name.nil?

          new(namespace, extensions_dir || EXTENSIONS_DIR, plugins_path || DEFAULT_PLUGINS_PATH)
        end

        def initialize(namespace, extensions_dir, plugins_path)
          @namespace = namespace

          @extensions_dir = extensions_dir

          namespace_path = @namespace.pathize

          @lookup_regex = _make_rex(plugins_path, namespace_path, @extensions_dir)

          @lookup_glob = File.join(plugins_path, namespace_path, @extensions_dir, '*.rb')
        end

        def plugins
          all = Gem.find_latest_files(@lookup_glob, true)
          loaded = $LOADED_FEATURES
          to_load = all - loaded

          _load_plugins(to_load)
          _map_to_const(loaded) + _map_to_const(to_load)
        end

        def each(&blk)
          plugins.each(&blk)
        end

        def map(&blk)
          plugins.map(&blk)
        end

        def select(&blk)
          plugins.select(&blk)
        end

        def reject(&blk)
          plugins.reject(&blk)
        end

        def to_a
          plugins.to_a
        end

        private

        def _path_to_rex(path)
          path.gsub("\\#{File::SEPARATOR}", SEPARATOR)
        end

        def _pre_process_paths(paths)
          paths.map { |path| @lookup_regex.match(path) }
               .compact
        end

        def _make_rex(plugin_path, namespace_path, extensions_dir)
          Regexp.compile(
            [
              _path_to_rex(plugin_path),
              "(?<namespace>#{_path_to_rex(namespace_path)})",
              "(?<extensions>#{_path_to_rex(extensions_dir)})",
              "(?<plugin>#{NOT_SEPARATOR}+).rb$"
            ].join(SEPARATOR)
          )
        end

        def _load_plugins(paths)
          paths.each { |path| require path }
        end

        def _map_to_const(paths)
          _pre_process_paths(paths).map do |parsed|
            namespace.lookup_module(extensions_dir, parsed[:plugin])
          end
        end
      end
    end
  end
end
