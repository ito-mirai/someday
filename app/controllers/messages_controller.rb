class MessagesController < ApplicationController

  # 全てのmessageを取得する
  before_action :messages_all, only: [:new, :create]

  def new
    @message = Message.new
  end

  def create
    # ユーザーとAIの双方のメッセージが正常に保存された時のみ完了する
    ActiveRecord::Base.transaction do

      # ユーザーのメッセージを保存
      user_message = Message.new(message_params)
      user_message.save!

      # ChatGptServiceサービスでの処理
      gpt = ChatGptService.new

      user_message = message_params[:message]
      pronpts = gpt.chinese_room(@messages, user_message)

      # AIのメッセージを保存
      pronpts.each do |pronpt|
        gpt_message = Message.new(message: pronpt[:message], speaker: 1, message_type: pronpt[:message_type], user_id: current_user.id)
        gpt_message.save!
      end
    end
    
    redirect_to new_message_path
  end

  def destroy
  end

  private

  def messages_all
    @messages = Message.where(user_id: current_user.id)
  end

  def message_params
    params.require(:message).permit(:message).merge(user_id: current_user.id, speaker: 0, message_type: 0)
  end

end
