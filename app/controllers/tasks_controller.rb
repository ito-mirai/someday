class TasksController < ApplicationController
  def index
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

  private

  def task_params
    params.require(:task).permit(:group_id, :content, :memo, :type_id)
  end

end
