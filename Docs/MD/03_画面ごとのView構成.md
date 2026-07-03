# 勉強くん 画面ごとのView構成

## 1. このファイルの目的

このドキュメントは、画面デザイン画像12枚・画面設計書画像13枚（一覧プレビュー1枚＋各画面設計書12枚）に対応する SwiftUI View 構成を定義する。

画面は以下の12画面を基本とする。

| No | 画面 | View名 |
|---|---|---|
| 1 | ホーム画面 | `HomeView` |
| 2 | 問題演習設定画面 | `QuizSettingView` |
| 3 | 問題演習画面 | `QuizView` |
| 4 | 回答結果画面：正解 | `AnswerResultView` |
| 5 | 回答結果画面：不正解 | `AnswerResultView` |
| 6 | 演習完了画面 | `QuizCompleteView` |
| 7 | 復習画面 | `ReviewView` |
| 8 | 問題追加画面 | `QuestionCreateView` |
| 9 | 問題一覧画面 | `QuestionListView` |
| 10 | 問題編集画面 | `QuestionEditView` |
| 11 | 学習記録画面 | `StudyRecordView` |
| 12 | 設定画面 | `SettingsView` |

注意：回答結果画面は画像上では正解・不正解の2枚だが、実装では `AnswerResultView` 1つに統合する。


補足：このドキュメント内に出てくる `AppHeader`、`TodayProgressCard`、`QuizModeCard`、`QuestionCountSelector`、`CompleteHeroView` などは、初期版では各画面内の `private subview` として実装してよい。  
複数画面で再利用することが明確になったものだけ `Components/` 配下へ移動する。

---

# 2. RootView

## 2-1. 目的

アプリ起動直後のルート画面。初期データ投入とメインタブ表示を行う。

## 2-2. 構成

```swift
struct RootView: View {
    var body: some View {
        MainTabView()
    }
}
```

## 2-3. 処理

- 初回起動時に `SampleDataSeeder` を実行する
- SwiftData の ModelContainer を利用する
- 初期問題が未投入なら `SampleQuestions.json` を取り込む

---

# 3. MainTabView

## 3-1. 目的

下部タブを管理する。

## 3-2. タブ構成

| タブ | 表示View |
|---|---|
| ホーム | `HomeView` |
| 問題演習 | `QuizSettingView` |
| 復習 | `ReviewView` |
| 記録 | `StudyRecordView` |
| 設定 | `SettingsView` |

## 3-3. 実装方針

各タブは `NavigationStack` で囲む。

```swift
TabView {
    NavigationStack { HomeView() }
        .tabItem { Label("ホーム", systemImage: "house") }

    NavigationStack { QuizSettingView() }
        .tabItem { Label("問題演習", systemImage: "checkmark.circle") }

    NavigationStack { ReviewView() }
        .tabItem { Label("復習", systemImage: "arrow.counterclockwise") }

    NavigationStack { StudyRecordView() }
        .tabItem { Label("記録", systemImage: "chart.bar") }

    NavigationStack { SettingsView() }
        .tabItem { Label("設定", systemImage: "gearshape") }
}
```

---

# 4. HomeView

## 4-1. 目的

今日の学習状況、試験日までの日数、総合正答率、連続学習日数、累計回答数を表示し、問題演習・復習へすぐ進めるようにする。

## 4-2. 使用ViewModel

```swift
HomeViewModel
```

## 4-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `AppHeader` | アプリ名、日付、必要ならベルアイコン |
| `TodayProgressCard` | 今日の回答数、目標、達成率 |
| `StatCard` | 試験日までの日数、正答率、連続学習日数、累計回答数 |
| `PrimaryButton` | 問題を解く |
| `SecondaryButton` | 復習する |
| `ShortcutButton` | 問題追加、学習記録、目標設定 |

## 4-4. アクション

| 操作 | 遷移先 |
|---|---|
| 問題を解く | `QuizSettingView` |
| 復習する | `ReviewView` |
| 問題を追加 | `QuestionCreateView` |
| 学習記録 | `StudyRecordView` |
| 目標を設定 | `GoalSettingView` |

## 4-5. 空データ表示

学習履歴が0件の場合：

```text
まずは1問解いてみましょう
```

---

# 5. QuizSettingView

## 5-1. 目的

出題方法、分野、問題数を選択し、演習を開始する。

## 5-2. 使用ViewModel

```swift
QuizSettingViewModel
```

## 5-3. State

```swift
@State private var selectedQuizMode: QuizMode = .random
@State private var selectedCategory: QuestionCategory = .all
@State private var selectedQuestionCount: Int? = 10
```

