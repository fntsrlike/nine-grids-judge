module Redcarpet
  module Render
    class Code < HTML
      def block_code(code, lang)
        lang ||= 'text'
        "<pre lang='#{lang}'>" \
          "<code>#{html_escape(code)}</code>" \
        "</pre>"
      end

      # There's a bug about autolink, we have to handle this by ourselves,
      # See https://github.com/vmg/redcarpet/issues/388 for more details
      def normal_text(text)
        Helpers.autolink text
      end

      private

      def html_escape(string)
        string.gsub(/['&\"<>\/]/, {
          '&' => '&amp;',
          '<' => '&lt;',
          '>' => '&gt;',
          '"' => '&quot;',
          "'" => '&#x27;',
          "/" => '&#x2F;',
        })
      end
    end
  end

  module Helpers
    def self.autolink(text)
      ActionView::Base.new.auto_link(text)
    end
  end
end
