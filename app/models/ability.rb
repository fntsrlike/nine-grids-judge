class Ability
  include CanCan::Ability

  def initialize(current_user)
    basic_read_only
    if !current_user.blank?
      if current_user.has_role?(:admin)
        can :manage, :all

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

      elsif current_user.has_role?(:student)
        can :read, Chapter
        can :show, Quiz
        can :read, Grid do |grid|
          grid.user_id == current_user.id
        end
        can :read, Answer do |answer|
          answer.user_id == current_user.id
        end
        can :create, Answer do |answer|
          quiz = answer.quiz
          chapter = quiz.chapter
          grid = Grid.where(chapter_id: chapter.id, user_id: current_user.id).first
          is_chapter_active = chapter.active?
          is_valid_quiz = (!grid.nil?) && (grid.get_quizzes_id.include? answer.quiz.id)
          is_not_queue = !Answer.exists?(quiz_id: answer.quiz.id, status: 0, user_id: current_user.id)
          is_quiz_passed = quiz.is_passed_by_user current_user.id

          is_chapter_active && is_valid_quiz && is_not_queue && !is_quiz_passed
        end
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

  def basic_read_only
    cannot :manage, :all
    can :read, Chapter
  end
end
