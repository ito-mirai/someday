class MessagesController < ApplicationController
  # ログインしていないとき、ログインページへ遷移する
  before_action :authenticate_user!

  # 全てのmessageを取得する
  before_action :messages_all, only: [:new, :create]

  def new
    @message = Message.new
  end

  def create
    # ユーザーとAIの双方のメッセージが正常に保存された時のみ完了する
    ActiveRecord::Base.transaction do
      # ユーザーのメッセージを保存
      user_message = Message.new(message_create_params)
      user_message.save!

      # ChatGptServiceでの処理
      user_message = message_create_params[:message]
      gpt = ChatGptService.new
      pronpts = gpt.chinese_room(@messages, user_message)

      # AIのメッセージを保存
      pronpts.each do |pronpt|
        gpt_message = Message.new(message: pronpt[:message], speaker: 1, message_type: pronpt[:message_type],
                                  user_id: current_user.id)
        gpt_message.save!
      end
    end
    redirect_to new_message_path
  end

  def update
    message = Message.find(params[:id])

    if message.update(message_update_params)
      redirect_to new_message_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Message.where(user_id: current_user.id).destroy_all
    redirect_to new_message_path
  end

  private

  def messages_all
    @messages = Message.where(user_id: current_user.id)
  end

  def message_create_params
    params.require(:message).permit(:message).merge(user_id: current_user.id, speaker: 0, message_type: 0)
  end

  def message_update_params
    params.require(:message).permit(:message, :speaker, :message_type).merge(user_id: current_user.id)
  end
end
