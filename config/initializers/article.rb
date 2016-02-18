Dir["#{Rails.root}/lib/redcarpet/*.rb"].each { |file| require file }

module Article
  MarkdownPipeline = HTML::Pipeline.new [
    # replace @user mentions with links
    # HTML::Pipeline::MentionFilter

    # replace relative image urls with fully qualified versions
    # HTML::Pipeline::AbsoluteSourceFilter

    # auto_linking urls in HTML
    # HTML::Pipeline::AutolinkFilter,

    # replace http image urls with camo-fied https versions
    # HTML::Pipeline::CamoFilter,

    # util filter for working with emails
    # HTML::Pipeline::EmailReplyFilter,

    # everyone loves emoji!
    # HTML::Pipeline::EmojiFilter,

    # HTML Filter for replacing http github urls with https versions.
    # HTML::Pipeline::HttpsFilter,

    # link to full size image for large images (Error)
    # HTML::Pipeline::ImageMaxWidthFilter,

    # convert markdown to html
    HTML::Pipeline::MarkdownFilter,

    # html escape text and wrap the result in a div
    # HTML::Pipeline::PlainTextInputFilter,

    # whitelist sanitize user markup
    # HTML::Pipeline::SanitizationFilter,

    # code syntax highlighter (Error)
    # HTML::Pipeline::SyntaxHighlightFilter,

    # convert textile to html
    # HTML::Pipeline::TextileFilter,

    # anchor headings with name attributes and generate Table of Contents html unordered list linking headings
    # HTML::Pipeline::TableOfContentsFilter,
  ]
end
