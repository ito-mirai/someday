class TasksController < ApplicationController
  # ログインしていないとき、ログインページへ遷移する
  before_action :authenticate_user!

  # user.idを取得
  before_action :current_user_id

  # 特定のtaskをparamsのidから取得
  before_action :task_find, only: [:show, :update, :destroy]

  # 編集権の制限
  before_action :only_current_user, only: :show

  def index
    @tasks = Task.order("created_at DESC").where(user_id: @user)
  end

  def create
    @messages = Message.where(user_id: @user)

    todo = TodoRegistrationService.new(@messages, @user)
    todo.registration
    Message.where(user_id: @user).destroy_all

    redirect_to root_path
  end

  def show
  end

  def update
    if @task.update(task_params)
      redirect_to root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to root_path
  end

  private

  def current_user_id
    @user = current_user.id
  end

  def only_current_user
    return if @user == @task.user_id

    redirect_to root_path
  end

  def task_find
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:group_id, :content, :memo, :type_id).merge(user_id: @user)
  end
end
