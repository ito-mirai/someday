class ChatGptService
  require 'openai'

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  # AIと会話する
  def chinese_room(messages, user_message)
    @messages = messages
    @user_message = user_message
    pronpt
  end

  private

  #-------------------------------------------------------------

  # プロンプトの生成
  def pronpt

    # AIの初期性格を規定
    @prompt = [{ role: "system", content: "あなたはリマインダーアプリです。\nユーザーと対話して、ユーザーのタスクを引き出すことがあなたの役割です。\n\nあなたがユーザーに対して「何か困っていることはありますか？」と質問したので、ユーザーが回答します。あなたはその回答に基づいて、リマインダーに登録すべきタスクの概要を提案してください。\n\n　：返信例\n下記に、ユーザーの回答と望ましい返信例を列挙して提示します。なお提示する場合は、列挙するのではなく、一文だけ提示してください。\n\n1.「部屋が散らかっている」と、ユーザーが回答した場合\n部屋の整理をしましょう\n部屋の掃除をしましょう\n\n2.「リンスがない」と、ユーザーが回答した場合\nリンスを買いましょう\n日用品を買いに行きましょう\n\n3.「携帯料金の支払い用紙が来ている」と、ユーザーが回答した場合\n料金の支払いを済ませましょう" }]

    @gpt_array = []
    if @messages.count == 1
      m_phase0
      m_phase1
  
    else
      m_phase2

    end

    @gpt_array
  end

  #-------------------------------------------------------------

  # ----------タスク引き出しフェーズ----------
  def m_phase0

    # 最新のメッセージをプロンプトに追加
    @prompt << { role: "user", content: @user_message }

    # AIの回答を生成
    m_hash = {message: chat(@prompt), message_type: 1}
    @gpt_array << m_hash
  end

  # ----------タスク分析フェーズ----------
  def m_phase1

    # 会話履歴をプロンプトに含む
    history

    # AIが提案したタスクの概要（グループ）に基づいて、より具体的なタスクを引き出す質問の生成プロンプト
    @content = "あなたはユーザーの回答に対してタスクの概要を提案しました。\nより具体的なタスクを引き出すため、具体的にユーザーが何に困っているのかを引き出してください。質問を考える際は次の点に留意してください。\n1.ユーザーから具体的な回答を引き出した後、あなたは引き出した回答に基づいて具体的なタスクを提案します。それを考慮して質問を考えてください。"
    @prompt << { role: "system", content: @content }

    # 性格設定プロンプトの適用
    m_hash = {message: @content, message_type: 100}
    @gpt_array << m_hash
    # AIの回答を生成
    m_hash = {message: chat(@prompt), message_type: 2}
    @gpt_array << m_hash

  end

  # ----------タスク提案フェーズ----------
  def m_phase2

    # 会話履歴をプロンプトに含む
    history

    # AIが提案したタスクの概要（グループ）に基づいて、より具体的なタスクを引き出す質問の生成プロンプト
    @content = "あなたは具体的なタスクを引き出す質問をして、ユーザーがそれに回答しました。\nあなたはユーザーのこれまでの回答に基づいて、リマインダーに登録するタスクを箇条書きで列挙してください。"
    @prompt << { role: "system", content: @content }

    # 性格設定プロンプトの適用
    m_hash = {message: @content, message_type: 100}
    @gpt_array << m_hash
    # AIの回答を生成
    m_hash = {message: chat(@prompt), message_type: 3}
    @gpt_array << m_hash

  end

  # ----------会話履歴をプロンプトに含む処理----------
  def history
    @messages.each do |message|
      # ユーザーのメッセージ
      if message.speaker == 0
        @prompt << {role: "user", content: message.message }
      # AIのメッセージ
      elsif message.speaker == 1
        @prompt << {role: "system", content: message.message }
      end
    end
  end

  #-------------------------------------------------------------

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