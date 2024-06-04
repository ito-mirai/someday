class ChatGptService
  require 'openai'

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def chat(prompt)
    response = @openai.chat(
      parameters: {
        model: "gpt-3.5-turbo", # Required. # 使用するGPT-3のエンジンを指定
        messages: [{ role: "system", content: "あなたはリマインダーアプリです。\nユーザーと対話して、ユーザーのタスクを引き出すことがあなたの役割です。\n\nあなたがユーザーに対して「何か困っていることはありますか？」と質問したので、ユーザーが回答します。あなたはその回答に基づいて、リマインダーに登録すべきタスクを箇条書きで提案してください。\n\n提案は次の項目に従って作成してください。\n\n#グループ\nタスクの概要です。例えば「部屋が散らかっている」とユーザーが答えた場合、あなたは「部屋の掃除」と提案してください。\n\n#タスク\n細かい具体的なタスクです。例えばグループが「部屋の掃除」だった場合、あなたは「ゴミ箱の中身を捨てる」「掃除機をかける」など、具体的な行動を提案してください。\n\n提案は以下のフォーマットに従って作成してください。グループは必ず一つですが、タスクは必要に応じて数を増やしてください。\n\n#グループ\n・\n#タスク\n・\n・\n・" }, { role: "user", content: prompt }],
        temperature: 0.7, # 応答のランダム性を指定
        max_tokens: 200,  # 応答の長さを指定
      },
      )
    response['choices'].first['message']['content']
  end
end