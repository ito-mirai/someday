class Prioritiy < ApplicationRecord

  belongs_to :task
  belongs_to :finish

  validates :weight, presence: true
end
