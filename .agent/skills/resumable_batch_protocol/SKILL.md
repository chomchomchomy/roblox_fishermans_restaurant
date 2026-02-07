---
name: Resumable Batch Protocol (RBP)
description: 大量データを「少しずつ」「確実に」処理し、エラーや中断が発生しても「続きから」再開することで、AIリソース（Quota）の浪費を防ぐための標準実装プロトコル。
---

# ⏯️ Resumable Batch Protocol (RBP)

「AIのQuota（処理枠）は貴重である」という前提に立ち、大量処理を一度に行わず、進捗を確実に保存しながら少しずつ実行するための標準スキルです。

## 1. コアコンセプト
**"Never Lose Progress."** (進捗は絶対に失わない)

- **Chunking (小分け処理)**: 対象データを小さな塊（チャンク）に分割し、1回あたりの処理負荷を下げる。
- **Checkpointing (状態保存)**: 1件または1チャンク処理するごとに、「完了済みリスト」をファイルに書き出す。
- **Idempotency (冪等性)**: 何度実行しても、「完了済み」のものは自動的にスキップされ、結果が変わらないようにする。

## 2. 必須実装パターン (Python)

スクリプトを作成する際は、以下の構造（`ProgressManager` クラスの使用）を必須とします。

```python
import json
import os
from datetime import datetime

class ProgressManager:
    def __init__(self, tracking_file="progress_log.json"):
        self.tracking_file = tracking_file
        self.completed_ids = self._load_progress()

    def _load_progress(self):
        if os.path.exists(self.tracking_file):
            try:
                with open(self.tracking_file, "r", encoding="utf-8") as f:
                    return set(json.load(f))
            except:
                return set()
        return set()

    def mark_completed(self, item_id):
        """処理完了を記録し、即座に保存する"""
        self.completed_ids.add(str(item_id))
        self._save_progress()

    def _save_progress(self):
        temp_file = f"{self.tracking_file}.tmp"
        with open(temp_file, "w", encoding="utf-8") as f:
            json.dump(list(self.completed_ids), f)
        os.replace(temp_file, self.tracking_file) # 安全な書き込み

    def is_completed(self, item_id):
        return str(item_id) in self.completed_ids

# --- 使用例 ---
if __name__ == "__main__":
    # 1. 処理対象リスト (例: 100件のID)
    all_items = [f"item_{i}" for i in range(100)]
    
    # 2. 進捗管理の初期化
    tracker = ProgressManager("processed_items.json")
    
    # 3. 未処理のものだけを抽出
    pending_items = [i for i in all_items if not tracker.is_completed(i)]
    print(f"Total: {len(all_items)}, Completed: {len(all_items) - len(pending_items)}, Pending: {len(pending_items)}")

    # 4. バッチサイズ制限 (一度にAIに投げすぎない)
    BATCH_SIZE = 10 
    batch_to_process = pending_items[:BATCH_SIZE]

    if not batch_to_process:
        print("🎉 すべて完了しています！")
        exit()

    print(f"🚀 今回は {len(batch_to_process)} 件を処理します...")

    # 5. 処理ループ
    for item in batch_to_process:
        try:
            print(f"Processing {item}...")
            
            # === ここに実際の重い処理 (AI生成, スクレイピング等) ===
            # process_heavy_task(item)
            # ==================================================
            
            # 成功したら記録 (これさえあれば、次回はスキップされる)
            tracker.mark_completed(item)
            
        except Exception as e:
            print(f"❌ Error processing {item}: {e}")
            # エラー時は記録しない = 次回再トライする
            continue
            
    print("✅ バッチ処理完了。続きをやるには再実行してください。")
```

## 3. このスキルを使うべき場面
- **データ件数が多いとき**: 10件以上の記事生成、100件以上のURLスクレイピングなど。
- **外部API/AIを使うとき**: エラーやレート制限（Quota切れ）で止まる可能性が高い処理。
- **長時間かかる処理**: いつPCがシャットダウンしても良いようにしたい場合。

## 4. 運用ルール
1.  **JSONで状態管理**: 進捗ファイルは単純なJSONリスト形式を標準とし、人間が手で修正（リセット）できるようにする。
2.  **アトミックな書き込み**: 保存中にクラッシュしてロストしないよう、`.tmp` に書いてからリネームする手法を推奨。
3.  **ユーザーへの報告**: 開始時に「全XX件中、YY件完了済み、残りZZ件」と必ず表示する。
