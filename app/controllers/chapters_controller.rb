class ChaptersController < ApplicationController

  # 在指定的方法執行前，先設置相關的實例變數，以省略冗贅的敘述
  before_action(:set_chapter, only: [:show, :edit, :update, :destroy])

  # Authorizing controller actions
  # Ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions
  authorize_resource

  # GET /chapters
  def index
    @chapters = Chapter.all.page(params[:page]).per(50)
  end

  # GET /chapters/1
  def show
    if can?(:manage, Quiz)
      @quizzes = Quiz.where( :chapter_id => @chapter.id )
      @statistics = get_chapter_statistics
    elsif can?(:create, Answer)
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
  def create
    @chapter = Chapter.new(chapter_params)
    if @chapter.save
      redirect_to(@chapter, notice: 'Chapter was successfully created.')
    else
      render(:new)
    end
  end

  # PATCH/PUT /chapters/1
  def update
    if !params[:button].nil? && params[:button] == "reset_grids"
      reset_chapter_grids(@chapter.id)
      redirect_to(@chapter, notice: 'Grids of chapter was successfully reset.')
    elsif !params[:button].nil? && params[:button] == "reload_status"
      reload_chapter_status(@chapter.id)
      redirect_to(@chapter, notice: 'All of students\' chapter passing status are reloaded.')
    elsif @chapter.update(chapter_params)
      redirect_to(@chapter, notice: 'Chapter was successfully updated.')
    else
      render(:edit)
    end
  end

  # DELETE /chapters/1
  def destroy
    @chapter.destroy
    redirect_to(chapters_url, notice: 'Chapter was successfully destroyed.')
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
  def reset_chapter_grids(chapter_id)
    failed_grids = Grid.where(chapter_id: chapter_id, status: Grid.statuses[:fail])
    failed_grids.each do |grids|
      grids.reset_user_grids
    end
  end

  # Reload chapter passing status of all student
  def reload_chapter_status(chapter_id)
    Grid.where(chapter_id: chapter_id).each do | grid |
      grid.update_status
    end
  end

  # 取得章節的統計數據
  def get_chapter_statistics
    {
      pass_people: {value: @chapter.get_pass_people_count, color: "blue"},
      challengers: {value: @chapter.get_all_people_count, color: "blue"},
      queue: {value: @chapter.get_queue_count, color: "yellow"},
      pass: {value: @chapter.get_pass_submit_count, color: "green"},
      reject: {value: @chapter.get_reject_submit_count, color: "red"},
      submits: {value: @chapter.get_all_submit_count, color: "purple"},
      quizzes: {value: @chapter.get_all_quizzes_count},
    }
  end
end
