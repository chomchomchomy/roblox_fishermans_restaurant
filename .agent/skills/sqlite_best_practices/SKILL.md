---
name: SQLite Best Practices
description: SQLiteデータベースの設計・運用において、パフォーマンス、整合性、セキュリティを確保するためのベストプラクティス集。Anthropic MCP参照実装とClaude Code Skillsの知見を融合。
---

# SQLite Best Practices Skill

## 概要

このスキルは、SQLiteデータベースを**安全**・**高速**・**堅牢**に運用するためのベストプラクティスを定義します。Anthropicの公式MCP SQLiteサーバーの知見と、Claude Code Skillsからの推奨事項を統合しています。

---

## 🔧 データベース初期化設定

すべてのSQLiteデータベース接続時に、以下のPRAGMAを設定すること：

```python
import sqlite3

def get_optimized_connection(db_path: str) -> sqlite3.Connection:
    """最適化されたSQLite接続を取得"""
    conn = sqlite3.connect(db_path)
    
    # WALモード: 並列読み書きとクラッシュ耐性向上
    conn.execute("PRAGMA journal_mode = WAL")
    
    # 同期モード: WAL使用時はNORMALで十分（高速化）
    conn.execute("PRAGMA synchronous = NORMAL")
    
    # キャッシュサイズ: 負の値はKB単位（-64000 = 64MB）
    conn.execute("PRAGMA cache_size = -64000")
    
    # 外部キー制約を有効化
    conn.execute("PRAGMA foreign_keys = ON")
    
    # 一時テーブルをメモリに保持
    conn.execute("PRAGMA temp_store = MEMORY")
    
    # mmap I/O: 大きなファイルの読み取り高速化（256MB）
    conn.execute("PRAGMA mmap_size = 268435456")
    
    return conn
```

---

## 📊 テーブル設計ルール

### 1. STRICT修飾子を使用

型安全性を強化するため、全テーブルに`STRICT`を付与：

```sql
-- ✅ 推奨
CREATE TABLE IF NOT EXISTS properties (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    price REAL NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
) STRICT;

-- ❌ 非推奨（型が曖昧になる）
CREATE TABLE properties (
    id INTEGER PRIMARY KEY,
    name TEXT,
    price REAL
);
```

### 2. WITHOUT ROWID（高パフォーマンス向け）

主キーが整数以外の場合、または複合主キーの場合に検討：

```sql
CREATE TABLE IF NOT EXISTS property_tags (
    property_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    PRIMARY KEY (property_id, tag)
) WITHOUT ROWID, STRICT;
```

### 3. 適切なインデックス設計

```sql
-- 頻繁に検索するカラムにインデックス
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties(price);

-- 複合インデックス（検索条件の順序に合わせる）
CREATE INDEX IF NOT EXISTS idx_properties_area_price 
    ON properties(area, price);

-- 部分インデックス（条件付きで高速化）
CREATE INDEX IF NOT EXISTS idx_active_properties 
    ON properties(id) WHERE status = 'active';
```

---

## 🔒 セキュリティルール

### 1. パラメータ化クエリを必須化

**絶対にSQL文字列結合を使用しない：**

```python
# ✅ 安全（パラメータ化クエリ）
cursor.execute(
    "SELECT * FROM properties WHERE name = ? AND price < ?",
    (property_name, max_price)
)

# ✅ 名前付きパラメータも可
cursor.execute(
    "SELECT * FROM properties WHERE name = :name AND price < :price",
    {"name": property_name, "price": max_price}
)

# ❌ 危険（SQLインジェクション脆弱性）
cursor.execute(f"SELECT * FROM properties WHERE name = '{property_name}'")
```

### 2. 読み取り専用接続

分析やレポート用には読み取り専用モードを使用：

```python
# 読み取り専用で開く
conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
```

---

## ⚡ パフォーマンス最適化

### 1. バッチ操作にはトランザクションを使用

```python
def insert_properties_batch(conn: sqlite3.Connection, properties: list):
    """バッチ挿入（トランザクションで高速化）"""
    cursor = conn.cursor()
    
    try:
        cursor.execute("BEGIN TRANSACTION")
        
        cursor.executemany(
            """
            INSERT INTO properties (name, price, area)
            VALUES (?, ?, ?)
            """,
            [(p["name"], p["price"], p["area"]) for p in properties]
        )
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
```

