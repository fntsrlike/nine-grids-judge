module ApplicationHelper
  def puts_answer_label answer
    if answer.done?
      status = answer.judgement.result
      if answer.judgement.pass?
        label = "green label"
      elsif answer.judgement.reject?
        label = "red label"
      end
    else
      status = answer.status
      if answer.queue?
        label = "label"
      elsif answer.judgement?
        label = "yellow label"
      end
    end

    raw "<span class=\"ui #{label}\">#{status.capitalize}</span>"
  end

  def markdown_render(md)
    html = Article::MarkdownPipeline.call(md)[:output].to_s.html_safe
    tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p code pre img table thead tbody tr th td)
    attributes = %w(href title src class)
    return sanitize(html, tags: tags, attributes: attributes)
  end
end
