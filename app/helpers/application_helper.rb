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
    Article::MarkdownPipeline.call(md)[:output].to_s.html_safe
  end
end
