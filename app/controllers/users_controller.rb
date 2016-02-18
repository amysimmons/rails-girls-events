class UsersController < ApplicationController
  before_action :find_user, only: [:edit, :show, :update_user_status]
  
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

  def edit
  end

  def destroy
    user = User.find(params[:id])
    if user
      user.destroy
    end
    redirect_to users_path
  end

  def index
    @users_applied = User.needs_admin_response.order(:created_at).all
    @users_responded = User.has_admin_response.order(:admin_status, :user_status, :created_at).all
    @admin_page = true
  end

  def show
    @admin = current_admin
    @admin_page = true
  end

  def update
    user = User.find params[:id]
    temp_params = user_params
    if temp_params[:comments].present?
      comment = temp_params[:comments]
      comment = comment.merge(admin_id: current_admin.id) if current_admin
      user.comments.create(comment)
      temp_params.delete(:comments)
    end

    user.assign_attributes(temp_params)

    if user.admin_status_changed?
      puts "EMAIL_LOG: admin status changed - going to send email"
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
    @user.update(user_status: params[:status])
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :gender, :track, :under_18, :previous_attendance,
      :programming_experience, :reason, :tshirt_size, :extra_info, :admin_status, :user_status, dietary_requirements: [], comments: [:comment])
  end
  
  def find_user
    @user = User.find(params[:id])
  end
end
