class TaskDecomposerService

  def self.decomposer(messages, user)
    group = messages.where(message_type: 1)
    tasks = messages.where(message_type: 3)

    ActiveRecord::Base.transaction do

      # グループの登録
      new_group = Group.new(group_name: group[0][:message], group_memo: "", user_id: user)
      new_group.save!

      # タスクの生成に向けたメッセージの非知性的分解
      task_array = tasks[0][:message].split("\n")

      # タスクの登録
      task_array.each do |task|
        task = task.delete_prefix("・")
        new_task = Task.new(group_id: new_group.id, content: task, memo: "", type_id: 2, user_id: user)
        new_task.save!
      end
    end
  end
end