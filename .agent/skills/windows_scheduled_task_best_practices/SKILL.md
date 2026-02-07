---
name: windows_scheduled_task_best_practices
description: Windowsタスクスケジューラで自動実行されるスクリプトを開発する際のベストプラクティスとコーディングルール
---

# Windows Scheduled Task Best Practices

## 概要

このスキルは、Windowsタスクスケジューラで自動実行されるPythonスクリプトを開発する際に発生しやすい問題を防ぐためのベストプラクティスを定義します。

**このルールは必ず遵守してください。**

---

## 1. 環境変数の取り扱い

### ❌ 問題のあるコード
```python
# タスクスケジューラからは環境変数が引き継がれない！
NOTE_EMAIL = os.environ.get("NOTE_EMAIL")
if not NOTE_EMAIL:
    raise ValueError("環境変数が設定されていません")
```

### ✅ 正しいコード
```python
def load_env_file(env_path):
    """
    .envファイルを手動で読み込む
    タスクスケジューラからの実行時に環境変数が引き継がれない問題への対策
    """
    if not os.path.exists(env_path):
        return {}
    
    env_vars = {}
    with open(env_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, value = line.split("=", 1)
                key = key.strip()
                value = value.strip()
                # クォートを除去
                if (value.startswith('"') and value.endswith('"')) or \
                   (value.startswith("'") and value.endswith("'")):
                    value = value[1:-1]
                env_vars[key] = value
                if key not in os.environ:
                    os.environ[key] = value
    return env_vars

# 使用例
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENV_FILE = os.path.join(BASE_DIR, ".env")

# まず環境変数を確認、なければ.envから読み込む
if not os.environ.get("NOTE_EMAIL"):
    load_env_file(ENV_FILE)
```

### ルール
1. **`.env`ファイルからのフォールバック読み込みを必ず実装する**
2. **`python-dotenv`に依存しない手動読み込み機能も用意する**
3. **必須環境変数が見つからない場合は、設定方法を含む詳細なエラーメッセージを表示する**

---

## 2. ログファイルの取り扱い

### ❌ 問題のあるコード
```python
# 単一のログファイルに追記し続けると肥大化する
LOG_FILE = "debug_log.txt"
with open(LOG_FILE, "a") as f:
    f.write(message)
```

### ✅ 正しいコード
```python
import datetime
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOG_DIR = os.path.join(BASE_DIR, "logs")

# ログディレクトリがなければ作成
if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)

def get_log_file_path():
    """日付ベースのログファイルパスを生成"""
    date_str = datetime.datetime.now().strftime("%Y%m%d")
    return os.path.join(LOG_DIR, f"job_{date_str}.log")

class Logger:
    def __init__(self, log_file_path):
        self.terminal = sys.stdout
        # UTF-8で確実にオープン
        self.log = open(log_file_path, "a", encoding="utf-8", errors="replace")
        
    def write(self, message):
        try:
            self.terminal.write(message)
        except UnicodeEncodeError:
            # Windowsコンソールでのエンコーディングエラーを回避
            self.terminal.write(message.encode('ascii', 'replace').decode('ascii'))
        self.log.write(message)
        self.log.flush()
```

### ルール
1. **日付ベースのログファイル名を使用する**（`logs/job_YYYYMMDD.log`）
2. **ログディレクトリの自動作成を必ず行う**
3. **UTF-8エンコーディングを明示的に指定する**
4. **`errors="replace"`でエンコーディングエラーを回避する**
5. **`.flush()`で即時書き込みを行う**

---

## 3. サブプロセス実行

### ❌ 問題のあるコード
```python
# タイムアウトがないと無限待機のリスク
result = subprocess.run([sys.executable, script_path])
```

