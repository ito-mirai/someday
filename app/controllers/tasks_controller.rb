class TasksController < ApplicationController

  # ログインしていないとき、ログインページへ遷移する
  before_action :authenticate_user!

  # user.idを取得
  before_action :current_user_id

  # 特定のtaskをparamsのidから取得
  before_action :task_find, only: [:show, :update, :destroy]

  def index
    @groups = Group.where(user_id: @user)
    @tasks = Task.where(user_id: @user)
  end

  def new
    @task = Task.new
  end

  def create
    @messages = Message.where(user_id: @user)

    TaskDecomposerService.decomposer(@messages, @user)
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

  def task_find
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:group_id, :content, :memo, :type_id).merge(user_id: @user)
  end

end
