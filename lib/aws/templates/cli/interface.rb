require 'json'
require 'aws/templates/utils'

module Aws
  module Templates
    module Cli
      ##
      # Templates CLI
      #
      # The class provides command-line utilities to use cloud templates and artifacts without
      # knowledge of Ruby directly from command line.
      # Commands:
      # * render - It is used to setup and execute rendering of a single artifact. Also, different
      #            formatters supported for output. By default, render output is not formatted
      #            at all and is returned as is. JSON formatter is available out-of-box.
      # * document - provide online documentation for selected artifact optionally using specific
      #              documentation generator
      class Interface < ::Thor
        desc 'render ARTIFACT', 'Render ARTIFACT with RENDER and print result'

        method_option :format,
                      desc: 'Formatter used for final output',
                      aliases: :f,
                      required: false,
                      default: 'Json',
                      type: :string

        method_option :options,
                      desc: 'JSON-formatted options to pass to the artifact',
                      aliases: :o,
                      required: false,
                      type: :string

        method_option :render,
                      desc: 'Render',
                      aliases: :r,
                      required: true,
                      type: :string

        method_option :render_parameters,
                      desc: 'Render parameters',
                      aliases: :rp,
                      type: :string

        def render(artifact_path)
          say _format(
            Templates::Utils.lookup_module(artifact_path),
            Templates::Utils.lookup_module(options[:render]),
            Aws::Templates::Cli::Formatter.format_as(options[:format]),
            _artifact_options,
            _render_parameters
          )
        end

        desc 'document ARTIFACT', 'Show help for the ARTIFACT'

        method_option :generator,
                      desc: 'Generator to be used to generate the documentation',
                      aliases: :g,
                      required: false,
                      default: 'Aws::Templates::Help::Rdoc',
                      type: :string

        method_option :parameters,
                      desc: 'JSON-formatted generator optional parameters',
                      aliases: :p,
                      required: false,
                      type: :string

        def document(artifact_path)
          artifact = Templates::Utils.lookup_module(artifact_path)
          generator = Templates::Utils.lookup_module(options[:generator])
          params = options[:parameters] && ::JSON.parse(options[:parameters], symbolize_names: true)

          say(generator.show(artifact, params))
        end

        private

        def _format(artifact, render, format, artifact_options, render_parameters)
          format.format(
            render.view_for(
              artifact.new(artifact_options),
              render_parameters
            ).to_rendered
          )
        end

        def _as_string(obj)
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

        def _artifact_options
          ::JSON.parse(options[:options] || _as_string(STDIN), symbolize_names: true)
        end

        def _render_parameters
          options[:render_parameters] && ::JSON.parse(
            options[:render_parameters],
            symbolize_names: true
          )
        end
      end
    end
  end
end
