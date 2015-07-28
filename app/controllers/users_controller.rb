class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new user_params.merge(admin_status: 'applied')
    if @user.save
      @user.send_application_thanks
    end
    render :new
  end

  def destroy
    user = User.find(params[:id])
    if user
      user.destroy
    end
    redirect_to users_path
  end

  def index
    @users = User.all
    @admin_page = true
  end

  def show
    @user = User.find params[:id]
    @admin = current_admin
    @admin_page = true
  end

  def update
    user = User.find params[:id]
    # temp_params = user_params
    # if temp_params[:comments].present?
    #   user.comments.create temp_params[:comments]
    #   temp_params.delete(:comments)
    # end

    user.assign_attributes(temp_params)

    if user.admin_status_changed?
      user.send_admin_status_email
    end

    user.save
    redirect_to user_path(user)
  end

  def data
    @users = User.all
    @admin_page = true
  end

  # Left separate from update since it's not for admin
  def update_user_status
    @user = User.find params[:id]
    @user.update(user_status: params[:status])
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :gender, :track, :under_18, :previous_attendance,
      :programming_experience, :reason, :tshirt_size, :extra_info, :admin_status, :user_status, dietary_requirements: [], comments: [:comment])
  end

end
