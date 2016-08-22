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
    @judgements = apply_scopes(Judgement).order('created_at DESC').all.page(params[:page]).per(50)
    @reviewers = Judgement.includes(:user).group(:user_id).order('COUNT(*) DESC').map(&:user)
  end

  # GET /judgements/1
  def show
  end

  # GET /judgements/new
  def new
    answer = Answer.find(params[:target])
    unless answer
      return render(:wrong_target)
    end

    if answer.done?
      return redirect_to(answers_url, alert: 'The answer has been judged.')
    end

    answer.judging!
    @judgement = Judgement.new
    @judgement.answer = answer
  end

  # GET /judgements/1/edit
  def edit
    authorize!(:update, @judgement)
  end

  # POST /judgements
  def create
    authorize!(:create, @judgement)

    @judgement = Judgement.new(judgement_params)
    @judgement.user = current_user if cannot?(:manage, Answer)

    if params[:cancel]
      @judgement.answer.queue!
      return redirect_to(answers_url, alert: 'Judgement canceled! Answer return to queue.')
    end

    if @judgement.save
      @judgement.answer.done!
      rejudge_grid
      return redirect_to(answers_url, notice: 'Judgement was successfully created.')
    end

    render(:new)
  end

  # PATCH/PUT /judgements/1
  def update
    authorize!(:update, @judgement)

    @judgement.user = current_user if cannot?(:manage, Answer)

    if @judgement.update(judgement_params)
      @judgement.answer.done!
      rejudge_grid
      return redirect_to(judgements_url, notice: 'Judgement was successfully updated.')
    end

    render(:edit, local: {judgement: @judgement})
  end

  # DELETE /judgements/1
  def destroy
    authorize!(:destroy, @judgement)

    @judgement.answer.queue!
    @judgement.destroy
    rejudge_grid

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
    grid = @judgement.answer.quiz.chapter.grids.where(user: answer.user).first
    grid.update_status
  end
end
