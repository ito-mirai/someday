class GroupsController < ApplicationController
  # ログインしていないとき、ログインページへ遷移する
  before_action :authenticate_user!

  # 特定のgroupをparamsのidから取得
  before_action :find_group, except: :index

  # 編集権の制限
  before_action :only_current_user, only: :show

  def index
    @groups = Group.where(user_id: current_user.id)
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
  end

  def update
    if @group.update(group_params)
      redirect_to groups_path
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path
  end

  private

  def find_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:group_name, :group_memo).merge(user_id: current_user.id)
  end

  def only_current_user
    return if current_user.id == @group.user.id

    redirect_to groups_path
  end
end
