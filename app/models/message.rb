class Message < ApplicationRecord
  belongs_to :user

  validates :message, presence: true
  validates :speaker, presence: true
  validates :message_type, presence: true
end