`selectedQuestionCount == nil` の場合は無制限扱いにする。

## 5-4. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `AppNavigationHeader` | 戻る、タイトル |
| `QuizModeCard` | ランダム・分野・間違えた問題 |
| `CategoryChip` | 分野選択 |
| `QuestionCountSelector` | 5問、10問、20問、無制限 |
| `PrimaryButton` | この条件で開始 |
| `ErrorMessageView` | 条件に合う問題がない場合 |

## 5-5. アクション

| 操作 | 処理 |
|---|---|
| この条件で開始 | `QuizService` で問題抽出 |
| 問題あり | `QuizView` へ遷移 |
| 問題なし | エラー表示 |

---

# 6. QuizView

## 6-1. 目的

4択問題に回答する。

## 6-2. 使用ViewModel

```swift
QuizSessionViewModel
```

## 6-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `QuizProgressBar` | 3/10問などの進捗 |
| `CategoryChip` | 問題分野 |
| `QuestionCard` | 問題文 |
| `AnswerOptionButton` | A/B/C/D の選択肢 |
| `SecondaryButton` | 演習を終了する |
| `ConfirmDialog` | 終了確認 |

## 6-4. 回答処理

```text
選択肢タップ
  → selectedOption を確定
  → 正誤判定
  → AnswerHistory保存
  → ReviewStatus更新
  → AnswerResultViewへ遷移
```

## 6-5. 注意

- 「回答する」ボタンは置かない
- 選択肢タップで即回答確定
- 未回答のまま次へ進めない
- 問題演習中は下部タブを非表示にしてよい

---

# 7. AnswerResultView

## 7-1. 目的

回答結果、正解、自分の回答、解説を表示する。

## 7-2. 正解・不正解の出し分け

```swift
struct AnswerResultView: View {
    let isCorrect: Bool
    let question: Question
    let selectedOption: AnswerOption
}
```

## 7-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `ResultCard` | 正解なら緑、不正解なら赤 |
| `AnswerCompareCard` | あなたの回答、正解 |
| `ExplanationCard` | 解説 |
| `ReviewAddedMessage` | 不正解時のみ表示 |
| `PrimaryButton` | 次の問題へ |

## 7-4. 正解時表示

```text
正解！
いいペースです！
```

## 7-5. 不正解時表示

```text
不正解
復習して覚えましょう
この問題は復習リストに追加されました
```

## 7-6. アクション

| 操作 | 処理 |
|---|---|
| 次の問題へ | 次の問題があれば `QuizView` |
| 次の問題へ | 最後なら `QuizCompleteView` |

---

# 8. QuizCompleteView

## 8-1. 目的

今回の演習結果を表示し、次の学習行動へ誘導する。

## 8-2. 使用ViewModel

```swift
QuizSessionViewModel
```

## 8-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `CompleteHeroView` | トロフィー、演習完了 |
| `ResultSummaryCard` | 解いた問題数、正解数、不正解数、正答率 |
| `GoalProgressCard` | 今日の目標達成率 |
| `ReviewCountCard` | 復習登録された問題数 |
| `PrimaryButton` | もう一度解く |
| `SecondaryButton` | 復習する |
| `SecondaryButton` | ホームへ戻る |

## 8-4. アクション

| 操作 | 遷移先 |
|---|---|
| もう一度解く | `QuizSettingView` |
| 復習する | `ReviewView` |
| ホームへ戻る | `HomeView` |

---

# 9. ReviewView

## 9-1. 目的

復習対象の問題を確認し、復習演習を開始する。

## 9-2. 使用ViewModel

```swift
ReviewViewModel
```

## 9-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `AppNavigationHeader` | 戻る、タイトル |
| `ReviewSummaryCard` | 復習する問題数 |
| `ReviewFilterMenu` | すべて、最近、分野別 |
| `ReviewQuestionRow` | 問題文、分野、間違えた日、回数 |
| `EmptyStateView` | 復習対象なし |
| `PrimaryButton` | 復習を開始する |

## 9-4. アクション

| 操作 | 処理 |
|---|---|
| 復習を開始 | 復習対象から問題セット作成 |
| 復習対象あり | `QuizView` へ遷移 |
| 復習対象なし | 空状態表示 |

---

# 10. QuestionCreateView

## 10-1. 目的

ユーザーが4択問題を追加できるようにする。

## 10-2. 使用ViewModel

```swift
QuestionFormViewModel
```

## 10-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `AppNavigationHeader` | 戻る、タイトル「問題を追加」 |
| `QuestionFormView` | 入力フォーム本体 |
| `PrimaryButton` | 保存する |
| `SecondaryButton` | キャンセル |
| `ErrorMessageView` | バリデーションエラー |