### ✅ 正しいコード
```python
def run_script(script_name, env, timeout=300, critical=True):
    """
    サブスクリプトを実行する
    
    Args:
        script_name: 実行するスクリプトのファイル名
        env: 環境変数辞書
        timeout: タイムアウト秒数
        critical: Trueの場合、失敗時にジョブ全体を中断
    """
    script_path = os.path.join(SCRIPT_DIR, script_name)
    
    if not os.path.exists(script_path):
        print(f"[ERROR] Script not found: {script_path}")
        return (False, "Script not found")
    
    try:
        result = subprocess.run(
            [sys.executable, "-u", script_path],  # -u: unbuffered output
            capture_output=True,
            text=True,
            env=env,
            cwd=SCRIPT_DIR,
            timeout=timeout
        )
        
        if result.stdout:
            print(result.stdout)
        
        if result.returncode != 0:
            print(f"[ERROR] {script_name} failed (exit code: {result.returncode})")
            if result.stderr:
                print(f"[STDERR] {result.stderr}")
            return (False, "Script failed")
        
        return (True, "Success")
        
    except subprocess.TimeoutExpired:
        print(f"[ERROR] {script_name} timed out after {timeout}s")
        return (False, "Timeout")
        
    except Exception as e:
        print(f"[ERROR] Exception: {e}")
        return (False, str(e))
```

### ルール
1. **必ずタイムアウトを設定する**
2. **`-u`フラグでバッファリングを無効にする**
3. **作業ディレクトリ（`cwd`）を明示的に指定する**
4. **環境変数を明示的に渡す**
5. **stdout/stderrを分離してキャプチャする**

---

## 4. タスクスケジューラ登録

### ルール
1. **`StartWhenAvailable`を有効にする** - スリープ等で実行時間を逃しても次回起動時に実行
2. **リトライ設定を追加する** - 失敗時に自動リトライ
3. **`WakeToRun`を有効にする** - スリープから復帰して実行
4. **実行時間制限を設定する** - 無限実行を防止

```powershell
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -WakeToRun `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 1) `
    -RestartCount 2 `
    -RestartInterval (New-TimeSpan -Minutes 5)
```

---

## 5. 依存ライブラリのフォールバック

### ❌ 問題のあるコード
```python
from dotenv import load_dotenv  # ライブラリがないとクラッシュ
load_dotenv()
```

### ✅ 正しいコード
```python
try:
    from dotenv import load_dotenv
    load_dotenv(ENV_FILE)
except ImportError:
    # python-dotenvがインストールされていない場合
    _load_env_file_manual(ENV_FILE)
```

### ルール
1. **オプショナルな依存ライブラリはtry-exceptでラップする**
2. **フォールバック実装を用意する**

---

## 6. 必須ディレクトリの自動作成

```python
# 必要なディレクトリを起動時に作成
REQUIRED_DIRS = [
    os.path.join(BASE_DIR, "logs"),
    os.path.join(BASE_DIR, "output"),
    os.path.join(BASE_DIR, "data"),
]

for dir_path in REQUIRED_DIRS:
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
```

---

## 7. エラーメッセージのベストプラクティス

### ❌ 問題のあるコード
```python
raise ValueError("環境変数が設定されていません")
```

### ✅ 正しいコード
```python
error_msg = """
[ERROR] NOTE_EMAIL and NOTE_PASSWORD environment variables must be set!

Please set them using one of the following methods:
1. Create a .env file in the project root with:
   NOTE_EMAIL=your_email@example.com
   NOTE_PASSWORD=your_password

2. Or set system environment variables:
   $env:NOTE_EMAIL = "your_email@example.com"
   $env:NOTE_PASSWORD = "your_password"
"""
print(error_msg)
raise ValueError("Required environment variables not set")
```

### ルール
1. **何が問題かを明確に説明する**
2. **解決方法を具体的に提示する**
3. **コマンド例を含める**

---

## チェックリスト

新しいスクリプトを作成する際は、以下を確認してください：

- [ ] `.env`ファイルからのフォールバック読み込みがあるか
- [ ] ログディレクトリの自動作成があるか
- [ ] 日付ベースのログファイル名を使用しているか
- [ ] UTF-8エンコーディングを明示しているか
- [ ] サブプロセスにタイムアウトを設定しているか
- [ ] 必須ディレクトリの自動作成があるか
- [ ] エラーメッセージに解決方法が含まれているか
- [ ] 依存ライブラリのフォールバックがあるか

---

*Created: 2026-02-01*
*Based on: Kiyohara Screening Auto Post system debugging session*
