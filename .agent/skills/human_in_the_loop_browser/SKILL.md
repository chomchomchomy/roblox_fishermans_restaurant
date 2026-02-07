---
name: Human-in-the-Loop Browser (HLB)
description: AIと人間が協力して「自動化」と「認証突破」を分担する、対スクレイピング対策用ブラウザ操作スキル。
---

# 🤝 Human-in-the-Loop Browser (HLB)

このスキルは、**「AIによる高速操作」**と**「人間による認証・判断」**を組み合わせることで、従来のスクレイピングでは突破困難だったサイト（Cloudflare、reCAPTCHA、2FA認証など）を攻略するための標準プロトコルです。

## 1. コアコンセプト
**"Ai drives, Human keys."** (AIが運転し、人間が鍵を開ける)

- **AIの役割**: ブラウザの起動、定型的なナビゲーション、データ抽出、保存、エラー検知。
- **人間の役割**: ログイン認証、CAPTCHA解除、予期せぬポップアップの閉鎖、重要判断。

## 2. 必須実装パターン (Python + Playwright)

このスキルを使用する際は、必ず以下の`headless=False`および`input()`による待機パターンを実装に含めます。

### 基本テンプレート

```python
import asyncio
from playwright.async_api import async_playwright

async def hlb_session(start_url: str):
    print("🚀 HLB: ブラウザを起動します...")
    async with async_playwright() as p:
        # 【重要】人間が見えるように headless=False に設定
        #  channel="chrome" を指定することで、より人間に近い挙動（正規Chrome）を利用
        browser = await p.chromium.launch(headless=False, channel="chrome", slow_mo=50)
        
        # 永続化が必要な場合は user_data_dir を指定するパターンも検討
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64)...", # 最新のUAを使用
            viewport={"width": 1280, "height": 800}
        )
        page = await context.new_page()

        try:
            print(f"🌐 {start_url} へ移動中...")
            await page.goto(start_url)

            # --- 人間による介入ポイント ---
            print("🛑 【待機】ログインやCAPTCHA解除を行ってください。")
            print("👉 準備ができたら、このターミナルで [Enter] を押してください...")
            input() 
            # ----------------------------

            print("⚡ 自動操作を再開します...")
            
            # ここからAIによるデータ抽出ロジック
            # await page.click(...)
            # data = await page.inner_text(...)

            print("✅ 完了しました。")

        except Exception as e:
            print(f"❌ エラーが発生しました: {e}")
            # エラー時も即閉じせず、人間が確認できるように少し待つか入力を待つ
            input("Press Enter to close browser...")

        finally:
            await browser.close()
```

## 3. ベストプラクティス

1.  **プロファイル永続化**: 毎回ログインしなくて済むよう、Chromeのユーザープロファイル (`userDataDir`) を指定することを推奨する。
2.  **Stealth Mode**: `playwright-stealth` などのプラグインと併用し、Bot検知リスクをさらに下げる。
3.  **Visual Feedback**: AIが何をしているか分かるよう、適宜 `print` で進行状況を日本語で実況させる。
4.  **Timeouts**: 人間の操作は遅いため、`timeout`設定は通常より長め（または無効化 `timeout=0`）にする箇所を設ける。

## 4. このスキルを使うべき場面
- `403 Forbidden` や `Access Denied` が頻発するサイト。
- 複雑な2段階認証が必要な管理画面。
- `Cloudflare` の "Verify you are human" が出るサイト。
- 視覚的な確認（レンダリング結果の正しさ）が重要なタスク。
