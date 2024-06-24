class Prioritiy < ApplicationRecord

  belongs_to :task

  validates :weight, presence: true
end
