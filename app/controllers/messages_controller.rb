class MessagesController < ApplicationController

  def new
    @messages = Message.all
    @message = Message.new
  end

  def create
    @messages = Message.all
    
    hash = [{ role: "system", content: "あなたは優しいAIアシスタントです。優しい言葉でユーザーと対話してください" }]
    @messages.each do |message|
    
      if message.speaker == 0
        hash << {role: "user", content: message.message }
      elsif message.speaker == 1
        hash << {role: "system", content: message.message }
      end

    end

    Message.create(message_params)
    prompt = message_params[:message]
    gpt = ChatGptService.new
    hash << { role: "user", content: prompt }
    gpt_message = gpt.chat(hash)
    Message.create(message: gpt_message, speaker: 1, message_type: 0, user_id: current_user.id)
    redirect_to new_message_path
  end

  def destroy
  end

  private

  def message_params
    params.require(:message).permit(:message).merge(user_id: current_user.id, speaker: 0, message_type: 0)
  end

end
