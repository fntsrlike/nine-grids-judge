# 本模型主要是做整個系統的權限管理
class Ability
  # 本系統使用 CanCanCan Gem 作為權限管理的核心
  include CanCan::Ability

  # 設定當前使用者的權限
  def initialize(current_user)
    @current_user = current_user
    initialize_permission_to_basic

    if current_user.blank?
      return
    end

    # admin 為最高管理者，有所有權限
    if current_user.has_role?(:admin)
      can :manage, :all

    # manager 通常為助教，可以管理題目、裁決解答，並且能看到學生資料
    elsif current_user.has_role?(:manager)
      can :manage, [Chapter, Quiz]
      can :read, Judgement
      can :create, Judgement do |judgement|
        !Judgement.exists?(answer_id: judgement.answer.id)
      end
      can [:update, :destroy], Judgement do |judgement|
        judgement.user_id == current_user.id
      end
      can :read, Answer
      can :read, User do |user|
        user.has_role?(:student)
      end

    # student 有關看章節、題目、與自身九宮格的權限，並能答題
    elsif current_user.has_role?(:student)
      can :show, Quiz do |quiz|
        quiz.chapter.active? && can_user_read_the_quiz?(current_user, quiz)
      end
      can :read, Grid do |grid|
        grid.user_id == current_user.id
      end
      can :read, Answer do |answer|
        answer.user_id == current_user.id
      end
      can :create, Answer do |answer|
        quiz = answer.quiz
        quizzes = quiz.chapter.quizzes
        queued_answers_count = 0
        quizzes.each do |current_quiz|
          queued_answers_count += current_quiz.answers.where(user_id: current_user.id).where(status: Answer.statuses[:queue]).count
        end
        can_submit_answer = queued_answers_count < 3

        quiz.chapter.active? && can_user_read_the_quiz?(current_user, quiz) && !can_user_answer_the_quiz?(current_user, quiz) && can_submit_answer
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  protected

  # 最基本的權限，只能觀看已經開啟的章節的基本資訊
  def initialize_permission_to_basic
    cannot :manage, :all
    can :read, Chapter do |chapter|
      chapter.active?
    end
  end

  # 指定使用者是否有讀取該題目的權限
  def can_user_read_the_quiz?(user_id, quiz)
    grid = Grid.where(chapter_id: quiz.chapter.id, user_id: user_id.id).first
    (!grid.nil?) && (grid.get_quizzes_id.include? quiz.id)
  end

  # 指定使用者是否有作答該題目的權限
  def can_user_answer_the_quiz?(user_id, quiz)
    quiz.is_answer_repeat_by_user user_id
  end
end
