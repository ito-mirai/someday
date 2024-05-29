class Group < ApplicationRecord
  belongs_to :user
  has_many :tasks

  validates :group_name, presence: true
end
