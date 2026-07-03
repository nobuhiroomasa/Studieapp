# 勉強くん SwiftDataモデル設計

## 1. このファイルの目的

このドキュメントは、iPhoneアプリ「勉強くん」の SwiftData モデルを定義する。

初期版ではログイン・サーバー連携を行わず、すべて端末内に保存する。

---

## 2. モデル一覧

| No | モデル | 目的 |
|---|---|---|
| 1 | `Question` | 4択問題を保存する |
| 2 | `AnswerHistory` | ユーザーの回答履歴を保存する |
| 3 | `ReviewStatus` | 復習対象・間違えた回数・連続正解数を管理する |
| 4 | `StudyGoal` | 試験日、1日の目標、総回答数、目標正答率を保存する |
| 5 | `AppSetting` | 初期データ投入済みフラグなどを保存する |

---

## 3. Enum設計

SwiftData では enum を直接保存するより、`String` または `Int` として保存し、画面側では enum に変換する方針にする。

## 3-1. AnswerOption

```swift
enum AnswerOption: String, CaseIterable, Codable, Identifiable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    var id: String { rawValue }
}
```

## 3-2. QuestionCategory

```swift
enum QuestionCategory: String, CaseIterable, Codable, Identifiable {
    case all = "すべて"
    case electricalTheory = "電気理論"
    case distributionTheory = "配電理論"
    case wiringDesign = "配線設計"
    case electricalEquipment = "電気機器"
    case wiringDevices = "配線器具"
    case tools = "工具"
    case materials = "材料"
    case constructionMethod = "施工方法"
    case inspectionMethod = "検査方法"
    case law = "法令"
    case wiringDiagram = "配線図"
    case identification = "鑑別"

    var id: String { rawValue }
}
```

## 3-2-1. QuestionCategoryの注意

`QuestionCategory.all` は、問題演習設定画面・問題一覧画面で使う「すべて」フィルター専用の値とする。  
`Question.categoryRaw` には保存しない。

問題保存時に許可する分野は、以下のような具体的な分野のみとする。

- 電気理論
- 配電理論
- 配線設計
- 電気機器
- 配線器具
- 工具
- 材料
- 施工方法
- 検査方法
- 法令
- 配線図
- 鑑別

---

## 3-3. QuizMode

```swift
enum QuizMode: String, CaseIterable, Codable, Identifiable {
    case random = "ランダム出題"
    case category = "分野を選んで出題"
    case review = "間違えた問題から出題"

    var id: String { rawValue }
}
```

## 3-4. QuestionSourceType

```swift
enum QuestionSourceType: String, Codable {
    case initial = "初期問題"
    case userCreated = "追加問題"
}
```

---

# 4. Question

## 4-1. 目的

問題文、選択肢、正解、分野、解説を保存する。

## 4-2. モデル定義案

```swift
import Foundation
import SwiftData

@Model
final class Question {
    @Attribute(.unique) var id: UUID

    var questionText: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String

    var correctOptionRaw: String
    var explanation: String
    var categoryRaw: String
    var sourceTypeRaw: String

    var isDeleted: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        questionText: String,
        optionA: String,
        optionB: String,
        optionC: String,
        optionD: String,
        correctOption: AnswerOption,
        explanation: String,
        category: QuestionCategory,
        sourceType: QuestionSourceType = .userCreated,
        isDeleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.questionText = questionText
        self.optionA = optionA
        self.optionB = optionB
        self.optionC = optionC
        self.optionD = optionD
        self.correctOptionRaw = correctOption.rawValue
        self.explanation = explanation
        self.categoryRaw = category.rawValue
        self.sourceTypeRaw = sourceType.rawValue
        self.isDeleted = isDeleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

## 4-3. Computed Property

```swift
extension Question {
    var correctOption: AnswerOption {
        AnswerOption(rawValue: correctOptionRaw) ?? .a
    }

    var category: QuestionCategory {
        QuestionCategory(rawValue: categoryRaw) ?? .electricalTheory
    }

    var sourceType: QuestionSourceType {
        QuestionSourceType(rawValue: sourceTypeRaw) ?? .userCreated
    }

    func optionText(for option: AnswerOption) -> String {
        switch option {
        case .a: return optionA
        case .b: return optionB
        case .c: return optionC
        case .d: return optionD
        }
    }
}
```

## 4-4. バリデーション

保存時には以下を必ず確認する。

| 項目 | 条件 |
|---|---|
| 問題文 | 空ではない |
| 選択肢A〜D | すべて空ではない |
| 正解 | A〜Dのいずれか |
| 分野 | 必須 |
| 解説 | 任意。ただし入力推奨 |

## 4-5. 削除仕様

問題は完全削除しない。

```swift
isDeleted = true
```

理由：

- 回答履歴との整合性を保つため
- 学習記録の集計が壊れないようにするため

---

# 5. AnswerHistory

## 5-1. 目的

ユーザーがいつ、どの問題に、何を回答し、正解したかを保存する。

## 5-2. モデル定義案

```swift
import Foundation
import SwiftData

