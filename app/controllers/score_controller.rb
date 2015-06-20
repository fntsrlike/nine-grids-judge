class ScoreController < ApplicationController
  before_action :authenticate_user!
  has_scope :role

  # GET /quizzes
  def index
    if params[:valid_chapter].nil?
      @users = [];
    else
      @users = apply_scopes(User).all
    end

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def score_params
     params.require(:user).permit(:realname, :username, :email, :phone)
  end
end
