class Task < ApplicationRecord
  belongs_to :group

  validates :content, presence: true
  validates :type_id, numericality: { other_than: 1 }
end
