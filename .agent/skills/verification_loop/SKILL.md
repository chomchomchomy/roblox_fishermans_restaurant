---
name: verification-loop
description: コード変更後に、ビルド・型・テスト・セキュリティを一貫して検証するループ。
---

# Verification Loop Skill

コードの変更が完了した直後に、品質ゲートを通過しているかを確認するための包括的な検証システムです。

## 使用タイミング
- 新機能の実装完了後
- PRの作成やGitへのプッシュ前
- リファクタリングによる予期せぬ影響の確認時

## 検証フェーズ

### 1. ビルド検証 (Build Check)
プロジェクトが正常にコンパイル・ビルドできるかを確認します。
- `npm run build` や `python -m compileall` など。

### 2. 型チェック (Type Check)
静的解析でエラーがないかを確認します。
- TypeScript: `npx tsc --noEmit`
- Python: `pyright .`

### 3. テスト実行 (Test Suite)
既存および新規のテストケースを実行します。
- カバレッジ目標: 80%以上

### 4. セキュリティ・スキャン (Security Scan)
意図しない情報の露出がないかを確認します。
- APIキーの漏洩チェック: `sk-`, `api_key` などのワードをソースコードから検索。
- デバッグコードの消し忘れチェック: `console.log`, `print` など。

### 5. 差分レビュー (Diff Review)
`git diff` を使い、自分が意図しない変更（不要なスペースの削除や誤ったファイルの編集）が含まれていないか最終確認します。

## 出力レポート形式
検証後、私は以下の形式で報告します：

```
Verification Report
==================
Build:    [PASS/FAIL]
Types:    [PASS/FAIL]
Tests:    [PASS/FAIL] (X/Y passed)
Security: [CLEAN/ISSUE FOUND]
Overall:  [READY/NOT READY]
```

## 運用ルール
「書きっぱなし」にせず、必ずこのループを回した結果を添えて、あなたに実装完了を伝えます。
