---
name: coding_quality_standards
description: すべてのプロジェクトで遵守すべきコーディング品質基準。堅牢性、保守性、デバッグ容易性を確保するためのルール。
---

# Coding Quality Standards (コーディング品質基準)

## 概要

このスキルは、Geminiがコードを生成する際に**必ず遵守**すべき品質基準を定義します。
これらのルールは、過去のバグやトラブルシューティング経験から導き出されたベストプラクティスです。

**重要**: このスキルはすべてのプロジェクトに適用されます。

---

## 1. 堅牢性 (Robustness)

### 1.1 環境変数の取り扱い

**原則**: 環境変数は「設定されていない」ことを常に想定する

```python
# ❌ NG: 環境変数がないとクラッシュ
API_KEY = os.environ["API_KEY"]

# ✅ OK: フォールバックと詳細なエラーメッセージ
API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    # .envファイルから読み込みを試みる
    load_env_file(os.path.join(BASE_DIR, ".env"))
    API_KEY = os.environ.get("API_KEY")
    
if not API_KEY:
    print("""
[ERROR] API_KEY environment variable is not set.
Please set it using one of the following methods:
1. Create a .env file with: API_KEY=your_key
2. Set environment variable: $env:API_KEY = "your_key"
    """)
    raise ValueError("API_KEY not set")
```

### 1.2 ファイル・ディレクトリ操作

**原則**: 存在確認と自動作成を必ず行う

```python
# ❌ NG: ディレクトリがないとクラッシュ
with open("logs/output.log", "w") as f:
    f.write(data)

# ✅ OK: 事前にディレクトリを作成
LOG_DIR = os.path.join(BASE_DIR, "logs")
os.makedirs(LOG_DIR, exist_ok=True)

with open(os.path.join(LOG_DIR, "output.log"), "w", encoding="utf-8") as f:
    f.write(data)
```

### 1.3 外部API/サービス呼び出し

**原則**: タイムアウト、リトライ、エラーハンドリングを必ず実装

```python
# ❌ NG: タイムアウトなし、リトライなし
response = requests.get(url)

# ✅ OK: 完全なエラーハンドリング
MAX_RETRIES = 3
INITIAL_DELAY = 2

for attempt in range(MAX_RETRIES):
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.Timeout:
        print(f"[WARN] Timeout on attempt {attempt + 1}")
    except requests.HTTPError as e:
        if e.response.status_code == 429:  # Rate limit
            delay = INITIAL_DELAY * (2 ** attempt)
            print(f"[WARN] Rate limited. Waiting {delay}s...")
            time.sleep(delay)
        else:
            raise
    except Exception as e:
        print(f"[ERROR] Request failed: {e}")
        if attempt == MAX_RETRIES - 1:
            raise

raise Exception("Max retries exceeded")
```

### 1.4 サブプロセス実行

**原則**: タイムアウトと環境変数の明示的な指定を必ず行う

```python
# ❌ NG: タイムアウトなし
subprocess.run([sys.executable, script])

# ✅ OK: 完全な設定
# UTF-8強制とエスケープミスを防ぐため、コマンドは可能な限りリスト形式で渡す。
# PowerShellの場合は明示的にエンコーディングを設定したワンライナーを検討する。
result = subprocess.run(
    [sys.executable, "-u", script],
    capture_output=True,
    text=True,
    env=env,
    cwd=working_dir,
    timeout=300,
    encoding="utf-8"  # Windows環境ではUTF-8明示が必須
)
```

### 1.5 AI API連携

**原則**: モデル名はハードコードせず、`AI Model Selector` スキルに従う

```python
# ❌ NG: 廃止されたモデル名や実験版を直接書く
model = genai.GenerativeModel("gemini-1.5-pro")

# ✅ OK: 推奨定数を使用し、フォールバックを実装
# 詳細は .agent/skills/ai_model_selector/SKILL.md を参照
PRIMARY_MODEL = "gemini-2.5-flash"  # 2026年標準
FALLBACK_MODEL = "gemini-flash-latest"

try:
    model = genai.GenerativeModel(PRIMARY_MODEL)
except Exception:
    model = genai.GenerativeModel(FALLBACK_MODEL)
```

---

