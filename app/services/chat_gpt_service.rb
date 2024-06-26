class ChatGptService
  require 'openai'

  def initialize
    @openai = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'))
  end

  # AIと会話する
  def chinese_room(messages, user_message)
    @messages = messages
    @user_message = user_message

    message_phase
    pronpt
  end

  # タスクに対して適切な属性を設定
  def task_type_setting(task)
    # タスクを分析して属性を割り当てるプロンプトの適用
    @content = "あなたは提示されたタスクから適切なタスク属性を設定するシステムです。\n提示されたタスクに対して、以下に用意したタスク属性の中からどれを割り当てるのが適切か判断してください。\n\n：注意点\n判断結果を出力する際には、数字だけ出力してください。\nまた数字は半角数字を出力してください。\n数字は2〜9のみ使用してください。\n\n：例\n・提示されたタスク\nゴミは回収日に捨てる\n・出力結果\n2\n\n### タスク属性\n2：家事\n3：買い物\n4：趣味\n5：イベント\n6：健康\n7：友人・家庭\n8：財務管理\n9：その他"
    @prompt = [{ role: 'system', content: @content }]

    # タスクを提示
    @prompt << { role: 'user', content: task }
    # 分析を実行（gpt_4oを使用）
    gpt_4o_check(@prompt)
  end

  def group_priority_check(group)
    # グループを分析して優先度を判定するプロンプトの適用
    @content = "あなたはユーザーのタスクの優先度を判定するためのシステムです。\nユーザーの回答に対して、あなたは緊急度と重要度の観点から適切な優先度を答えてください。\n優先度は以下の４つの選択肢から選択しなくてはいけません。\n\n1. 緊急度が高く、重要度も高い\n2. 緊急度は低いが、重要度は高い\n3. 緊急度が高いが、重要度は低い\n4. 緊急度が低く、重要度も低い\n\n回答する際は数字だけ答えてください。\n例：1"
    @prompt = [{ role: 'system', content: @content }]

    # グループを提示
    @prompt << { role: 'user', content: group }
    # 分析を実行（gpt_4oを使用）
    gpt_4o_check(@prompt)
  end

  def task_priority_check_preparation(tasks, priority_base)
    # タスクを分析して優先度を判定するプロンプトの準備
    @content = "あなたはユーザーのタスクの優先度を判定するためのシステムです。\nこれから１つまたは複数のタスクを一覧として提示するので、その後に改めて提示されるタスクの優先度を、一覧として提示された中で相対的にどれくらいの優先度があるのか回答してください。\nこのとき回答する優先度は、#{priority_base}を基準値として、相対的に妥当な数値を0から100のあいだで割り当ててください。\n\n回答する際は数字だけ答えてください。\n例：50"
    # 同時にタスク属性の判定も行うので、プロンプトは@promptとは別の変数に代入
    @priority_prompt = [{ role: 'system', content: @content }]

    # タスクの一覧を提示
    @priority_prompt << { role: 'system', content: tasks }
  end

  def task_priority_check(content)
    # 用意したタスク優先度分析用プロンプトに判定するタスクを追加
    @priority_prompt << { role: 'user', content: content }
    # 分析を実行（gpt_4oを使用）
    gpt_4o_check(@priority_prompt)
  end

  #-------------------------------------------------------------
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
    @prompt = [{ role: 'system',
                 content: "あなたはリマインダーアプリのアシスタントです。\nユーザーと対話して、ユーザーのタスクを見つけ出すことがあなたの役割です。\n\nあなたはユーザーに対し、日常の中で困っていることや忘れていたことがないか質問したので、ユーザーが回答します。あなたはその回答に基づいて、リマインダーに登録すべきタスクの概要を提案してください。提案は必ずユーザーの回答に関連している必要があります。\n\n　：返信例\n下記に、ユーザーの回答に対する返信例を列挙して提示します。なお提示する場合は、列挙するのではなく、一文だけ提示してください。\n\n1.「部屋が散らかっている」と、ユーザーが回答した場合\n部屋の整理をしませんか？\n部屋の掃除をしましょう\n\n2.「リンスがない」と、ユーザーが回答した場合\nリンスを買う必要がありますね\n日用品を買いに行きましょう\n\n3.「携帯料金の支払い用紙が来ている」と、ユーザーが回答した場合\n重要な支払い" }]

    @gpt_array = []
    if @message_phase == 0
      m_phase0
      context_check_phase
      if @context_check_result == 'false'
        @gpt_array.pop
        user_message_again
      else
        m_phase1
      end

    elsif @message_phase == 2
      m_phase2
      context_check_phase
      task_detailed_check
      if @context_check_result == 'false'
        @gpt_array.pop
        user_message_again
      elsif @task_detailed_check_result == 'false'
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
    @prompt << { role: 'user', content: @user_message }

    # AIの回答を生成
    m_hash = { message: chat(@prompt), message_type: 1 }
    @gpt_array << m_hash
  end

  # ----------タスク分析フェーズ----------
  def m_phase1
    # 会話履歴をプロンプトに含む
    history

    # AIが提案したタスクの概要（グループ）に基づいて、より具体的なタスクを引き出す質問の生成プロンプト
    @content = "あなたはユーザーの回答に対してタスクの概要を提案しました。\nより具体的なタスクを引き出すため、具体的にユーザーが何に困っているのかを引き出してください。質問を考える際は次の点に留意してください。\n1.ユーザーから具体的な回答を引き出した後、あなたは引き出した回答に基づいて具体的なタスクを提案します。それを考慮して質問を考えてください。"
    @prompt << { role: 'system', content: @content }

    # 性格設定プロンプトの適用
    m_hash = { message: @content, message_type: 100 }
    @gpt_array << m_hash
    # AIの回答を生成
    m_hash = { message: chat(@prompt), message_type: 2 }
    @gpt_array << m_hash
  end

  # ----------タスク提案フェーズ----------
  def m_phase2
    # 会話履歴をプロンプトに含む
    history

    # AIが提案したタスクの概要（グループ）に基づいて、より具体的なタスクを引き出す質問の生成プロンプト
    @content = "あなたは具体的なタスクを引き出す質問をして、ユーザーがそれに回答しました。\nあなたはユーザーのこれまでの回答に基づいて、リマインダーに登録するタスクを箇条書きで列挙してください。必要であれば、会話を遡ってタスクを考えてください。\n列挙する際は次の点を守ってください。\n1.箇条書きをする際の先頭の記号は・を使用する"
    @prompt << { role: 'system', content: @content }

    # 性格設定プロンプトの適用
    m_hash = { message: @content, message_type: 100 }
    @gpt_array << m_hash
    # AIの回答を生成
    m_hash = { message: chat(@prompt), message_type: 3 }
    @gpt_array << m_hash
  end

  # ----------文脈チェックフェーズ----------
  def context_check_phase
    # 文脈チェック用プロンプトの追加（チェック結果出力時に削除）
    @prompt << { role: 'system',
                 content: "あなたは会話の文脈をチェックして、妥当な範囲の中で会話が成立しているかを確認するシステムです。\nあなたはユーザーの回答に対して返信しましたが、ユーザーの回答は、その前にあなたが発言した内容に対して大きく逸脱していないか、客観的に判断してください。\n出力は以下の通りに行なってください。\n1.回答が適切だった\nture\n2.回答が不適切だった\nfalse" }
    @context_check_result = check(@prompt)
    @prompt.pop
  end

  # ----------タスク詳細度チェックフェーズ----------
  def task_detailed_check
    # タスク詳細度チェック用プロンプトの追加（チェック結果出力時に削除）
    @prompt << { role: 'system',
                 content: "あなたはタスクを箇条書きで列挙する前に、ユーザーの回答がタスクを提案するのに十分な情報量だったのか判断するシステムです。\nユーザーの回答があまりにも曖昧な場合、より詳細な情報を引き出す必要があります。タスクを生成するのに十分であれば適切と判断し、あまりにも不十分であれば不適切と判断してください。\n出力は以下の通りに行なってください。\n1.回答が適切だった\nture\n2.回答が不適切だった\nfalse" }
    @task_detailed_check_result = check(@prompt)
    @prompt.pop
  end

  # ------------------------------------------------------------
  #      サブモジュール
  # ------------------------------------------------------------
  # ----------再確認用のメッセージを生成----------
  def user_message_again
    # ユーザーにメッセージを再送してもらうためのメッセージ生成用プロンプト
    @content = 'ユーザーの回答をあなたは理解することができませんでした。ユーザーからタスクを引き出すための適切なメッセージを生成してください。'
    @prompt << { role: 'system', content: @content }

    # AIの回答を生成
    m_hash = { message: chat(@prompt), message_type: 400 }
    @gpt_array << m_hash

    # メッセージ生成用プロンプトの削除
    @prompt.pop
  end

  # ----------具体性を求めるメッセージを生成----------
  def task_detailed_up_message
    # ユーザーにメッセージを再送してもらうためのメッセージ生成用プロンプト
    @content = 'ユーザーの回答はタスクを生成するのには不十分な情報量です。より詳細で具体的な情報を引き出すための適切なメッセージを生成してください。'
    @prompt << { role: 'system', content: @content }

    # AIの回答を生成
    m_hash = { message: chat(@prompt), message_type: 300 }
    @gpt_array << m_hash

    # メッセージ生成用プロンプトの削除
    @prompt.pop
  end

  # ----------会話履歴をプロンプトに含む処理----------
  def history
    @messages.each do |message|
      # ユーザーのメッセージ
      if message.speaker == 0
        @prompt << { role: 'user', content: message.message }
      # AIのメッセージ
      elsif message.speaker == 1
        @prompt << { role: 'system', content: message.message }
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
        model: 'gpt-4o',
        messages: pronpt,
        temperature: 1, # 応答のランダム性を指定
        max_tokens: 500 # 応答の長さを指定
      }
    )
    response['choices'].first['message']['content']
  end

  # ----------判断機構----------
  def check(pronpt)
    response = @openai.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: pronpt,
        temperature: 0.5, # 応答のランダム性を指定
        max_tokens: 10 # 応答の長さを指定
      }
    )
    response['choices'].first['message']['content']
  end

  # ----------高度判断機構----------
  def gpt_4o_check(pronpt)
    response = @openai.chat(
      parameters: {
        model: 'gpt-4o',
        messages: pronpt,
        temperature: 0.5, # 応答のランダム性を指定
        max_tokens: 10 # 応答の長さを指定
      }
    )
    response['choices'].first['message']['content']
  end
end
