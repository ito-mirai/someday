# README

### usersテーブル（Userモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| username | string | null: false | ユーザー名称 |
| email | string | null: false | メールアドレス |
| encrypted_password | string | null: false | パスワード |

has_many :groups

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
| group | references | null: false, foreign_key: true | groupsテーブルの外部キー |

has_one :finish
has_one :priority
belongs_to :group

### finishesテーブル（Finishモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| task | references | null: false, foreign_key: true | tasksテーブルの外部キー |

has_one :priority
belongs_to :task

### prioritiesテーブル（prioritiyモデル）

| カラム名 | データ型 | オプション | 備考 |
| --- | --- | --- | --- |
| weight | integer | null: false | 重み付け |
| task | references | null: false, foreign_key: true | tasksテーブルの外部キー |
| finish | references | null: false, foreign_key: true | finishesテーブルの外部キー |

belongs_to :task
belongs_to :finish