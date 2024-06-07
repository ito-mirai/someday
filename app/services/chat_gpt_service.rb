class ChatGptService
  require 'openai'

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  # AIと会話する
  def chinese_room(messages, user_message)
    @messages = messages
    @user_message = user_message

    message_phase
    pronpt
  end

  private

  # メッセージの進行具合を確認
  def message_phase
    select_message = @messages.select { |message| message.message_type <= 5 }
    @message_phase = select_message.max_by(&:message_type)[:message_type]
  end

  #-------------------------------------------------------------

  # プロンプトの生成
  def pronpt

    # AIの初期性格を規定
    @prompt = [{ role: "system", content: "あなたはリマインダーアプリです。\nユーザーと対話して、ユーザーのタスクを引き出すことがあなたの役割です。\n\nあなたがユーザーに対して「何か困っていることはありますか？」と質問したので、ユーザーが回答します。あなたはその回答に基づいて、リマインダーに登録すべきタスクの概要を提案してください。あなたはユーザーの回答を分析することができるので、抽象的な回答でも受け入れましょう。\n\n　：返信例\n下記に、ユーザーの回答と望ましい返信例を列挙して提示します。なお提示する場合は、列挙するのではなく、一文だけ提示してください。\n\n1.「部屋が散らかっている」と、ユーザーが回答した場合\n部屋の整理をしましょう\n部屋の掃除をしましょう\n\n2.「リンスがない」と、ユーザーが回答した場合\nリンスを買いましょう\n日用品を買いに行きましょう\n\n3.「携帯料金の支払い用紙が来ている」と、ユーザーが回答した場合\n料金の支払いを済ませましょう" }]

    @gpt_array = []
    if @message_phase == 0
      m_phase0
      context_check_phase
      if @context_check_result == "false"
        @gpt_array.pop
        user_message_again
      else
        m_phase1
      end
  
    elsif @message_phase == 2
      m_phase2
      context_check_phase
      task_detailed_check
      if @context_check_result == "false"
        @gpt_array.pop
        user_message_again
      elsif @task_detailed_check_result == "false"
        @gpt_array.pop
        task_detailed_up_message
      end

    end

    @gpt_array
  end

  # ------------------------------------------------------------
  # メッセージモジュール
  # ------------------------------------------------------------
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
    @content = "あなたは具体的なタスクを引き出す質問をして、ユーザーがそれに回答しました。\nあなたはユーザーのこれまでの回答に基づいて、リマインダーに登録するタスクを箇条書きで列挙してください。\n列挙する際は次の点を守ってください。\n1.箇条書きをする際の先頭の記号は・を使用する"
    @prompt << { role: "system", content: @content }

    # 性格設定プロンプトの適用
    m_hash = {message: @content, message_type: 100}
    @gpt_array << m_hash
    # AIの回答を生成
    m_hash = {message: chat(@prompt), message_type: 3}
    @gpt_array << m_hash

  end

  # ----------文脈チェックフェーズ----------
  def context_check_phase

    # 文脈チェック用プロンプトの追加（チェック結果出力時に削除）
    @prompt << {role: "system", content: "あなたは会話の文脈をチェックして、妥当な範囲の中で会話が成立しているかを確認するシステムです。\nあなたはユーザーの回答に対して返信しましたが、ユーザーの回答は、その前にあなたが発言した内容に対して大きく逸脱していないか、客観的に判断してください。\n出力は以下の通りに行なってください。\n1.回答が適切だった\nture\n2.回答が不適切だった\nfalse" }
    @context_check_result = check(@prompt)
    @prompt.pop
  end

  # ----------タスク詳細度チェックフェーズ----------
  def task_detailed_check

    # タスク詳細度チェック用プロンプトの追加（チェック結果出力時に削除）
    @prompt << {role: "system", content: "あなたはタスクを箇条書きで列挙する前に、ユーザーの回答がタスクを提案するのに十分な情報量だったのか判断するシステムです。\nユーザーの回答が曖昧な場合、より詳細な情報を引き出す必要があります。タスクを生成するのに十分であれば適切と判断し、あまりにも不十分であれば不適切と判断してください。\n出力は以下の通りに行なってください。\n1.回答が適切だった\nture\n2.回答が不適切だった\nfalse" }
    @task_detailed_check_result = check(@prompt)
    @prompt.pop
  end

  # ------------------------------------------------------------
  #      サブモジュール
  # ------------------------------------------------------------
  # ----------再確認用のメッセージを生成----------
  def user_message_again
    # ユーザーにメッセージを再送してもらうためのメッセージ生成用プロンプト
    @content = "ユーザーの回答をあなたは理解することができませんでした。ユーザーからタスクを引き出すための適切なメッセージを生成してください。"
    @prompt << { role: "system", content: @content }

    # AIの回答を生成
    m_hash = {message: chat(@prompt), message_type: 400}
    @gpt_array << m_hash

    # メッセージ生成用プロンプトの削除
    @prompt.pop
  end

  # ----------再確認用のメッセージを生成----------
  def task_detailed_up_message
    # ユーザーにメッセージを再送してもらうためのメッセージ生成用プロンプト
    @content = "ユーザーの回答はタスクを生成するのには不十分な情報量です。より詳細で具体的な情報を引き出すための適切なメッセージを生成してください。"
    @prompt << { role: "system", content: @content }

    # AIの回答を生成
    m_hash = {message: chat(@prompt), message_type: 300}
    @gpt_array << m_hash

    # メッセージ生成用プロンプトの削除
    @prompt.pop
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

  # ------------------------------------------------------------
  #      生成機構
  # ------------------------------------------------------------
  # ----------メッセージ生成機構----------
  def chat(pronpt)
    response = @openai.chat(
      parameters: {
        model: "gpt-3.5-turbo", # Required. # 使用するGPT-3のエンジンを指定
        messages: pronpt,
        temperature: 1, # 応答のランダム性を指定
        max_tokens: 500,  # 応答の長さを指定
      },
    )
    response['choices'].first['message']['content']
  end

  # ----------判断機構----------
  def check(pronpt)
    response = @openai.chat(
      parameters: {
        model: "gpt-3.5-turbo", # Required. # 使用するGPT-3のエンジンを指定
        messages: pronpt,
        temperature: 0.5, # 応答のランダム性を指定
        max_tokens: 10,  # 応答の長さを指定
      },
    )
    response['choices'].first['message']['content']
  end

end