require 'facets/string/pathize'
require 'facets/module/pathize'
require 'set'
require 'concurrent/map'

module Aws
  module Templates
    module Utils
      ##
      # Lazy load implementation
      #
      # It allows to skip 'require' definitions and load all classes and modules by convention.
      module Autoload
        REQUIRE_LOCKER = Concurrent::Map.new
        MODULE_LOCKER = Concurrent::Map.new

        Trace = TracePoint.new(:class) { |tp| Autoload.autoload!(tp.self) }

        def self._try_to_require(path, mutex)
          require path
        rescue ScriptError, NoMemoryError, StandardError => e
          REQUIRE_LOCKER.get_and_set(path, e)
          raise e
        ensure
          mutex.unlock
        end

        def self._check_if_required(path, obj)
          raise(obj) if obj.is_a?(::Exception)
          return if obj.owned?

          obj.lock.unlock
          locker_obj = REQUIRE_LOCKER[path]
          raise locker_obj if locker_obj.is_a?(Exception)
        end

        def self.atomic_require(path)
          mutex = Mutex.new.lock

          obj = REQUIRE_LOCKER.put_if_absent(path, mutex)

          if obj.nil?
            _try_to_require(path, mutex)
          else
            _check_if_required(path, obj)
          end

          true
        end

        def self.autoload!(mod)
          return if mod.name.nil?

          MODULE_LOCKER.compute_if_absent(mod) do
            path = mod.pathize

            begin
              atomic_require path
            rescue LoadError => e
              sanitize_load_exception(e, path)
            end

            true
          end
        end

        def self.const_path_for(mod, const_name)
          raise ScriptError.new("Autoload is not supported for #{mod}") if mod.name.nil?

          path = const_name.to_s.pathize

          path = "#{mod.pathize}/#{path}" unless mod.root_namespace?

          path
        end

        def self.sanitize_load_exception(exc, path)
          raise exc unless exc.path == path
        end

        def self.const_is_loaded?(mod, const_name)
          const_path = Autoload.const_path_for(mod, const_name)

          begin
            atomic_require const_path
            true
          rescue LoadError => e
            Autoload.sanitize_load_exception(e, const_path)
            false
          end
        end

        def const_missing(const_name)
          super(const_name) unless Autoload.const_is_loaded?(self, const_name)

          unless const_defined?(const_name)
            raise NameError.new(
              "::#{self}::#{const_name} is loaded but the constant is missing"
            )
          end

          const_get(const_name)
        end

        def lazy
          Lazy.new(self)
        end

        def reduce(_ = false)
          self
        end

        def root_namespace?
          (self == ::Kernel) || (self == ::Object)
        end
      end

      ##
      # Lazy module wrapper
      #
      # Allows to traverse non-existent modules up to the point when constant can be
      # auto-discovered.
      class Lazy < Module
        def self.fail_on_method(method_name)
          define_method(method_name) { |*params, &blk| raise_error(method_name, params, blk) }
        end

        def raise_error(method_name, params, blk)
          raise NoMethodError.new(
            "Lazy namespace #{self} doesn't support #{method_name}\n" \
            "  Parameters: #{params}\n" \
            "  Block: #{blk}"
          )
        end

        fail_on_method :alias_method
        fail_on_method :append_features
        fail_on_method :attr
        fail_on_method :attr_accessor
        fail_on_method :attr_reader
        fail_on_method :attr_writer
        fail_on_method :autoload
        fail_on_method :autoload?
        fail_on_method :define_method
        fail_on_method :extend_object
        fail_on_method :extended
        fail_on_method :include
        fail_on_method :included
        fail_on_method :method_added
        fail_on_method :method_removed
        fail_on_method :method_undefined
        fail_on_method :prepend
        fail_on_method :prepend_features
        fail_on_method :prepended
        fail_on_method :refine
        fail_on_method :remove_method
        fail_on_method :undef_method
        fail_on_method :using

        def method_missing(method_name, *params, &blk)
          raise_error(method_name, params, blk)
          super
        end

        def respond_to_missing?(*)
          super
        end

        def const_missing(const_name)
          Lazy.new(self, const_name)
        end

        def reduce(is_loaded = false)
          return @parent.reduce if @short_name.nil?

          @parent.reduce(is_loaded || Autoload.const_is_loaded?(@parent, @short_name))
                 .const_get(@short_name)
        end

        def to_s
          name
        end

        def inspect
          "#{name}(Lazy)"
        end

        def lazy
          self
        end

        def name
          return @parent.name if @short_name.nil?

          if @parent.root_namespace?
            @short_name.to_s
          else
            "#{@parent.name}::#{@short_name}"
          end
        end

        def root_namespace?
          @parent.root_namespace? && @short_name.nil?
        end

        def initialize(parent, short_name = nil)
          raise ScriptError.new("#{parent} is not a module") unless parent.is_a?(Module)
          @parent = parent
          @short_name = short_name
        end
      end
    end
  end
end

##
# Lazy load
#
# It allows to skip 'require' definitions and load all classes and modules by convention.
class Module
  prepend Aws::Templates::Utils::Autoload
end

Aws::Templates::Utils::Autoload::Trace.enable
