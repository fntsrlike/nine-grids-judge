begin
  require "redcarpet"
  rescue LoadError => _
  abort "Missing dependency 'redcarpet' for RedcarpetFilter."
end

module HTML
  class Pipeline
  # HTML Filter that converts Markdown text into HTML and converts into a
  # DocumentFragment. This is different from most filters in that it can take a
  # non-HTML as input. It must be used as the first filter in a pipeline.
  #
  # Context options:
  #   :redcarpet      => Hash    Options of Redcarpet
  #
  # This filter does not write any additional information to the context hash.
    class RedcarpetFilter < TextFilter
      def initialize(text, context = nil, result = nil)
        super text, context, result
        # @text = @text.gsub "\r", ''
      end

      # Convert Markdown to HTML using the best available implementation
      # and convert into a DocumentFragment.
      def call
                # TODO re-enable autolink after the issue solved
        options = { fenced_code_blocks: true, no_intra_emphasis: true, tables: true, with_toc_data: true, strikethrough: true, lax_spacing: true }
                options.merge! context[:redcarpet] if context[:recarpet].is_a? Hash
                html = ::Redcarpet::Markdown.new(::Redcarpet::Render::Code.new(xhtml: true, hard_wrap: true), options).render @text
        html.rstrip!
                html
      end
    end
  end
end