## 10-4. 入力項目

- 問題文
- 選択肢A
- 選択肢B
- 選択肢C
- 選択肢D
- 正解
- 分野
- 解説

## 10-5. 保存処理

```text
保存する
  → バリデーション
  → Question作成
  → sourceType = userCreated
  → 保存完了
  → 問題一覧 or 前画面へ戻る
```

---

# 11. QuestionListView

## 11-1. 目的

登録済み問題を検索・絞り込み・編集できるようにする。

## 11-2. 使用ViewModel

```swift
QuestionListViewModel
```

## 11-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `SearchBar` | 問題文検索 |
| `CategoryFilterPicker` | 分野絞り込み |
| `QuestionSourceSegment` | すべて、初期問題、追加問題 |
| `QuestionListRow` | 問題カード |
| `FloatingAddButton` | 問題追加 |
| `EmptyStateView` | 問題なし |

## 11-4. アクション

| 操作 | 遷移先 |
|---|---|
| 問題カードタップ | `QuestionEditView` |
| ＋問題を追加 | `QuestionCreateView` |

---

# 12. QuestionEditView

## 12-1. 目的

既存問題を編集・削除する。

## 12-2. 使用ViewModel

```swift
QuestionFormViewModel
```

## 12-3. 表示コンポーネント

`QuestionCreateView` と同じ `QuestionFormView` を使い回す。

## 12-4. ボタン

| ボタン | 処理 |
|---|---|
| 変更を保存 | 問題を更新 |
| 削除する | 確認ダイアログ表示 |

## 12-5. 削除仕様

- 初期問題は削除不可
- ユーザー追加問題は削除可能
- 削除は `isDeleted = true` の論理削除

---

# 13. StudyRecordView

## 13-1. 目的

学習状況を数字とグラフで表示する。

## 13-2. 使用ViewModel

```swift
StudyRecordViewModel
```

## 13-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `StatCardGrid` | 累計回答数、正解数、不正解数、総合正答率 |
| `RecordChartTab` | 日別回答数、分野別正答率、目標達成率 |
| `DailyAnswerBarChart` | 日別回答数 |
| `CategoryAccuracyChart` | 分野別正答率 |
| `GoalProgressChart` | 目標達成率 |
| `EmptyStateView` | 回答履歴なし |

## 13-4. 初期表示

```text
日別回答数
```

---

# 14. GoalSettingView

## 14-1. 目的

試験日、1日の目標回答数、目標総回答数、目標正答率を設定する。

## 14-2. 使用ViewModel

```swift
GoalSettingViewModel
```

## 14-3. 入力項目

| 項目 | 初期値 |
|---|---|
| 試験日 | 未設定 |
| 1日の目標回答数 | 10問 |
| 目標総回答数 | 300問 |
| 目標正答率 | 80% |

## 14-4. アクション

| 操作 | 処理 |
|---|---|
| 目標を保存 | バリデーション後に保存 |

---

# 15. SettingsView

## 15-1. 目的

目標設定、問題一覧、データリセット、アプリ情報へ移動できるようにする。

## 15-2. 使用ViewModel

```swift
SettingsViewModel
```

## 15-3. 表示コンポーネント

| コンポーネント | 内容 |
|---|---|
| `SettingsRow` | メニュー行 |
| `AppInfoCard` | アプリ名、バージョン、利用規約、プライバシーポリシー |
| `ConfirmDialog` | データリセット確認 |

## 15-4. メニュー

| メニュー | 処理 |
|---|---|
| 目標設定 | `GoalSettingView` へ |
| 問題一覧 | `QuestionListView` へ |
| データリセット | 確認ダイアログ表示 |
| アプリ情報 | アプリ情報表示 |

## 15-5. ハンバーガーメニューについて

画面デザイン上にハンバーガーメニューがある場合でも、初期版では削除推奨。

理由：

- 下部タブと役割が重複する
- 押しても反応しない飾りは不具合に見える

残す場合は、必ずタップ時にメニュー表示を実装する。

---

# 16. View構成の実装ルール

1. 1画面1Viewを基本にする。
2. 複雑な画面は専用ViewModelを用意する。
3. 回答結果画面は正解・不正解でViewを分けない。
4. 問題追加・編集は `QuestionFormView` を共通化する。
5. 学習記録のグラフは最初は簡易表示でよい。
6. 下部タブはメイン5画面だけに表示する。
7. 問題演習中・回答結果・演習完了画面では下部タブを非表示にしてよい。
