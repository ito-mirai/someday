module MessagesHelper
  # subjectで指定したmessage_typeがmessagesの中に存在しているか確認するメソッド
  def check_for_message_existence(messages, subject)
    judge = messages.select { |message| message.message_type == subject }
    if judge == []
      false
    else
      true
    end
  end
end
