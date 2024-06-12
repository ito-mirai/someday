class Type < ActiveHash::Base
  self.data = [
    { id: 1, name: '---' },
    { id: 2, name: '家事' },
    { id: 3, name: '買い物' },
    { id: 4, name: '趣味' },
    { id: 5, name: 'イベント' },
    { id: 6, name: '健康' },
    { id: 7, name: '友人・家族' },
    { id: 8, name: '財務管理' },
    { id: 9, name: 'その他' }
  ]
  include ActiveHash::Associations
  has_many :tasks
end
