class GroupsController < ApplicationController
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to new_task_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to root_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to root_path
  end

  private

  def group_params
    params.require(:group).permit(:group_name, :group_memo).merge(user_id: current_user.id)
  end

end