## 2. ログ・デバッグ (Logging & Debugging)

### 2.1 ログファイルの命名

**原則**: 日付ベースの命名で管理しやすくする

```python
# ❌ NG: 単一ファイルに追記し続ける
LOG_FILE = "debug.log"

# ✅ OK: 日付ベース
def get_log_file_path():
    date_str = datetime.datetime.now().strftime("%Y%m%d")
    return os.path.join(LOG_DIR, f"job_{date_str}.log")
```

### 2.2 エンコーディング

**原則**: UTF-8を明示的に指定し、エラーハンドリングを追加

```python
# ❌ NG: エンコーディング未指定
with open(file, "w") as f:
    f.write(text)

# ✅ OK: UTF-8明示 + エラーハンドリング
with open(file, "w", encoding="utf-8", errors="replace") as f:
    f.write(text)
```

### 2.3 ログメッセージのフォーマット

**原則**: タイムスタンプ、レベル、コンテキストを含める

```python
# ❌ NG: 情報不足
print("Error occurred")

# ✅ OK: 構造化されたログ
print(f"[{datetime.now().isoformat()}] [ERROR] Failed to connect to API: {e}")
print(f"[INFO] Processing file: {filename} ({idx}/{total})")
```

---

## 3. 保守性 (Maintainability)

### 3.1 設定の分離

**原則**: ハードコーディングを避け、設定ファイルまたは定数を使用

```python
# ❌ NG: マジックナンバー
time.sleep(30)
if retries > 3:
    raise

# ✅ OK: 名前付き定数
DEFAULT_TIMEOUT = 30
MAX_RETRIES = 3

time.sleep(DEFAULT_TIMEOUT)
if retries > MAX_RETRIES:
    raise
```

### 3.2 関数の単一責任

**原則**: 一つの関数は一つのことだけを行う

```python
# ❌ NG: 複数の責任を持つ関数
def process_and_save_and_notify(data):
    # データ処理
    # ファイル保存
    # 通知送信
    pass

# ✅ OK: 責任を分離
def process_data(data):
    return processed_data

def save_to_file(data, path):
    pass

def send_notification(message):
    pass
```

### 3.3 ドキュメンテーション

**原則**: 公開関数にはdocstringを必ず記述

```python
def load_env_file(env_path: str) -> Dict[str, str]:
    """
    .envファイルから環境変数を読み込む
    
    Args:
        env_path: .envファイルのパス
        
    Returns:
        読み込んだ環境変数の辞書
        
    Raises:
        FileNotFoundError: ファイルが存在しない場合
    """
    pass
```

---

## 4. 依存関係 (Dependencies)

### 4.1 オプショナルな依存

**原則**: オプショナルなライブラリはtry-exceptでラップ

```python
# ❌ NG: ライブラリがないとクラッシュ
from dotenv import load_dotenv
load_dotenv()

# ✅ OK: フォールバック実装
try:
    from dotenv import load_dotenv
    load_dotenv(ENV_FILE)
except ImportError:
    _load_env_file_manual(ENV_FILE)
```

### 4.2 パス指定

**原則**: 相対パスではなく、BASE_DIRからの絶対パスを使用

```python
# ❌ NG: 相対パス（実行場所に依存）
with open("data/config.json") as f:
    pass

# ✅ OK: 絶対パス
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG_PATH = os.path.join(BASE_DIR, "data", "config.json")
```

---

## 5. エラーハンドリング (Error Handling)

### 5.1 詳細なエラーメッセージ

**原則**: 何が問題で、どう解決するかを明示

```python
# ❌ NG: 不親切なエラー
raise ValueError("Invalid input")

# ✅ OK: 解決策を提示
raise ValueError(
    f"Invalid date format: '{date_str}'. "
    f"Expected format: YYYY-MM-DD (e.g., 2026-02-01)"
)
```

### 5.2 例外の適切な伝播

**原則**: 握り潰さず、ログを残して再スロー

```python
# ❌ NG: 例外を握り潰す
try:
    risky_operation()
except Exception:
    pass

# ✅ OK: ログを残して処理
try:
    risky_operation()
except Exception as e:
    print(f"[ERROR] Operation failed: {e}")
    traceback.print_exc()
    raise  # または適切な代替処理
```

