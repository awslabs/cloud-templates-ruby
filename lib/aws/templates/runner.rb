require 'json'
require 'optparse'
require 'aws/templates/runner/formatter'

module Aws
  module Templates
    ##
    # Logic to render single artifacts
    #
    # The module encapsulates the logic used in cloud-templates-runner.rb file. It is used to
    # setup and execute rendering of a single artifact selected from the currently loaded modules.
    # Load modules are defined by contents of aws/templates/runner/modules dir content. Any Ruby
    # file in this folder is required by modules.rb. Users can put their own loaders to the
    # directory to get them loaded during module start-up time
    #
    # Also, different formatters supported for output. By default, render output is not formatted
    # at all and is returned as is. JSON formatter is available out-of-box.
    module Runner
      class HelpException < RuntimeError
      end

      class ParameterException < RuntimeError
      end
      ##
      # Encapsulates run settings and execution
      #
      # It's used internally by module's with method to initialize rendering run.
      class Instance
        attr_reader :render
        attr_reader :format
        attr_reader :artifact
        attr_reader :options

        def run!
          format.format(render.view_for(artifact.new(options)).to_rendered)
        end

        def initialize(render: nil, format: nil, artifact: nil, options: nil)
          @render = render
          @format = format
          @artifact = artifact
          @options = options
        end
      end

      OPT_PARSER = lambda do |opts|
        opts.banner = 'AWS Templates simple runner'

        opts.on('-h', '--help', 'Display command help') do
          raise HelpException.new(opts.to_s)
        end

        opts.on('-rNAME', '--render=NAME', 'Class name of the render to use') do |name|
          store(:render, Runner.lookup_module(name))
        end

        opts.on('-fNAME', '--format=NAME', 'Formatter used for final output') do |name|
          store(:format, Aws::Templates::Runner::Formatter.format_as(name))
        end

        opts.on('-aNAME', '--artifact=NAME', 'Artifact class name') do |name|
          store(:artifact, Runner.lookup_module(name))
        end

        opts.on('-oOPTS', '--options=OPTS', 'JSON string for artifact options') do |str|
          store(:options, JSON.parse(str, symbolize_names: true))
        end
      end

      def self.with(args, opts_source)
        Instance.new(as_parameters(args, opts_source))
      end

      def self.as_parameters(args, opts_source)
        parameters = parameters_from(args)
        parameters[:format] ||= Aws::Templates::Runner::Formatter.as_is
        parameters[:options] ||= JSON.parse(as_string(opts_source), symbolize_names: true)
        parameters
      end

      RUNNER_PARAMETERS_LIST = %i[render artifact].freeze

      def self.parameters_from(args)
        parameters = {}
        optparser = OptionParser.new { |opts| parameters.instance_exec(opts, &OPT_PARSER) }
        optparser.parse(args)
        missing_parameters = RUNNER_PARAMETERS_LIST.select { |key| parameters[key].nil? }
        raise ParameterException.new(optparser.to_s) unless missing_parameters.empty?
        parameters
      end

      def self.as_string(obj)
        if obj.respond_to?(:to_str)
          obj.to_str
        elsif obj.respond_to?(:to_io)
          obj.to_io.read
        elsif obj.respond_to?(:read)
          obj.read
        else
          obj.to_s
        end
      end

      def self.lookup_module(str)
        path = str.split('::')
        path.inject(::Kernel) do |acc, elem|
          require path.map(&:downcase).join('/') unless acc.const_defined?(elem)
          acc.const_get(elem)
        end
      end
    end
  end
end
