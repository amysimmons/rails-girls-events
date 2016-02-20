class UsersController < ApplicationController
  before_action :find_user, only: [:edit, :show, :update_user_status]

  def new
    @user = User.new
    @user.applications.build
  end

  def create
    @user = User.find_by_email(user_params[:email])

    if @user
      @user.applications.new application_params
    else
      @user = User.new user_params
    end

    # TODO: This should be a (hidden?) field element based on when the applications open
    # This is much easier for now, but will only support one event at a time
    # and the hard coding would need to be updated for the next event
    @user.applications.last.event = Event.where("title like ?", "%April 1-2, 2016%").first

    if @user.valid? && @user.applications.last.valid?
      @user.save
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
    params.require(:user).permit(:name, :email, applications_attributes: Application.allowed_params, comments: [:comment])
  end

  def application_params
    user_params[:applications_attributes]['0']
  end

  def find_user
    @user = User.find(params[:id])
  end
end
