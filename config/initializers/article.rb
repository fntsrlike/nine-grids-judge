Dir["#{Rails.root}/lib/redcarpet/*.rb"].each { |file| require file }

module Article
  MarkdownPipeline = ::HTML::Pipeline.new [
    ::HTML::Pipeline::RedcarpetFilter,
    #::HTML::Pipeline::SanitizationFilter,
    #::HTML::Pipeline::CamoFilter,
    ::HTML::Pipeline::ImageMaxWidthFilter,
    #::HTML::Pipeline::EmojiFilter,
    ::HTML::Pipeline::SyntaxHighlightFilter
  ], asset_root: ActionController::Base.relative_url_root
end
