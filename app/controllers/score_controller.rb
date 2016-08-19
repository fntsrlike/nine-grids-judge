class ScoreController < ApplicationController

  # 在指定的方法執行前，先設置相關的實例變數，以省略冗贅的敘述
  before_action(:authenticate_user!)

  # Authorizing controller actions
  # Ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions
  has_scope(:role)

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
