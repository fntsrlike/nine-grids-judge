class ChaptersController < ApplicationController
  before_action :set_chapter, only: [:show, :edit, :update, :destroy]
  authorize_resource

  # GET /chapters
  # GET /chapters.json
  def index
    @chapters = Chapter.all
  end

  # GET /chapters/1
  # GET /chapters/1.json
  def show
    if can? :manage, Quiz
      @quizzes = Quiz.where( :chapter_id => @chapter.id )
    elsif can? :create, Answer
      if !Grid.exists?( :user_id => current_user.id, :chapter_id => @chapter.id )
        set_quizzes_of_grids
      end
      @quizzes = get_quizzes_of_grids
      @quiz_status = get_quizzes_status @quizzes
    end
  end

  # GET /chapters/new
  def new
    @chapter = Chapter.new
  end

  # GET /chapters/1/edit
  def edit
  end

  # POST /chapters
  # POST /chapters.json
  def create
    @chapter = Chapter.new(chapter_params)

    respond_to do |format|
      if @chapter.save
        format.html { redirect_to @chapter, notice: 'Chapter was successfully created.' }
        format.json { render :show, status: :created, location: @chapter }
      else
        format.html { render :new }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chapters/1
  # PATCH/PUT /chapters/1.json
  def update
    respond_to do |format|
      if @chapter.update(chapter_params)
        format.html { redirect_to @chapter, notice: 'Chapter was successfully updated.' }
        format.json { render :show, status: :ok, location: @chapter }
      else
        format.html { render :edit }
        format.json { render json: @chapter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chapters/1
  # DELETE /chapters/1.json
  def destroy
    @chapter.destroy
    respond_to do |format|
      format.html { redirect_to chapters_url, notice: 'Chapter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chapter
      @chapter = Chapter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def chapter_params
      params.require(:chapter).permit(:number, :title, :decription, :weight, :status)
    end

    def get_quizzes_of_grids
      grids = Grid.where( :user_id => current_user.id, :chapter_id => @chapter.id ).last
      return grids.get_quizzes
    end

    def set_quizzes_of_grids
      quizzes = Quiz.where(:chapter_id => @chapter.id).pluck(:id).shuffle[0..8]
      grids = Grid.new( :user_id => current_user.id, :chapter_id => @chapter.id )
      attributes = {}
      for i in 1..9
        attributes["quiz_#{i}"] = quizzes[i-1]
      end
      grids.update(attributes)
    end

    def get_quizzes_status quizzes
      status = [0,0,0,0,0,0,0,0,0]
      quizzes.each_with_index do |quiz, index|
        if Answer.joins(:judgement).exists?(quiz_id: quiz.id, user_id: current_user.id, status: 2, judgements: { result: 1 })
          status[index] = 2
        elsif Answer.exists?(:quiz_id => quiz.id, :user_id => current_user.id, :status => 1)
          status[index] = 1
        else
          status[index] = 0
        end
      end
      return status
    end
end
