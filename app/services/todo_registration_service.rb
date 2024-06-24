class TodoRegistrationService

  def initialize(messages, user)
    @group = messages.where(message_type: 1)[0][:message]
    @tasks = messages.where(message_type: 3)
    @user = user
    @gpt = ChatGptService.new
  end

  def registration
    ActiveRecord::Base.transaction do
      group_create
      group_priority
      task_create
    end
  end

  private

  def group_create
    @new_group = Group.new(group_name: @group, group_memo: '', user_id: @user)
    @new_group.save!
  end

  def group_priority
    result = @gpt.group_priority_check(@group)

    if result == "1"
      @priority_base = 80
    elsif result == "2"
      @priority_base = 60
    elsif result == "3"
      @priority_base = 40
    elsif result == "4"
      @priority_base = 20
    else
      @priority_base = 50
    end
  end

  def task_create
    # タスクの生成に向けたメッセージの非知性的分解
    task_array = @tasks[0][:message].split("\n")

    # タスクの登録
    task_array.each do |task|
      task = task.delete_prefix('・')

      # 各タスクに属性を付与する
      type_id = @gpt.task_type_setting(task)
      type_id = if 1 < type_id.to_i && type_id.to_i < 10
                  type_id.to_i
                else
                  9
                end

      new_task = Task.new(group_id: @new_group.id, content: task, memo: '', type_id:, user_id: @user)
      new_task.save!
    end
  end
end
