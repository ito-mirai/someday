# groupsテーブルとtasksテーブルの一括処理
# class GroupTask
#   include ActiveModel::Model
#   attr_accessor :group_name, :group_memo, :user_id, :content, :memo, :type_id, :group_id

#   with_options presence: true do
#     validates :group_name
#     validates :user_id
#     validates :content
#     validates :type_id, numericality: { other_than: 1 }
#     validates :group_id
#   end

#   def save
#     group = Group.create(group_name:, group_memo:, user_id:)
#     Task.create(content:, memo:, type_id:, group_id: group.id)
#   end
# end