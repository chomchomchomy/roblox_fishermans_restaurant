---
name: AI Model Selector
description: AIAPIを利用したスクリプトを書く際、モデル名が毎回違う・古くてエラーになる問題（Model Not Found）を防ぐための、統一モデル名管理スキル。
---

# AI Model Selector (Unified Model Registry)

AI APIを利用するスクリプトを書く際、モデル名をハードコードせず、必ずこのスキルで定義された「現在推奨されるモデル名」を使用すること。

## 1. 推奨モデル一覧 (Current Standard Models)
以下のモデル名は動作確認済みであり、優先的に使用する。スクリプト内では定数として定義し、変更が容易なように設計すること。

### A. Google Gemini (google-generativeai)
- **高速・標準 (Default)**: `gemini-2.5-flash`
  - *Note*: 2026年現在の標準。`gemini-flash-latest` エイリアスでもアクセス可能。
- **高精度 (High Quality)**: `gemini-2.5-pro`
  - *Note*: 複雑な推論用。`gemini-pro-latest` としても機能。
- **最先端 (Next Gen)**: `gemini-3-pro-preview`
  - *Note*: 最新の研究用。非常に強力だがコスト高。
- **超軽量 (Ultra Lite)**: `gemini-2.5-flash-lite`
  - *Note*: 極小のリクエストや大量処理用。

## 2. 互換性マップ (Compatibility Map)
古いスクリプトをメンテナンスする際、以下のマッピングに従ってモデル名を置換すること。

| 旧指定 (Legacy) | 新指定 (2026 Standard) | 理由 |
|----------------|-----------------------|------|
| `gemini-pro` | `gemini-2.5-pro` | 1.0/1.5proは廃止済 |
| `gemini-1.5-flash` | `gemini-2.5-flash` | パフォーマンス向上のため |
| `gemini-2.0-flash-exp` | `gemini-2.5-flash` | 実験版終了に伴う安定版移行 |
| `gpt-3.5-turbo` | `gpt-4o-mini` | コスト・速度共に上位互換 |

### B. OpenAI (openai)
- **高速・標準 (Default)**: `gpt-4o-mini`
- **高精度 (High Quality)**: `gpt-4o`

### C. Anthropic Claude (anthropic)
- **高速 (Fast)**: `claude-3-haiku-20240307`
- **高精度 (High Quality)**: `claude-3-5-sonnet-latest` (推奨)
  - *Note*: `latest` エイリアスが使える環境ではそちらを優先。固定バージョンは `claude-3-5-sonnet-20240620` 等。

## 2. 実装パターン (Implementation Patterns)
スクリプト内でモデル名を記述する際は、以下のいずれかのパターンを採用し、「モデル名変更時の修正箇所」を1箇所に集約する。

### Pattern A: Python (consts.py / config.py)
```python
import os

# Define models in one place
class AIModels:
    GEMINI_FAST = "gemini-2.5-flash"
    GEMINI_HIGH = "gemini-2.5-pro"
    GPT_FAST = "gpt-4o-mini"
    GPT_HIGH = "gpt-4o"
    CLAUDE_FAST = "claude-3-haiku-20240307"
    CLAUDE_HIGH = "claude-3-5-sonnet-latest"

def get_gemini_model(use_high_quality=False):
    return AIModels.GEMINI_HIGH if use_high_quality else AIModels.GEMINI_FAST
```

### Pattern B: Fallback Logic (Error Handling)
モデルが廃止されたり、一時的に利用できない場合（404 Not Found）に備え、自動でフォールバックするロジックを組み込むことを推奨する。

```python
import google.generativeai as genai
from google.api_core import exceptions

def generate_content_safe(prompt, primary_model="gemini-2.5-flash", fallback_model="gemini-flash-latest"):
    try:
        model = genai.GenerativeModel(primary_model)
        return model.generate_content(prompt)
    except exceptions.NotFound:
        print(f"Model {primary_model} not found. Falling back to {fallback_model}...")
        model = genai.GenerativeModel(fallback_model)
        return model.generate_content(prompt)
    except Exception as e:
        print(f"Generation failed: {e}")
        return None
```

## 3. ルール (Rules)
1. **ハードコード禁止**: `genai.GenerativeModel("gemini-pro")` のように直接文字列を書かない。必ず変数か定数を使用する。
2. **存在確認**: 新しいモデル名を使用する際は、必ずその時点での公式ドキュメントまたは動作確認済みのリストを参照する（勝手に `gemini-1.5-ultra` などを捏造しない）。
3. **エラー時の更新**: スクリプト実行時に `404 Not Found` が出たら、コードを直す前に**このスキルファイル（SKILL.md）の推奨モデル一覧を更新**し、その後コードに反映させる。
