---
description: RobloxでRojoを安全にセットアップし、Studioとスクリプトを同期する手順
---

# 🎣 Roblox Rojo 安全セットアップ・スキル

このワークフローは、Roblox StudioとVS Code（Antigravity）をRojoを使って安全につなぎ、既存のスクリプトを壊さずに同期するためのものです。

## 1. Rojoエンジンの確認と準備
// turbo
1. プロジェクトフォルダに `rojo.exe` があるか確認し、なければ最新版をダウンロードして配置します。
2. `rojo.exe --version` で動作確認を行います。

## 2. Rojoサーバーの起動
// turbo
1. `./rojo.exe serve` を実行して、ポート `34872` で待機します。

## 3. 安全なスクリプト同期（お引っ越し）
Studioにすでにスクリプトがある場合は、以下の手順で「安全なお引っ越し」を行います。

1. **スクリプトの吸い出し**: Studioにあるスクリプトの中身をコピーし、VS Codeの `src/Server` や `src/Shared` に保存します。
2. **管理看板の設置**: 保存したスクリプトの1行目に `-- [Rojo管理] このスクリプトはVS Codeで編集してね！` というコメントを追加します。
3. **設定の調整**: `default.project.json` を書き換え、Studio側の配置場所（ServerScriptService直下など）と一致させます。

## 4. Studio側での接続と整理
1. Roblox Studioで 「Connect」 を押します。
2. スクリプトが2つ（双子）になった場合、**看板（[Rojo管理]）がない方**を安全に削除するようユーザーに促します。

## 5. 同期確認テスト
1. VS Code側でコメントや初期値を少し書き換え、Studio側が連動して変わることを確認して完了です！
