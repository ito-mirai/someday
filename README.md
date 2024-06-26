# README
# アプリケーション名
ソノウチ

# アプリケーションについて
### コンセプト
掃除や洗濯、買い物、申請、手続きなど「いつかやろう」「そのうちやろう」と思っていたことを、そのうちやるための対話型リマインダーアプリ
### 特徴
- AIを用いたタスクの作成と分析
- タスクの内容に応じた優先度の自動判定
- LINEを使ったAIとのチャット機能と通知（実装予定）

# URL
http://18.176.20.182/
## テスト用アカウント
#### BASIC認証
- ID：admin
- パスワード：0042
#### 登録済みのユーザー情報
- ユーザー名：test1
- メールアドレス：test@1.com
- パスワード：test0000
# 主な機能
## タスクを作成する
グループとタスクは、AI（chatGPT）との対話によって生成されます。  
またタスクに振り分けられるタスク属性と優先度も、タスクの内容に応じて自動で付与されます。  


#### タスク作成までの流れ

1. トップページのヘッダーにある「タスクを考えて！」を押下します。  
[![Image from Gyazo](https://i.gyazo.com/df5f16275d0f4fe7aebe37a32075138b.gif)](https://gyazo.com/df5f16275d0f4fe7aebe37a32075138b)  

2. メッセージ欄に困っていることや、やろうと思っていたことなどを入力して送信してください。  
[![Image from Gyazo](https://i.gyazo.com/b6ac0b6f70a16619c4984bb619ad575a.gif)](https://gyazo.com/b6ac0b6f70a16619c4984bb619ad575a)  
  
3. AIの返信が返ってくるため、内容に応じてさらに回答しましょう。  
[![Image from Gyazo](https://i.gyazo.com/c4d4f52cf92164e44efc0608c48ea15a.png)](https://gyazo.com/c4d4f52cf92164e44efc0608c48ea15a)  
  
4. タスクの概要である「グループ」と個別の「タスク」が生成されると、「タスクを登録する」がメッセージ欄上部に現れるので押下します。  
[![Image from Gyazo](https://i.gyazo.com/14340bfbfe439b5b5597685544b85b58.png)](https://gyazo.com/14340bfbfe439b5b5597685544b85b58)  
  
5. チャットの内容に応じたタスクが登録されました。  
[![Image from Gyazo](https://i.gyazo.com/0c4c32e6637696503e5549cee11f95b6.gif)](https://gyazo.com/0c4c32e6637696503e5549cee11f95b6)  
  
#### ※タスク作成のコツ  
AIの返信に対しては具体的なメッセージを送信するようにしましょう。  
下記の画像のように、AIのメッセージ欄にオレンジや赤の影がついている場合、AIはより詳細な情報を求めています。
[![Image from Gyazo](https://i.gyazo.com/6e46cfc2d89137d0c76832f2a6fc1d5a.png)](https://gyazo.com/6e46cfc2d89137d0c76832f2a6fc1d5a)  
  
## タスクを編集する
グループやタスクはそれぞれ「＞」ボタンを押下して表示される詳細ページで編集できます。  
[![Image from Gyazo](https://i.gyazo.com/7470d9ec510cc0ec4845df88219dc7d2.gif)](https://gyazo.com/7470d9ec510cc0ec4845df88219dc7d2)

## その他の機能
- タスクの削除
- チャットで提案されたタスクを登録前に修正
- タスク優先度判定機能  

# 今後の実装予定
- LINEでのリマインド通知機能
- 通知に対する反応に基づいた優先度の変動
- LINEを使用したチャット機能

# DB設計（実装予定も含む）
### usersテーブル（Userモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| username | string | null: false | ユーザー名称 |
| email | string | null: false | メールアドレス |
| encrypted_password | string | null: false | パスワード |

has_many :groups  
has_many :tasks
has_many :messages

### groupsテーブル（Groupモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| group_name | string | null: false | グループの名称 |
| group_memo | text |  | グループの補足 |
| user | references | null: false, foreign_key: true | userテーブルの外部キー |

has_many :tasks  
belongs_to :user

### tasksテーブル（Taskモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| content | string | null: false | タスク |
| memo | text |  | タスクの補足 |
| type_id | integer | null: false | タスクのタイプ（プルダウン） |
| user | references | null: false, foreign_key: true | userテーブルの外部キー |
| group | references | null: false, foreign_key: true | groupsテーブルの外部キー |

has_one :finish  
has_one :priority  
belongs_to :group  
belongs_to :user

### finishesテーブル（Finishモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| task | references | null: false, foreign_key: true | tasksテーブルの外部キー |

belongs_to :task

### prioritiesテーブル（Priorityモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| weight | integer | null: false | 重み付け |
| task | references | null: false, foreign_key: true | tasksテーブルの外部キー |

belongs_to :task  

### messagesテーブル（Messageモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| message | text | null: false | メッセージ内容 |
| speaker | integer | null: false | 発言者 0がユーザーで1がアプリ |
| type | integer | null:false | メッセージ属性 |
| user | references | null: false, foreign_key: true | userテーブルの外部キー |

belongs_to :user

# 開発環境
### フロントエンド
HTML, CSS
### バックエンド
Ruby, JavaScript,  
ChatGPT API
### インフラ
AWS
### テキストエディタ
Visual Studio Code
### タスク管理
Github, Notion

