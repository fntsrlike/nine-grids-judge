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

  # GET /answers
  def index
    if can?(:create, Judgement)
      status = [Answer.statuses[:queue], Answer.statuses[:judgement]]
      @answers = apply_scopes(Answer).where(status: status).judge_piority
      @statistics = get_answers_statistics
      @statistics_today = get_answers_statistics_today
    else
      @answers = Answer.where(user_id: current_user.id).order("created_at DESC")
    end
    @answers = @answers.page(params[:page]).per(50)
  end

  # GET /answers/1
  def show
  end

  # GET /answers/new
  def new
    has_target = !params[:target].nil?
    is_target_valid = Quiz.exists?(id: params[:target])
    @has_quiz_param = has_target && is_target_valid

    if @has_quiz_param
      @quiz = Quiz.find(params[:target])
    end
    @answer = Answer.new
  end

  # GET /answers/1/edit
  def edit
  end

  # POST /answers
  def create
    @answer = Answer.new(answer_params)
    @answer.user_id = current_user.id if cannot?(:manage, Answer)
    @quiz = Quiz.find(@answer.quiz_id)
    @has_quiz_param = !@quiz.nil?
    authorize!(:create, @answer)

    if params.has_key?(:preview)
      @preview = true
      render :new
    elsif @answer.save
      @answer.queue!
      redirect_to(@quiz.chapter, notice: 'Answer was successfully created.')
    else
      render(:new, {answer: @answer})
    end
  end

  # PATCH/PUT /answers/1
  def update
    if @answer.update(answer_params)
      redirect_to(@answer, notice: 'Answer was successfully updated.')
    else
      render(:edit)
    end
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
  def get_answers_statistics
    all_count = Answer.count
    judged_count = Judgement.count
    pass_count = Judgement.joins(:answer).where(result: Judgement.results[:pass]).count
    reject_count = Judgement.joins(:answer).where(result: Judgement.results[:reject]).count

    {
      all: {value: all_count, color: :blue},
      judged: {value: judged_count, color: :purple},
      pass: {value: pass_count, color: :green},
      reject: {value: reject_count, color: :red}
    }
  end

  # 取得僅限於今日解答的統計數據
  def get_answers_statistics_today
    new_count = Answer.today.count
    judged_count = Judgement.today.count
    pass_count = Judgement.joins(:answer).where(result: Judgement.results[:pass]).today.count
    reject_count = Judgement.joins(:answer).where(result: Judgement.results[:reject]).today.count

    {
      new: {value: new_count, color: :blue},
      judged: {value: judged_count, color: :purple},
      pass: {value: pass_count, color: :green},
      reject: {value: reject_count, color: :red}
    }
  end
end
