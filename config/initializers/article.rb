module Article
  class Markdown
    def self.get_instance
      @@instance ||= self.new
    end

    def initialize
      @redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::XHTML, fenced_code_blocks: true, tables: true, autolink: true )
    end

    def render(data)
      @redcarpet.render data
    end
  end
end
