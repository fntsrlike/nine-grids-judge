class QuizzesController < ApplicationController
  before_action :set_quiz, only: [:show, :edit, :update, :destroy]
  authorize_resource

  # GET /quizzes
  # GET /quizzes.json
  def index
    @quizzes = Quiz.all.page(params[:page]).per(50)
  end

  # GET /quizzes/1
  # GET /quizzes/1.json
  def show
    @answer = Answer.new
    @last_answer = Answer.where(quiz_id: @quiz.id, user_id: current_user.id, status: [Answer.statuses[:queue], Answer.statuses[:judgement]]).first
    @logs = @quiz.get_answer_logs_by_user(current_user.id).reverse
  end

  # GET /quizzes/new
  def new
    new_params
    @quiz = Quiz.new
  end

  # GET /quizzes/1/edit
  def edit
    @chapter = @quiz.chapter
  end

  # POST /quizzes
  # POST /quizzes.json
  def create
    @quiz = Quiz.new(quiz_params)

    respond_to do |format|
      if @quiz.save
        format.html { redirect_to @quiz, notice: 'Quiz was successfully created.' }
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { render :new }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quizzes/1
  # PATCH/PUT /quizzes/1.json
  def update
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to @quiz, notice: 'Quiz was successfully updated.' }
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1
  # DELETE /quizzes/1.json
  def destroy
    @quiz.destroy
    respond_to do |format|
      format.html { redirect_to quizzes_url, notice: 'Quiz was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quiz
      @quiz = Quiz.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quiz_params
      params.require(:quiz).permit(:title, :content, :reference, :chapter_id)
    end

    def new_params
      has_chapter = !params[:chapter].nil?
      is_chapter_valid = Chapter.exists? number: params[:chapter]
      @has_chapter_param = has_chapter && is_chapter_valid

      if @has_chapter_param
        @chapter = Chapter.where(number: params[:chapter]).first
      end
    end
end
