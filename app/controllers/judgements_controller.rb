class JudgementsController < ApplicationController

  # 在指定的方法執行前，先設置相關的實例變數，以省略冗贅的敘述
  before_action(:set_judgement, only: [:show, :edit, :update, :destroy])

  # Authorizing controller actions
  # Ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions
  authorize_resource

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  has_scope(:chapter)
  has_scope(:quiz)
  has_scope(:examinee)
  has_scope(:reviewer)
  has_scope(:result)
  has_scope(:passed, type: :boolean)
  has_scope(:rejected, type: :boolean)
  has_scope(:period_from)
  has_scope(:period_end)
  has_scope(:answer)
  has_scope(:judgement)

  # GET /judgements
  def index
    @judgements = apply_scopes(Judgement).order("created_at DESC").all.page(params[:page]).per(50)
    @reviewers = Judgement.select("user_id, count(user_id) as num").group("user_id").order("num DESC").all
  end

  # GET /judgements/1
  def show
  end

  # GET /judgements/new
  def new
    has_target = !params[:target].nil?
    is_target_valid = Answer.exists?(id: params[:target])
    @has_answer_param = has_target && is_target_valid

    if @has_answer_param
      @answer = Answer.find(params[:target])
      if !@answer.done?
        @answer.judgement
      else
        redirect_to(answers_url, alert: 'The answer has been judged.')
      end
    end
    @judgement = Judgement.new
    @logs = @answer.quiz.get_answer_logs_by_user(@answer.user_id)
  end

  # GET /judgements/1/edit
  def edit
    authorize! :update, @judgement
    @answer = @judgement.answer
    @logs = @answer.quiz.get_answer_logs_by_user(@answer.user_id)
  end

  # POST /judgements
  def create
    @judgement = Judgement.new(judgement_params)
    @judgement.user_id = current_user.id if cannot?(:manage, Answer)
    authorize!(:create, @judgement)

    if !params[:cancel].nil?
      Answer.find(@judgement.answer_id).queue!
      redirect_to(answers_url, alert: 'Judgement canceled! Answer return to queue.')
    elsif @judgement.save
      @judgement.answer.done!
      rejudge_grid
      redirect_to(answers_url, notice: 'Judgement was successfully created.')
    else
      render(:new)
    end
  end

  # PATCH/PUT /judgements/1
  def update
    authorize!(:update, @judgement)
    @judgement.user_id = current_user.id if cannot?(:manage, Answer)

    if @judgement.update(judgement_params)
      @judgement.answer.done!
      rejudge_grid
      redirect_to(judgements_url, notice: 'Judgement was successfully updated.')
    else
      render(:edit, local: {judgement: @judgement})
    end
  end

  # DELETE /judgements/1
  def destroy
    authorize!(:destroy, @judgement)
    @judgement.answer.queue!
    rejudge_grid
    @judgement.destroy
    redirect_to(judgements_url, notice: 'Judgement was successfully destroyed.')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_judgement
    @judgement = Judgement.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def judgement_params
    params.require(:judgement).permit(:answer_id, :user_id, :content, :result, :cancel)
  end

  # 重新判定該判定所屬的九宮格的通過狀態
  def rejudge_grid
    answer = @judgement.answer
    grid = Grid.where(user_id: answer.user.id, chapter_id: answer.quiz.chapter_id ).first
    grid.update_status
  end
end
