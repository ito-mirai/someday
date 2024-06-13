# README
# アプリケーション名
ソノウチ
# アプリケーションについて
### コンセプト
掃除や洗濯、買い物、申請、手続きなど「いつかやろう」「そのうちやろう」と思っていたことを、そのうちやるための対話型リマインダーアプリ
### 特徴
- AIを用いたタスクの作成、分析
- LINEを使ったAIとのチャット機能と通知（未実装）
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
# 利用方法
## タスクを作成する
##### タスクは、AI（chatGPT）との対話によって生成されます。  

#### タスク作成までの流れ

1. トップページのヘッダーにある「タスクを考えて！」を押下します。  
[![Image from Gyazo](https://i.gyazo.com/d18b37eedc61c8570bc8119b16527e2a.png)](https://gyazo.com/d18b37eedc61c8570bc8119b16527e2a)  

2. メッセージ欄に困っていることや、やろうと思っていたことなどを入力して送信してください。  
[![Image from Gyazo](https://i.gyazo.com/ef982469cc454aa0d8115e1d4081b627.png)](https://gyazo.com/ef982469cc454aa0d8115e1d4081b627)  
  
3. AIの返信が返ってくるため、内容に応じてさらに回答しましょう。  
[![Image from Gyazo](https://i.gyazo.com/f292f8dc17df8eab163cabbe986f43b8.png)](https://gyazo.com/f292f8dc17df8eab163cabbe986f43b8)  
  
4. タスクの概要である「グループ」と個別の「タスク」が生成されると、「タスクを登録する」がメッセージ欄上部に現れるので押下します。  
[![Image from Gyazo](https://i.gyazo.com/c243c3c587042d6f7315d526d58812c0.png)](https://gyazo.com/c243c3c587042d6f7315d526d58812c0)  
  
5. チャットの内容に応じたタスクが登録されました。  
[![Image from Gyazo](https://i.gyazo.com/fff5538b831c6358d238bd6673fb907a.png)](https://gyazo.com/fff5538b831c6358d238bd6673fb907a)  
  
#### ※タスク作成のコツ  
AIの返信に対しては具体的なメッセージを送信するようにしましょう。  
AIのメッセージ欄にオレンジや赤の影がついている場合、AIはより詳細の情報を求めています。
[![Image from Gyazo](https://i.gyazo.com/6e46cfc2d89137d0c76832f2a6fc1d5a.png)](https://gyazo.com/6e46cfc2d89137d0c76832f2a6fc1d5a)

### usersテーブル（Userモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| username | string | null: false | ユーザー名称 |
| email | string | null: false | メールアドレス |
| encrypted_password | string | null: false | パスワード |

has_many :groups
has_many :tasks

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

has_one :priority
belongs_to :task

### prioritiesテーブル（Priorityモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| weight | integer | null: false | 重み付け |
| task | references | null: false, foreign_key: true | tasksテーブルの外部キー |
| finish | references | null: false, foreign_key: true | finishesテーブルの外部キー |

belongs_to :task
belongs_to :finish

### messagesテーブル（Messageモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| message | text | null: false | メッセージ内容 |
| speaker | integer | null: false | 発言者
0がユーザーで1がアプリ |
| type | integer | null:false | メッセージ属性 |