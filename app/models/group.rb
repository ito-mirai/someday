class Group < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy

  validates :group_name, presence: true
end
