class Task < ApplicationRecord
  belongs_to :group
  has_one :finish, dependent: :destroy

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to :type

  validates :content, presence: true
  validates :type_id, numericality: { other_than: 1 }
end
