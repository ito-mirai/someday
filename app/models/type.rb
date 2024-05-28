class Type < ActiveHash::Base
  self.data = [
    { id: 1, name: '---'},
    { id: 2, name: '生活'},
    { id: 2, name: '趣味'},
    { id: 3, name: '手続き'}
  ]
  include ActiveHash::Associations
  has_many :tasks
 end