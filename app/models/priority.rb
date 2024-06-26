class Priority < ApplicationRecord

  belongs_to :task

  validates :weight, presence: true
end
