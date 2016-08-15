class JudgementsController < ApplicationController
  before_action :set_judgement, only: [:show, :edit, :update, :destroy]
  authorize_resource

  has_scope :chapter
  has_scope :quiz
  has_scope :examinee
  has_scope :reviewer
  has_scope :result
  has_scope :passed, type: :boolean
  has_scope :rejected, type: :boolean
  has_scope :period_from
  has_scope :period_end
  has_scope :answer
  has_scope :judgement

  # GET /judgements
  # GET /judgements.json
  def index
    @judgements = apply_scopes(Judgement).order("created_at DESC").all.page(params[:page]).per(50)
    @reviewers = Judgement.select("user_id, count(user_id) as num").group("user_id").order("num DESC").all
  end

  # GET /judgements/1
  # GET /judgements/1.json
  def show
  end

  # GET /judgements/new
  def new
    has_target = !params[:target].nil?
    is_target_valid = Answer.exists? id: params[:target]
    @has_answer_param = has_target && is_target_valid

    if @has_answer_param
      @answer = Answer.find(params[:target])
      if !@answer.done?
        @answer.judgement!
      else
        redirect_to answers_url, alert: 'The answer has been judged.'
      end
    end
    @judgement = Judgement.new
    @logs = @answer.quiz.get_answer_logs_by_user @answer.user_id
  end

  # GET /judgements/1/edit
  def edit
    authorize! :update, @judgement
    @answer = @judgement.answer
    @logs = @answer.quiz.get_answer_logs_by_user @answer.user_id
  end

  # POST /judgements
  # POST /judgements.json
  def create
    @judgement = Judgement.new(judgement_params)
    @judgement.user_id = current_user.id if cannot? :manage, Answer
    authorize! :create, @judgement

    respond_to do |format|
      if !params[:cancel].nil?
        Answer.find(@judgement.answer_id).queue!
        format.html { redirect_to answers_url, alert: 'Judgement canceled! Answer return to queue.' }
      elsif @judgement.save
        @judgement.answer.done!
        rejudge_grid
        format.html { redirect_to answers_url, notice: 'Judgement was successfully created.' }
        format.json { render :show, status: :created, location: @judgement }
      else
        format.html { render :new }
        format.json { render json: @judgement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /judgements/1
  # PATCH/PUT /judgements/1.json
  def update
    authorize! :update, @judgement
    @judgement.user_id = current_user.id if cannot? :manage, Answer

    respond_to do |format|
      if @judgement.update(judgement_params)
        @judgement.answer.done!
        rejudge_grid
        format.html { redirect_to judgements_url, notice: 'Judgement was successfully updated.' }
        format.json { render :show, status: :ok, location: @judgement }
      else
        format.html { render :edit }
        format.json { render json: @judgement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /judgements/1
  # DELETE /judgements/1.json
  def destroy
    authorize! :destroy, @judgement
    @judgement.answer.queue!
    rejudge_grid
    @judgement.destroy
    respond_to do |format|
      format.html { redirect_to judgements_url, notice: 'Judgement was successfully destroyed.' }
      format.json { head :no_content }
    end
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

    def rejudge_grid
      answer = @judgement.answer
      grid = Grid.where(user_id: answer.user.id, chapter_id: answer.quiz.chapter_id ).first
      grid.update_status

      return true
    end
end