---

## 6. Windows固有の注意点

### 6.1 タスクスケジューラ

- 環境変数は引き継がれない → `.env`ファイル読み込みを実装
- 作業ディレクトリが異なる場合がある → 絶対パスを使用
- GUIアプリ（Selenium等）はヘッドレスモードを検討

### 6.2 エンコーディング

- Windowsのデフォルトはcp932（Shift-JIS）
- 明示的にUTF-8を指定する
- `errors="replace"`でクラッシュを防止

### 6.3 パス区切り文字

```python
# ❌ NG: Unix形式のパス
path = "logs/output.log"

# ✅ OK: os.path.joinを使用
path = os.path.join("logs", "output.log")
```

---

## チェックリスト

コードをコミットする前に以下を確認：

### 堅牢性
- [ ] 環境変数のフォールバック読み込みがあるか
- [ ] 必須ディレクトリの自動作成があるか
- [ ] 外部API呼び出しにタイムアウトがあるか
- [ ] リトライロジックが実装されているか

### ログ・デバッグ
- [ ] 日付ベースのログファイル名か
- [ ] UTF-8エンコーディングを明示しているか
- [ ] エラー時に十分な情報がログに残るか

### 保守性
- [ ] マジックナンバーを定数化しているか
- [ ] 関数が単一責任になっているか
- [ ] 公開関数にdocstringがあるか

### エラーハンドリング
- [ ] エラーメッセージに解決策が含まれているか
- [ ] 例外を握り潰していないか
- [ ] 適切なログが残されているか

### セキュリティ
- [ ] パスワード/APIキーをログに出力していないか
- [ ] .gitignoreに.envが含まれているか
- [ ] 機密情報をコード内にハードコードしていないか

### テスト
- [ ] 単体テストが存在するか
- [ ] pytest.iniまたはpyproject.tomlにテスト設定があるか

---

## 7. セキュリティ (Security) ⚠️ 最重要

### 7.1 機密情報の取り扱い

**原則**: パスワード、APIキー、トークン等の機密情報は**絶対に**ログやコンソールに出力しない

```python
# ❌ 絶対NG: 機密情報をログに出力
print(f"Loaded credentials: {NOTE_EMAIL}, {NOTE_PASSWORD}")
print(f"API Key: {API_KEY}")

# ❌ 絶対NG: 機密情報の値を表示
def load_env_file(path):
    env_vars = {}
    ...
    print(f"Loaded: {env_vars}")  # パスワードが含まれる可能性！
    return env_vars

# ✅ OK: キー名のみ表示（値は出さない）
def load_env_file(path):
    env_vars = {}
    ...
    print(f"[INFO] Loaded environment variables: {list(env_vars.keys())}")
    return env_vars
```

### 7.2 .gitignore の必須項目

**原則**: 新しいプロジェクトを作成したら、まず.gitignoreを確認

```gitignore
# 必須項目
.env
.env.local
.env.*.local
*.pem
*.key
secrets/
credentials/
```

### 7.3 ハードコーディングの禁止

**原則**: 機密情報は必ず環境変数または設定ファイル経由で読み込む

```python
# ❌ 絶対NG: ハードコーディング
NOTE_EMAIL = "user@example.com"
NOTE_PASSWORD = "password123"
API_KEY = "sk-xxxxxxxxxxxxxxxx"

# ✅ OK: 環境変数から読み込み
NOTE_EMAIL = os.environ.get("NOTE_EMAIL")
NOTE_PASSWORD = os.environ.get("NOTE_PASSWORD")
API_KEY = os.environ.get("API_KEY")
```

### 7.4 ファイル表示時の注意

**原則**: `.env`ファイルや設定ファイルの内容を表示する際は、機密情報をマスクする

```python
# ❌ NG: 内容をそのまま表示
with open(".env") as f:
    print(f.read())

# ✅ OK: キー名のみ表示
def show_env_keys(env_path):
    with open(env_path) as f:
        for line in f:
            if "=" in line:
                key = line.split("=")[0].strip()
                print(f"  - {key}: ****")
```

---

## 8. テスト (Testing)

### 8.1 プロジェクト構成

**原則**: 新しいプロジェクトには必ずテスト設定を含める