@Model
final class AnswerHistory {
    @Attribute(.unique) var id: UUID

    var questionId: UUID
    var selectedOptionRaw: String
    var correctOptionRaw: String
    var isCorrect: Bool
    var categoryRaw: String
    var answeredAt: Date

    init(
        id: UUID = UUID(),
        questionId: UUID,
        selectedOption: AnswerOption,
        correctOption: AnswerOption,
        isCorrect: Bool,
        category: QuestionCategory,
        answeredAt: Date = Date()
    ) {
        self.id = id
        self.questionId = questionId
        self.selectedOptionRaw = selectedOption.rawValue
        self.correctOptionRaw = correctOption.rawValue
        self.isCorrect = isCorrect
        self.categoryRaw = category.rawValue
        self.answeredAt = answeredAt
    }
}
```

## 5-3. 保存タイミング

選択肢をタップした時点で回答確定とし、そのタイミングで保存する。

```text
選択肢タップ
  → 正誤判定
  → AnswerHistory保存
  → ReviewStatus更新
  → AnswerResultViewへ遷移
```

## 5-4. 集計に使う項目

| 集計内容 | 使用項目 |
|---|---|
| 累計回答数 | `AnswerHistory.count` |
| 正解数 | `isCorrect == true` |
| 不正解数 | `isCorrect == false` |
| 総合正答率 | 正解数 / 回答数 |
| 今日の回答数 | `answeredAt` が今日 |
| 分野別正答率 | `categoryRaw` ごとに集計 |
| 連続学習日数 | 回答履歴の日付を日単位で集計 |


## 5-5. 初期版で保存しないもの

初期版の `AnswerHistory` は、学習記録・正答率・復習対象判定のための集計データとして扱う。  
そのため、以下のような「当時の表示内容を完全再現するためのスナップショット」は初期版では保存しない。

```swift
var questionTextSnapshot: String
var selectedOptionTextSnapshot: String
var correctOptionTextSnapshot: String
```

将来的に「過去回答の詳細画面」を作り、問題文や選択肢が編集された後も当時の内容を完全再現したい場合は、上記のスナップショット項目を追加する。

---
---

# 6. ReviewStatus

## 6-1. 目的

間違えた問題を復習対象として管理する。

初期版の仕様：

- 一度でも不正解になった問題を復習対象にする
- 復習で2回連続正解したら復習対象から外す

## 6-2. モデル定義案

```swift
import Foundation
import SwiftData

@Model
final class ReviewStatus {
    @Attribute(.unique) var id: UUID

    var questionId: UUID
    var isReviewTarget: Bool
    var wrongCount: Int
    var consecutiveReviewCorrectCount: Int
    var lastWrongAt: Date?
    var lastReviewedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        questionId: UUID,
        isReviewTarget: Bool = true,
        wrongCount: Int = 1,
        consecutiveReviewCorrectCount: Int = 0,
        lastWrongAt: Date? = Date(),
        lastReviewedAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.questionId = questionId
        self.isReviewTarget = isReviewTarget
        self.wrongCount = wrongCount
        self.consecutiveReviewCorrectCount = consecutiveReviewCorrectCount
        self.lastWrongAt = lastWrongAt
        self.lastReviewedAt = lastReviewedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

## 6-3. 不正解時の更新仕様

```text
対象の ReviewStatus が存在しない
  → 新規作成
  → isReviewTarget = true
  → wrongCount = 1
  → consecutiveReviewCorrectCount = 0

対象の ReviewStatus が存在する
  → isReviewTarget = true
  → wrongCount += 1
  → consecutiveReviewCorrectCount = 0
  → lastWrongAt = 現在日時
```

## 6-4. 復習で正解した時の更新仕様

```text
復習モードで正解
  → consecutiveReviewCorrectCount += 1
  → lastReviewedAt = 現在日時

consecutiveReviewCorrectCount >= 2
  → isReviewTarget = false
```

## 6-5. 復習で不正解だった時の更新仕様

```text
復習モードで不正解
  → isReviewTarget = true
  → wrongCount += 1
  → consecutiveReviewCorrectCount = 0
  → lastWrongAt = 現在日時
  → lastReviewedAt = 現在日時
```

---

# 7. StudyGoal

## 7-1. 目的

ホーム画面・学習記録画面で使う目標値を保存する。

保存する目標：

- 試験日
- 1日の目標回答数
- 試験日までの目標総回答数
- 目標正答率

## 7-2. モデル定義案

```swift
import Foundation
import SwiftData

@Model
final class StudyGoal {
    @Attribute(.unique) var id: UUID

    var examDate: Date?
    var dailyQuestionTarget: Int
    var totalQuestionTarget: Int
    var targetAccuracyPercent: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        examDate: Date? = nil,
        dailyQuestionTarget: Int = 10,
        totalQuestionTarget: Int = 300,
        targetAccuracyPercent: Double = 80.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.examDate = examDate
        self.dailyQuestionTarget = dailyQuestionTarget
        self.totalQuestionTarget = totalQuestionTarget
        self.targetAccuracyPercent = targetAccuracyPercent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

## 7-3. バリデーション

| 項目 | 条件 |
|---|---|
| 試験日 | 未設定可。ただし設定する場合は過去日不可 |
| 1日の目標回答数 | 1以上 |
| 目標総回答数 | 1以上 |
| 目標正答率 | 1〜100 |

---

# 8. AppSetting

## 8-1. 目的

アプリ全体の設定や初期化状態を保存する。

初期版では、初期問題データを二重投入しないために使う。

## 8-2. モデル定義案

```swift
import Foundation
import SwiftData

@Model
final class AppSetting {
    @Attribute(.unique) var id: UUID

