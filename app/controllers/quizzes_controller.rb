class QuizzesController < ApplicationController

  # 在指定的方法執行前，先設置相關的實例變數，以省略冗贅的敘述
  before_action(:set_quiz, only: [:show, :edit, :update, :destroy])

  # Authorizing controller actions
  # Ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions
  authorize_resource

  # GET /quizzes
  def index
    @quizzes = Quiz.all.page(params[:page]).per(50)
  end

  # GET /quizzes/1
  def show
    @answer = Answer.new
    @answer.quiz = @quiz

    if can?(:manage, Quiz)
      @statistics = get_quiz_statistics
      return render(:manage)
    end

    @last_answer = @quiz.answers.find_by(user: current_user, status: [Answer.statuses[:queue], Answer.statuses[:judging]])
    @logs = @quiz.get_answer_logs_by_user(current_user.id).reverse

    # Please move this block of code to User model in the future.
    quizzes = @quiz.chapter.quizzes
    queued_answers_count = 0
    quizzes.each do |current_quiz|
      queued_answers_count += current_quiz.answers.where(user: current_user).where(status: Answer.statuses[:queue]).count
    end
    @can_submit_answer = current_user.can?(create)
    # End.
  end

  # GET /quizzes/new
  def new
    unless Chapter.exists?(number: params[:chapter])
      render(:wrong_target)
    end

    @quiz = Quiz.new
    @quiz.chapter = Chapter.find_by(number: params[:chapter])
  end

  # GET /quizzes/1/edit
  def edit
    @chapter = @quiz.chapter
  end

  # POST /quizzes
  def create
    @quiz = Quiz.new(quiz_params)
    if @quiz.save
      redirect_to(@quiz, notice: 'Quiz was successfully created.')
    else
      render(:new)
    end
  end

  # PATCH/PUT /quizzes/1
  def update
      if @quiz.update(quiz_params)
        redirect_to(@quiz, notice: 'Quiz was successfully updated.')
      else
        render(:edit)
      end
  end

  # DELETE /quizzes/1
  def destroy
    @quiz.destroy
    redirect_to(quizzes_url, notice: 'Quiz was successfully destroyed.')
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

  # 取得題目相關的統計數據
  def get_quiz_statistics
    {
      pass_submits: {value: @quiz.get_passed_submits_count, color: "green"},
      reject_submits: {value: @quiz.get_failed_submits_count, color: "red"},
      submits: {value: @quiz.get_all_submits_count, color: "blue"},
      assignees: {value: @quiz.get_all_assignee_count, color: "purple"},
      answered_assignees: {value: @quiz.get_answered_assignee_count, color: "purple"},
      silent_assignees: {value: @quiz.get_silent_assignee_count, color: "purple"}
    }
  end
end