```
project/
├── src/
│   └── ...
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # 共通fixture
│   └── test_*.py
├── pytest.ini                # または pyproject.toml
└── requirements-dev.txt      # テスト用依存関係
```

### 8.2 pytest設定ファイル

**原則**: `pytest.ini` または `pyproject.toml` に設定を記述

```ini
# pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
addopts = -v --tb=short
filterwarnings = ignore::DeprecationWarning
```

```toml
# pyproject.toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-v --tb=short"
```

### 8.3 基本的なテスト構造

**原則**: 主要な関数には必ず単体テストを書く

```python
# tests/test_common_utils.py
import pytest
from src.common_utils import load_env_file, get_gemini_api_key

class TestLoadEnvFile:
    """load_env_file関数のテスト"""
    
    def test_load_existing_file(self, tmp_path):
        """存在するファイルを読み込めること"""
        env_file = tmp_path / ".env"
        env_file.write_text("TEST_KEY=test_value\n")
        
        result = load_env_file(str(env_file))
        
        assert "TEST_KEY" in result
        assert result["TEST_KEY"] == "test_value"
    
    def test_missing_file_returns_empty(self):
        """存在しないファイルは空の辞書を返すこと"""
        result = load_env_file("/nonexistent/.env")
        assert result == {}
    
    def test_skip_comments_and_empty_lines(self, tmp_path):
        """コメントと空行をスキップすること"""
        env_file = tmp_path / ".env"
        env_file.write_text("# comment\n\nKEY=value\n")
        
        result = load_env_file(str(env_file))
        
        assert len(result) == 1
        assert "KEY" in result
```

### 8.4 conftest.py の活用

**原則**: 共通のfixtureはconftestに集約

```python
# tests/conftest.py
import pytest
import os

@pytest.fixture
def mock_env(monkeypatch):
    """テスト用の環境変数を設定"""
    monkeypatch.setenv("NOTE_EMAIL", "test@example.com")
    monkeypatch.setenv("NOTE_PASSWORD", "test_password")
    monkeypatch.setenv("GEMINI_API_KEY", "test_api_key")
    yield

@pytest.fixture
def temp_env_file(tmp_path):
    """一時的な.envファイルを作成"""
    env_file = tmp_path / ".env"
    env_file.write_text(
        "TEST_EMAIL=test@example.com\n"
        "TEST_PASSWORD=test_pass\n"
    )
    return str(env_file)
```

### 8.5 requirements-dev.txt

**原則**: 開発用依存関係は別ファイルで管理

```txt
# requirements-dev.txt
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0
```

---

## チェックリスト（セキュリティ・テスト追加版）

### セキュリティ ⚠️
- [ ] **機密情報をログに出力していないか**
- [ ] **機密情報をコード内にハードコードしていないか**
- [ ] `.gitignore`に`.env`が含まれているか
- [ ] ファイル内容表示時に機密情報をマスクしているか

### テスト
- [ ] `tests/`ディレクトリが存在するか
- [ ] `pytest.ini`または`pyproject.toml`にテスト設定があるか
- [ ] 主要な関数に単体テストがあるか
- [ ] `conftest.py`で共通fixtureを管理しているか

### クリーンアップ
- [ ] プロジェクトルートに一時ファイルが散らかっていないか
- [ ] 古いログファイルが適切に管理されているか
- [ ] 使われていないスクリプトがないか
- [ ] 重複したファイルがないか

---

## 9. プロジェクトクリーンアップ (Cleanup)

### 9.1 定期的なクリーンアップの実施

**原則**: 作業完了後、プロジェクトをクリーンな状態に保つ

#### 検知すべき不要ファイル

| パターン | 説明 | アクション |
|---------|------|-----------|
| `debug_*.txt` | 古いデバッグログ | `logs/`に移動または削除 |
| `*_debug_*.txt` | デバッグ出力 | 確認後削除 |
| `*.bak`, `*.backup` | バックアップファイル | Gitで管理されていれば削除 |
| `*_old.*`, `*_copy.*` | 重複ファイル | 確認後削除 |
| `test_*.tmp` | 一時ファイル | 削除 |
| `task_def.xml` | 古いタスク定義 | スクリプトで置き換え済みなら削除 |