    var hasSeededSampleQuestions: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        hasSeededSampleQuestions: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.hasSeededSampleQuestions = hasSeededSampleQuestions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
```

---

# 9. モデル間の関係

## 9-1. 推奨方針

初期版では SwiftData の Relationship を多用せず、`questionId: UUID` で関連付ける。

理由：

- 問題削除を論理削除にするため
- 回答履歴を壊したくないため
- 後からモデル変更しやすくするため
- Codex実装時の複雑さを減らすため

## 9-2. 関係図

```text
Question
  ├─ AnswerHistory.questionId
  └─ ReviewStatus.questionId

StudyGoal
  └─ ホーム・記録画面の目標表示に使用

AppSetting
  └─ 初期データ投入済み判定に使用
```

---

# 10. 初期データ設計

`Resources/SampleQuestions.json` に少数の初期問題を定義する。

## 10-1. JSON形式

```json
[
  {
    "questionText": "オームの法則で表される関係式はどれか。",
    "optionA": "V = I × R",
    "optionB": "V = I / R",
    "optionC": "I = V × R",
    "optionD": "R = I × V",
    "correctOption": "A",
    "category": "電気理論",
    "explanation": "オームの法則は、電圧V、電流I、抵抗Rの関係を示す式で、V = I × Rです。"
  }
]
```

## 10-2. 投入条件

```text
AppSetting.hasSeededSampleQuestions == false
  → SampleQuestions.json を読み込む
  → Question として保存
  → sourceTypeRaw = "初期問題"
  → hasSeededSampleQuestions = true
```

---

# 11. データリセット仕様

設定画面の「データリセット」では以下を削除または初期化する。

## 11-1. 削除対象

- `AnswerHistory`
- `ReviewStatus`
- `StudyGoal`
- ユーザー追加問題 `Question.sourceTypeRaw == "追加問題"`

## 11-2. 削除しない対象

- 初期問題 `Question.sourceTypeRaw == "初期問題"`
- `AppSetting.hasSeededSampleQuestions`

## 11-3. 初期問題の扱い

初期問題は削除せず、もし `isDeleted = true` になっている場合はデータリセット時に `false` に戻してもよい。

---

# 12. 集計ロジック概要

## 12-1. 正答率

```text
正答率 = 正解数 / 回答数 × 100
```

回答数が0件の場合は `0%` と表示する。

## 12-2. 今日の回答数

```text
Calendar.current.isDate(answeredAt, inSameDayAs: Date())
```

## 12-3. 連続学習日数

回答履歴の `answeredAt` を日付単位で重複排除し、今日または昨日から連続している日数を計算する。

## 12-4. 分野別正答率

```text
categoryRaw ごとに AnswerHistory をグループ化
正解数 / 回答数 × 100
```

---

# 13. 実装時の注意

1. `Question` は物理削除しない。
2. `AnswerHistory` は回答ごとに必ず1件作成する。
3. `ReviewStatus` は問題ごとに最大1件を想定する。
4. `StudyGoal` は初期版では1件のみを想定する。
5. `AppSetting` も初期版では1件のみを想定する。
6. enum は raw value として保存する。
7. 問題編集時は `updatedAt` を更新する。
8. 回答履歴は集計用データとして残す。問題文・選択肢の当時表示を完全再現する仕様は初期版では対象外とする。
