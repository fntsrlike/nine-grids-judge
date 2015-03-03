class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role?(:admin)
      can :manage, :all
    elsif user.has_role?(:manager)
      can :manage, [Chapter, Quiz, Judgement]
      can :read, Answer
    elsif user.has_role?(:student)
      can :create, Answer
      can :read, Chapter
      can :read, Quiz
      can :read, Grid do |grid|
        grid.user_id == user.id
      end
      can :read, Answer do |answer|
        answer.user_id == user.id
      end
    else
      basic_read_only
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
