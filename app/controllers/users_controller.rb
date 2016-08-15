class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  authorize_resource

  has_scope :id
  has_scope :role
  has_scope :username
  has_scope :passed_chapter, type: :array
  has_scope :failed_chapter, type: :array

  # GET /users
  # GET /users.json
  def index
    if current_user.has_role? :admin
      @users = apply_scopes(User).all
    elsif current_user.has_role? :manager
      @users = apply_scopes(User).with_role :student
    end
    @users = @users.page(params[:page]).per(50)
  end

  # GET /users/1
  # GET /users/1.json
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
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.password = Array.new(32){[*"a".."z", *"A".."Z", *"0".."9"].sample}.join

    respond_to do |format|
      if @user.save
        role_params
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        role_params
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
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

    def get_student_statistics
      {
        all_submit: {value: @user.get_submits.count, color: "black"},
        passed_submit: {value: @user.get_passed_submits.count, color: "green"},
        failed_submit: {value: @user.get_failed_submits.count, color: "red"}
      }
    end
end