#### ディレクトリ整理のルール

```
project/
├── src/          # ソースコードのみ
├── tests/        # テストコードのみ
├── logs/         # すべてのログはここに集約
├── output/       # 出力ファイル
├── data/         # データファイル
└── .agent/       # エージェント設定
```

### 9.2 クリーンアップ実施のタイミング

**原則**: 以下のタイミングでクリーンアップを実施

1. **機能実装完了時** - 不要になった一時ファイルを削除
2. **バグ修正完了時** - デバッグ用ファイルを削除
3. **リファクタリング完了時** - 古いバージョンのファイルを削除

### 9.3 クリーンアップ実施時の確認事項

```python
# クリーンアップ対象の検出例
import os
import glob

def find_cleanup_candidates(base_dir):
    """クリーンアップ候補のファイルを検出"""
    patterns = [
        "debug_*.txt",
        "*_debug_*.txt", 
        "*.bak",
        "*.backup",
        "*_old.*",
        "*_copy.*",
        "*.tmp",
        "task_def.xml",  # 古いタスク定義
    ]
    
    candidates = []
    for pattern in patterns:
        matches = glob.glob(os.path.join(base_dir, pattern))
        candidates.extend(matches)
    
    return candidates

# 使用例
candidates = find_cleanup_candidates(".")
if candidates:
    print("クリーンアップ候補:")
    for f in candidates:
        print(f"  - {f}")
```

### 9.4 ログファイルの管理

**原則**: ログは`logs/`ディレクトリに集約し、日付ベースで管理

```python
# ❌ NG: プロジェクトルートにログを散らかす
LOG_FILE = "debug_log.txt"
LOG_FILE_2 = "debug_log_2.txt"
LOG_FILE_UTF8 = "debug_log_utf8.txt"

# ✅ OK: logs/ディレクトリに集約
LOG_DIR = os.path.join(BASE_DIR, "logs")
LOG_FILE = os.path.join(LOG_DIR, f"job_{date_str}.log")
```

### 9.5 古いログのローテーション

**原則**: 古いログファイルは定期的にアーカイブまたは削除

```python
import os
from datetime import datetime, timedelta

def cleanup_old_logs(log_dir, days_to_keep=30):
    """古いログファイルを削除"""
    cutoff = datetime.now() - timedelta(days=days_to_keep)
    
    for filename in os.listdir(log_dir):
        filepath = os.path.join(log_dir, filename)
        if os.path.isfile(filepath):
            mtime = datetime.fromtimestamp(os.path.getmtime(filepath))
            if mtime < cutoff:
                print(f"[CLEANUP] Removing old log: {filename}")
                os.remove(filepath)
```

### 9.6 使われていないスクリプトの検出

**原則**: 孤立したスクリプトはドキュメント化するか削除

#### チェック方法

1. **呼び出し元の確認**: 他のスクリプトから参照されているか
2. **タスクスケジューラの確認**: 自動実行に登録されているか
3. **ドキュメントの確認**: README等に記載されているか

```bash
# Windowsでの依存関係確認例
# 特定のスクリプトを参照しているファイルを検索
Select-String -Path src\*.py -Pattern "import fetch_tickers"
Select-String -Path src\*.py -Pattern "from fetch_tickers"
```

---

## クリーンアップチェックリスト

作業完了時に以下を確認：

- [ ] プロジェクトルートに一時ファイル（`debug_*.txt`等）がないか
- [ ] すべてのログが`logs/`ディレクトリに集約されているか
- [ ] 使われていない古いスクリプトがないか
- [ ] `.bak`, `.backup`, `*_old.*`ファイルがないか
- [ ] 古いタスク定義ファイル（`task_def.xml`等）がないか

---

---

## 関連スキル

- **[Claude Opus Coding Philosophy](../claude_opus_coding_philosophy/SKILL.md)**: このスキルと併用推奨。Opus 4.5の「ミニマル・精密・堅牢」なコーディング哲学を適用することで、より高品質なコード生成を実現。

---

*Created: 2026-02-01*
*Updated: 2026-02-01 - セキュリティ、テスト、クリーンアップのセクションを追加*
*このルールはすべてのプロジェクトに適用されます*
