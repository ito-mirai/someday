class Message < ApplicationRecord
  belongs_to :user

  validates :message, presence: true
  validates :speaker, presence: true
  validates :type, presence: true

end
