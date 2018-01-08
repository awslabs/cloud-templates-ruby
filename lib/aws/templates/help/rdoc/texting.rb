require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Rdoc classes wrapper
        #
        # Creates simple DSL over Rdoc native classes so text blocks can be composed in idiomatic
        # Ruby way.
        module Texting
          def sub(*parts)
            item = ::RDoc::Markup::ListItem.new(nil, *parts)
            yield item if block_given?
            item
          end

          def text(str)
            ::RDoc::Markup::Paragraph.new(str)
          end

          def list(type = :BULLET, *parts)
            list = ::RDoc::Markup::List.new(type, *parts)
            yield list if block_given?
            list
          end

          def parsed_for(str)
            sub { |s| RDoc::Markup.parse(str).each { |part| s << part } }
          end

          def document(*parts)
            doc = ::RDoc::Markup::Document.new(*parts)
            yield doc if block_given?
            doc
          end
        end
      end
    end
  end
end
