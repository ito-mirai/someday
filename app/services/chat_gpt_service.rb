class ChatGptService
  require 'openai'

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  # AIと会話する
  def chinese_room(messages, new_message)
    pronpts = pronpt(messages, new_message)
    chat(pronpts)
  end

  private

  # プロンプトの生成
  def pronpt(messages, new_message)

    # AIの性格を規定
    prompt = [{ role: "system", content: "あなたは優しいAIアシスタントです。優しい言葉でユーザーと対話してください" }]

    # 会話履歴をプロンプトに含む
    messages.each do |message|
      # ユーザーのメッセージ
      if message.speaker == 0
        prompt << {role: "user", content: message.message }
      # AIのメッセージ
      elsif message.speaker == 1
        prompt << {role: "system", content: message.message }
      end
    end

    # 最新のメッセージをプロンプトに追加
    prompt << { role: "user", content: new_message }

  end

  # プロンプトを踏まえてメッセージ生成
  def chat(pronpt)
    response = @openai.chat(
      parameters: {
        model: "gpt-3.5-turbo", # Required. # 使用するGPT-3のエンジンを指定
        messages: pronpt,
        temperature: 0.7, # 応答のランダム性を指定
        max_tokens: 200,  # 応答の長さを指定
      },
    )
    response['choices'].first['message']['content']
  end

end