### 2. 単一クエリ優先

複数の小さなクエリより、1つの包括的なクエリを使用：

```python
# ✅ 推奨: 1回のクエリで必要なデータを取得
cursor.execute("""
    SELECT p.*, 
           COUNT(t.tag) as tag_count,
           AVG(r.rating) as avg_rating
    FROM properties p
    LEFT JOIN property_tags t ON p.id = t.property_id
    LEFT JOIN reviews r ON p.id = r.property_id
    WHERE p.status = 'active'
    GROUP BY p.id
""")

# ❌ 非推奨: N+1クエリ問題
for prop in properties:
    cursor.execute("SELECT COUNT(*) FROM property_tags WHERE property_id = ?", (prop["id"],))
    cursor.execute("SELECT AVG(rating) FROM reviews WHERE property_id = ?", (prop["id"],))
```

### 3. EXPLAINでクエリ分析

遅いクエリは実行計画を確認：

```python
# クエリプランを確認
cursor.execute("EXPLAIN QUERY PLAN SELECT * FROM properties WHERE price > 10000000")
for row in cursor.fetchall():
    print(row)
```

---

## 🛡️ 整合性とメンテナンス

### 1. 定期的な整合性チェック

```python
def check_database_integrity(conn: sqlite3.Connection) -> bool:
    """データベースの整合性をチェック"""
    cursor = conn.cursor()
    cursor.execute("PRAGMA integrity_check")
    result = cursor.fetchone()[0]
    
    if result == "ok":
        print("✅ データベースは正常です")
        return True
    else:
        print(f"❌ 整合性エラー: {result}")
        return False
```

### 2. VACUUMで領域回収

削除操作が多い場合、定期的にVACUUMを実行：

```python
def vacuum_database(db_path: str):
    """データベースを最適化（定期メンテナンス用）"""
    conn = sqlite3.connect(db_path)
    
    # 現在のサイズを取得
    cursor = conn.cursor()
    cursor.execute("SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()")
    before_size = cursor.fetchone()[0]
    
    # VACUUM実行（トランザクション外で実行する必要がある）
    conn.execute("VACUUM")
    
    # 最適化後のサイズ
    cursor.execute("SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()")
    after_size = cursor.fetchone()[0]
    
    print(f"最適化完了: {before_size / 1024:.1f}KB → {after_size / 1024:.1f}KB")
    conn.close()
```

### 3. バックアップ戦略

```python
import shutil
from datetime import datetime

def backup_database(db_path: str, backup_dir: str):
    """オンラインバックアップを作成"""
    conn = sqlite3.connect(db_path)
    
    # WALチェックポイントを強制（全データをメインDBに書き込み）
    conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")
    
    # タイムスタンプ付きバックアップ
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = f"{backup_dir}/backup_{timestamp}.db"
    
    # SQLite標準のバックアップAPI使用
    backup_conn = sqlite3.connect(backup_path)
    conn.backup(backup_conn)
    backup_conn.close()
    
    print(f"✅ バックアップ完了: {backup_path}")
    conn.close()
```

---

## ⚠️ 絶対に避けるべきこと

| NG項目 | 理由 |
|--------|------|
| ネットワークドライブに配置 | ファイルロックが正常に機能せず、破損の原因に |
| 複数プロセスからの同時書き込み | WALモードでも競合が発生しやすい |
| 文字列結合でSQL構築 | SQLインジェクション脆弱性 |
| 巨大なBLOBの直接保存 | パフォーマンス低下（別ファイルで管理推奨） |
| トランザクション外での大量INSERT | 極端に遅くなる |

---

## 📋 チェックリスト

新しいSQLiteデータベースを作成する際は、以下を確認：

- [ ] WALモードを有効化したか
- [ ] STRICT修飾子を使用しているか
- [ ] 適切なインデックスを設計したか
- [ ] パラメータ化クエリを使用しているか
- [ ] バックアップ戦略を決定したか
- [ ] 定期メンテナンス（VACUUM/integrity_check）のスケジュールを決めたか

---

## 参考資料

- [Anthropic MCP SQLite Server (Archived)](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/sqlite)
- [SQLite公式: Write-Ahead Logging](https://www.sqlite.org/wal.html)
- [SQLite公式: PRAGMA Statements](https://www.sqlite.org/pragma.html)
