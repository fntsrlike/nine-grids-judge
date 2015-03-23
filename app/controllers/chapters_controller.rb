class ChaptersController < ApplicationController
  before_action :set_chapter, only: [:show, :edit, :update, :destroy]
  authorize_resource

  # GET /chapters
  # GET /chapters.json
  def index
    @chapters = Chapter.all.page(params[:page]).per(50)
  end

  # GET /chapters/1
  # GET /chapters/1.json
  def show
    if can? :manage, Quiz
      @quizzes = Quiz.where( :chapter_id => @chapter.id )
      @statistics = get_chapter_statistics
    elsif can? :create, Answer
      if !Grid.exists?( :user_id => current_user.id, :chapter_id => @chapter.id )
        grids = Grid.new( :user_id => current_user.id, :chapter_id => @chapter.id )
        grids.set_quizzes_random
      end
      grids = Grid.where( :user_id => current_user.id, :chapter_id => @chapter.id ).first
      @quizzes = grids.get_quizzes
      @quiz_status = grids.get_quizzes_status
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
      if !params[:button].nil? && params[:button] == "reset_grids"
        reset_chapter_grids @chapter.id
        format.html { redirect_to @chapter, notice: 'Grids of chapter was successfully reset.' }
      elsif !params[:button].nil? && params[:button] == "reload_status"
        reload_chapter_status @chapter.id
        format.html { redirect_to @chapter, notice: 'All of students\' chapter passing status are reloaded.' }
      elsif @chapter.update(chapter_params)
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
      params.require(:chapter).permit(:number, :title, :description, :weight, :status)
    end

    # Reset no passed quizzes of no passed user's grids of the chapter
    def reset_chapter_grids chapter_id
      failed_grids = Grid.where(chapter_id: chapter_id, status: 0)
      failed_grids.each do |grids|
        grids.reset_user_grids
      end
    end

    # Reload chapter passing status of all student
    def reload_chapter_status chapter_id
      Grid.where(chapter_id: chapter_id).each do | grid |
        grid.update_status
      end
    end

    def get_chapter_statistics
      statistics = {
        all_count: @chapter.get_all_count,
        pass_count: @chapter.get_pass_count,
        pass_rate: @chapter.get_pass_rate.to_s + '%'
      }
    end
end
