---
name: Local-First Cloud Processing (LFCP)
description: クラウド上の大量ファイルを扱う際、API経由で直接処理せず、「ローカルに同期→分析→結果のみアップロード」することで、Quota消費とタイムアウトを回避する標準戦略。
---

# 📥 Local-First Cloud Processing (LFCP)

Google Drive、S3、SharePointなどのクラウドストレージにあるファイルをAIで分析する際、**「絶対にAPI経由でファイルを1つずつ開いて読み込まない」**ための鉄則と実装パターンです。

## 1. コアコンセプト
**"Download Once, Process Locally, Upload Result."**
（一度落として、手元で料理し、結果だけ返す）

API経由のファイル読み込みは、「遅い」「Quotaを食う」「ネットワークエラーで落ちる」の三重苦です。これを回避するため、以下の3ステップを強制します。

1.  **Sync (Batch Download)**: 対象ファイルをまとめてローカルの一時フォルダ（キャッシュ）にダウンロードする。
2.  **Local Process**: ローカルファイルに対して分析・加工を行う（高速・堅牢）。
3.  **Push (Result Upload)**: 生成されたレポートや成果物だけをクラウドに書き戻す。

## 2. 実装チェックリスト

このスキルを使用する場合、以下のフローでスクリプトを構築してください。

### Phase 1: ダウンロード（同期）
- [ ] 処理対象のフォルダ構造を確認する。
- [ ] すでにローカルに同名ファイルがある場合、タイムスタンプやハッシュで「更新が必要か」判断する（スキップ機能）。
- [ ] Google Drive APIなら `files.export` (Google Docの場合) や `files.get` (Binaryの場合) を使い、ローカルへ保存する。

### Phase 2: ローカル処理
- [ ] `os.walk` や `glob` でローカルのファイルをリストアップ。
- [ ] **Resumable Batch Protocol (RBP)** と組み合わせて、1件ずつ着実に処理する。
- [ ] エラーが出てもローカルファイルは消えないので、何度でも再試行可能にする。

### Phase 3: アップロード
- [ ] 成果物（レポートPDF、Excel、Markdown）のみを対象フォルダへアップロードする。

## 3. コードテンプレート (Python擬似コード)

```python
import os
from google_drive_manager import DriveManager # 仮のラッパー

# --- 設定 ---
REMOTE_FOLDER_ID = "xxx"
LOCAL_CACHE_DIR = "./_drive_cache"
OUTPUT_DIR = "./_output_reports"

def sync_from_drive():
    print("🌍 クラウドからファイルを同期中...")
    drive = DriveManager()
    remote_files = drive.list_files(REMOTE_FOLDER_ID)
    
    for rf in remote_files:
        local_path = os.path.join(LOCAL_CACHE_DIR, rf['name'])
        
        # すでにダウンロード済みならスキップ (キャッシュ活用)
        if os.path.exists(local_path):
            print(f"⏩ Skip (Cached): {rf['name']}")
            continue
            
        print(f"⬇️ Downloading: {rf['name']}")
        drive.download_file(rf['id'], local_path)

def process_locally():
    print("💻 ローカルで高速分析を実行中...")
    # ここからはAPIを一切叩かない
    files = os.listdir(LOCAL_CACHE_DIR)
    for f in files:
        # 重い処理
        analyze_file(os.path.join(LOCAL_CACHE_DIR, f))

def upload_results():
    print("☁️ 結果をアップロード中...")
    # ...

if __name__ == "__main__":
    os.makedirs(LOCAL_CACHE_DIR, exist_ok=True)
    
    # 1. まず手元に持ってくる
    sync_from_drive()
    
    # 2. 手元でガリガリやる
    process_locally()
    
    # 3. 結果を返す
    upload_results()
```

## 4. このスキルを使うべき場面
- **Google Drive内の大量PDF/画像解析**: APIでバイナリを何度も取得すると即死するため。
- **動画/音声処理**: ファイルサイズが大きく、ストリーミング処理が不安定な場合。
- **反復開発中**: プロンプトの調整などで同じファイルに対して何度も試行錯誤する場合（ローカルなら何度読んでもタダ）。
