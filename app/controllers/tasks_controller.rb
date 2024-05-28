class TasksController < ApplicationController
  def index
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    @task.save
  end

  private

  def task_params
    params.require(:task).permit(:group_id, :content, :memo, :type_id)
  end

end
