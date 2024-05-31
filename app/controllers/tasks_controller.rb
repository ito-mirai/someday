class TasksController < ApplicationController
  def index
    if user_signed_in?
      @groups = Group.where(user_id: current_user.id)
      # @tasks = Task.where(user_id: current_user.id)
    end
  end

  def new
    @task = Task.new
  end

  def create
    #将来的には配列でもらったtasksを繰り返し処理することで複数のタスクを保存できるようにしたい
    @task = Task.new(task_params)
    if @task.save
      redirect_to new_task_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to root_path
  end

  private

  def task_params
    params.require(:task).permit(:group_id, :content, :memo, :type_id).merge(user_id: current_user.id)
  end

end
