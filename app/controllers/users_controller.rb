class UsersController < ApplicationController

  # 在指定的方法執行前，先設置相關的實例變數，以省略冗贅的敘述
  before_action(:set_user, only: [:show, :edit, :update, :destroy])

  # Authorizing controller actions
  # Ref: https://github.com/ryanb/cancan/wiki/authorizing-controller-actions
  authorize_resource

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  has_scope(:id)
  has_scope(:role)
  has_scope(:username)
  has_scope(:passed_chapter, type: :array)
  has_scope(:failed_chapter, type: :array)

  # GET /users
  def index
    if current_user.has_role?(:admin)
      @users = apply_scopes(User).all
    elsif current_user.has_role?(:manager)
      @users = apply_scopes(User).with_role(:student)
    end
    @users = @users.page(params[:page]).per(50)
  end

  # GET /users/1
  def show
    @statistics = get_student_statistics
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join

    if @user.save
      role_params
      redirect_to @user, notice: 'User was successfully created.'
    else
      render(:new)
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      role_params
      redirect_to(@user, notice: 'User was successfully updated.')
    else
      render(:edit)
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to(users_url, notice: 'User was successfully destroyed.')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
     params.require(:user).permit(:realname, :username, :email, :phone)
  end

  # 讀取表單中對使用者身份設定的參數，並且更新資料庫
  def role_params
    if params[:user_admin] == "1"
      @user.grant(:admin)
    elsif params[:user_admin] == "0"
      @user.remove_role(:admin)
    end

    if params[:user_manager] == "1"
      @user.grant(:manager)
    elsif params[:user_manager] == "0"
      @user.remove_role(:manager)
    end

    if params[:user_student] == "1"
      @user.grant(:student)
    elsif params[:user_student] == "0"
      @user.remove_role(:student)
    end
  end

  # 取得使用者提交的相關數據
  def get_student_statistics
    {
      all_submit: {value: @user.get_submits.count, color: "black"},
      passed_submit: {value: @user.get_passed_submits.count, color: "green"},
      failed_submit: {value: @user.get_failed_submits.count, color: "red"}
    }
  end
end
