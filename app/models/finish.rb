class Finish < ApplicationRecord
  belongs_to :task
  has_one :priority, dependent: :destroy
end
