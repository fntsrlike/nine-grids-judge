class AnswersController < ApplicationController

  # 在指定的方法執行前，先設置相關的實例變數，以省略冗贅的敘述
  before_action(:set_answer, only: [:show, :edit, :update, :destroy])

  # Authorizing controller actions
  # Ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions
  authorize_resource

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  has_scope(:chapter)
  has_scope(:quiz)
  has_scope(:examinee)
  has_scope(:status)
  has_scope(:period_from)
  has_scope(:period_end)
  has_scope(:answer)

  def index
    if can?(:create, Judgement)
      status = [Answer.statuses[:queue], Answer.statuses[:judgement]]
      answers = apply_scopes(Answer).where(status: status).judge_piority
    else
      answers = Answer.where(user_id: current_user.id).order("created_at DESC")
    end
    @answers = answers.page(params[:page]).per(50)
  end

  # GET /answers/1
  def show; end

  # GET /answers/new
  def new
    unless Quiz.exists?(id: params[:target])
      return redirect_to(answers_url)
    end
    @answer = Answer.new
    @answer.quiz = Quiz.find(params[:target])
  end

  # POST /answers
  def create
    @answer = Answer.new(answer_params)
    @answer.user_id = current_user.id if cannot?(:manage, Answer)
    authorize!(:create, @answer)
    if params[:preview]
      @preview = true
      return render(:new)
    end

    if @answer.save
      @answer.queue!
      return redirect_to(@answer.quiz.chapter, notice: 'Answer was successfully created.')
    end

    render(:new)
  end

  # GET /answers/1/edit
  def edit; end

  # PATCH/PUT /answers/1
  def update
    if @answer.update(answer_params)
      return redirect_to(@answer, notice: 'Answer was successfully updated.')
    end

    render(:edit)
  end

  # DELETE /answers/1
  def destroy
    @answer.destroy
    redirect_to(answers_url, notice: 'Answer was successfully destroyed.')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def answer_params
    params.require(:answer).permit(:user_id, :quiz_id, :content)
  end

  # 取得解答的統計數據
  helper_method def get_answers_statistics
    {
      all:    {color: :blue,    value: Answer.count             },
      judged: {color: :purple,  value: Judgement.count          },
      pass:   {color: :green,   value: Judgement.passed.count   },
      reject: {color: :red,     value: Judgement.rejected.count }
    }
  end

  # 取得僅限於今日解答的統計數據
  helper_method def get_answers_statistics_today
    {
        all:    {color: :blue,    value: Answer.today.count             },
        judged: {color: :purple,  value: Judgement.today.count          },
        pass:   {color: :green,   value: Judgement.passed.today.count   },
        reject: {color: :red,     value: Judgement.rejected.today.count }
    }
  end
end
