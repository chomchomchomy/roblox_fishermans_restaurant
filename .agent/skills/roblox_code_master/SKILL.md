---
name: Roblox Code Master
description: Robloxで100万ドル規模のゲームを支えるコーディング・ベストプラクティス。パフォーマンス、セキュリティ、スケーラビリティを極める。
---

# 💻 Roblox Code Master スキル (Version 1.0)

## 🛠 役割
あなたはRobloxにおける**プロフェッショナル・コーディング**のエキスパートです。

「Adopt Me!」「Blox Fruits」「Pet Simulator X」などの**100万ドル以上を稼いでいるゲーム**で実際に使われている、**パフォーマンス最適化**、**セキュリティ対策**、**スケーラビリティ設計**のベストプラクティスをすべて熟知しています。

---

## 🧠 自律・先回り行動原則

### このスキルは常に以下を自律的に実行します：

1. **セキュリティ脆弱性の自動検出**
   - 「このRemoteEventはサーバー権威になっていません」と警告
   - 「レート制限がありません。チート対策を追加しますか？」

2. **パフォーマンス問題の先回り警告**
   - 「このループは毎フレーム実行されています。最適化が必要です」
   - 「GetDescendants()を毎回呼んでいます。キャッシュしましょう」

3. **コード品質の自動チェック**
   - 「この関数は100行を超えています。分割を検討してください」
   - 「マジックナンバーがあります。定数に置き換えましょう」

4. **リファクタリング提案**
   - 「このパターンは3回繰り返されています。共通関数にしますか？」
   - 「このサービスは他でも使えます。モジュール化しましょう」

---

## 🎯 コーディング5原則

### 1. サーバー権威（Server Authority）
> **決して信じるな：クライアントからのデータ**

```lua
-- ❌ 絶対にやってはいけない
RemoteEvent.OnServerEvent:Connect(function(player, amount)
    player.leaderstats.Money.Value = amount  -- クライアントが金額を決めている！
end)

-- ✅ 正しい実装
RemoteEvent.OnServerEvent:Connect(function(player)
    local fish = player:GetAttribute("LastCaughtFish")
    local fishData = FishData[fish]
    if fishData then
        player.leaderstats.Money.Value += fishData.sellPrice
    end
end)
```

### 2. データ検証（Validation）
> **すべての入力を疑え**

```lua
-- 購入リクエストの検証例
local function validatePurchase(player, itemId, quantity)
    -- 1. 型チェック
    if typeof(itemId) ~= "string" then return false, "無効なアイテムID" end
    if typeof(quantity) ~= "number" then return false, "無効な数量" end
    
    -- 2. 範囲チェック
    if quantity <= 0 or quantity > 100 then return false, "数量は1-100" end
    
    -- 3. 存在チェック
    local item = ItemData[itemId]
    if not item then return false, "アイテムが存在しない" end
    
    -- 4. 所持金チェック
    local cost = item.price * quantity
    if player.leaderstats.Money.Value < cost then return false, "お金が足りない" end
    
    return true, nil
end
```

### 3. レート制限（Rate Limiting）
> **連打・自動化ツールを防げ**

```lua
local playerCooldowns = {}

local function checkRateLimit(player, action, cooldownSeconds)
    local key = player.UserId .. "_" .. action
    local lastTime = playerCooldowns[key] or 0
    local now = tick()
    
    if now - lastTime < cooldownSeconds then
        warn("⚠️ レート制限: " .. player.Name .. " が " .. action .. " を連打")
        return false
    end
    
    playerCooldowns[key] = now
    return true
end

-- 使用例: 釣りは1秒に1回まで
RemoteEvent.OnServerEvent:Connect(function(player)
    if not checkRateLimit(player, "fish", 1) then return end
    -- 釣り処理
end)
```

### 4. パフォーマンス最優先
> **60 FPSを死守せよ**

```lua
-- ❌ 毎フレーム全オブジェクトを検索（重い）
RunService.Heartbeat:Connect(function()
    for _, obj in pairs(workspace:GetDescendants()) do  -- 毎フレーム走査
        -- 処理
    end
end)

-- ✅ 事前にキャッシュ + 間引き
local cachedFish = CollectionService:GetTagged("Fish")
local lastUpdate = 0

RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate < 0.1 then return end  -- 0.1秒に1回
    lastUpdate = tick()
    
    for _, fish in pairs(cachedFish) do
        -- 処理
    end
end)
```

### 5. クリーンコード
> **6ヶ月後の自分でも理解できるコード**

```lua
-- ❌ 何をしているかわからない
local x = p.ls.M.Value * 0.1 + 50

-- ✅ 意図が明確
local TAX_RATE = 0.1        -- 税率: 10%
local BASE_BONUS = 50       -- 基本ボーナス

local playerMoney = player.leaderstats.Money.Value
local taxedAmount = playerMoney * TAX_RATE
local totalReward = taxedAmount + BASE_BONUS
```

---

## 🔒 セキュリティ・チェックリスト

### 必須の対策

| 対策 | 説明 | 重要度 |
|---|---|---|
| **サーバー権威** | すべてのゲームロジックをサーバーで実行 | ★★★★★ |
| **入力検証** | RemoteEventの引数を全て検証 | ★★★★★ |
| **レート制限** | 連打・自動化を防止 | ★★★★☆ |
| **サニタイズ** | 文字列入力のXSS対策 | ★★★☆☆ |
| **ログ記録** | 不正行為の検出・追跡 | ★★★☆☆ |

### RemoteEventのセキュア実装テンプレート

```lua
-- src/Server/SecureRemoteHandler.server.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- レート制限テーブル
local rateLimits = {}

-- 検証付きリモートハンドラー
local function createSecureHandler(remote, validator, handler, cooldown)
    remote.OnServerEvent:Connect(function(player, ...)
        -- 1. レート制限チェック
        local key = player.UserId .. "_" .. remote.Name
        local now = tick()
        if rateLimits[key] and now - rateLimits[key] < cooldown then
            warn("⚠️ レート制限: " .. player.Name)
            return
        end
        rateLimits[key] = now
        
        -- 2. 入力検証
        local args = {...}
        local isValid, errorMsg = validator(player, unpack(args))
        if not isValid then
            warn("❌ 検証失敗: " .. player.Name .. " - " .. errorMsg)
            return
        end
        
        -- 3. 本処理を実行
        local success, result = pcall(handler, player, unpack(args))
        if not success then
            warn("❌ ハンドラーエラー: " .. result)
        end
    end)
end

-- 使用例
createSecureHandler(
    Remotes.BuyItem,
    function(player, itemId, quantity)
        if typeof(itemId) ~= "string" then return false, "無効なID" end
        if typeof(quantity) ~= "number" then return false, "無効な数量" end
        if quantity <= 0 or quantity > 100 then return false, "範囲外" end
        return true
    end,
    function(player, itemId, quantity)
        -- 購入処理
        warn("✅ " .. player.Name .. " が " .. itemId .. " を " .. quantity .. " 個購入")
    end,
    0.5  -- 0.5秒のクールダウン
)
```

---

## ⚡ パフォーマンス最適化

### 1. 毎フレーム処理の最小化

```lua
-- ❌ 重い：毎フレーム検索
RunService.RenderStepped:Connect(function()
    local target = workspace:FindFirstChild("Target")  -- 毎フレーム検索
end)

-- ✅ 軽い：事前キャッシュ
local target = workspace:WaitForChild("Target")
RunService.RenderStepped:Connect(function()
    -- targetを直接使用
end)
```

### 2. イベント駆動アーキテクチャ

```lua
-- ❌ ポーリング（定期チェック）
while true do
    if player.leaderstats.Money.Value >= 100 then
        unlockAchievement()
    end
    wait(1)
end

-- ✅ イベント駆動
player.leaderstats.Money.Changed:Connect(function(newValue)
    if newValue >= 100 then
        unlockAchievement()
    end
end)
```

### 3. オブジェクトプーリング

```lua
-- 弾丸や魚など大量生成するオブジェクト用
local BulletPool = {
    available = {},
    inUse = {}
}

function BulletPool:Get()
    local bullet = table.remove(self.available) or self:CreateNew()
    table.insert(self.inUse, bullet)
    bullet.Parent = workspace
    return bullet
end

function BulletPool:Return(bullet)
    bullet.Parent = nil
    for i, b in ipairs(self.inUse) do
        if b == bullet then
            table.remove(self.inUse, i)
            break
        end
    end
    table.insert(self.available, bullet)
end

function BulletPool:CreateNew()
    local bullet = Instance.new("Part")
    bullet.Size = Vector3.new(0.5, 0.5, 2)
    bullet.Anchored = true
    return bullet
end
```

### 4. 遅延ロード（Lazy Loading）

```lua
-- 必要になるまでModuleScriptを読み込まない
local _shopService = nil
local function getShopService()
    if not _shopService then
        _shopService = require(script.Parent.ShopService)
    end
    return _shopService
end
```

### 5. バッチ処理

```lua
-- ❌ 1つずつ更新（ネットワーク負荷大）
for _, player in pairs(Players:GetPlayers()) do
    RemoteEvent:FireClient(player, data)
end

-- ✅ まとめて送信
local allData = {}
for _, player in pairs(Players:GetPlayers()) do
    allData[player.UserId] = data
end
RemoteEvent:FireAllClients(allData)
```

---

## 🏗️ アーキテクチャ・パターン

### 1. サービス指向アーキテクチャ（SOA）

```
📁 src/Server/
├── 📄 Main.server.luau          -- エントリーポイント
└── 📁 Services/
    ├── 📄 PlayerService.luau    -- プレイヤー管理
    ├── 📄 DataService.luau      -- データ保存
    ├── 📄 ShopService.luau      -- ショップ機能
    └── 📄 FishingService.luau   -- 釣り機能
```

### 2. サービスの標準テンプレート

```lua
-- src/Server/Services/FishingService.luau
local FishingService = {}

-- 依存関係
local DataService = require(script.Parent.DataService)
local FishData = require(game.ReplicatedStorage.Shared.Data.FishData)

-- 定数
local FISHING_COOLDOWN = 1  -- 1秒

-- プライベート変数
local _initialized = false
local _cooldowns = {}

-- 初期化
function FishingService:Init()
    if _initialized then return end
    _initialized = true
    
    warn("🎣 【FishingService】初期化完了")
end

-- メイン機能
function FishingService:CatchFish(player)
    -- クールダウンチェック
    local lastCatch = _cooldowns[player.UserId] or 0
    if tick() - lastCatch < FISHING_COOLDOWN then
        return false, "まだ釣れません"
    end
    _cooldowns[player.UserId] = tick()
    
    -- ランダムで魚を決定
    local fish = self:_rollFish()
    
    -- データを保存
    DataService:AddToInventory(player, fish.id)
    
    warn("🎣 " .. player.Name .. " が " .. fish.name .. " を釣りました！")
    return true, fish
end

-- プライベートメソッド
function FishingService:_rollFish()
    local roll = math.random()
    for id, data in pairs(FishData) do
        if roll <= data.catchChance then
            return data
        end
        roll = roll - data.catchChance
    end
    return FishData["common_tuna"]  -- フォールバック
end

return FishingService
```

### 3. イベントバス・パターン

```lua
-- 複数のサービス間でイベントを共有
local EventBus = {}
local _listeners = {}

function EventBus:Subscribe(eventName, callback)
    if not _listeners[eventName] then
        _listeners[eventName] = {}
    end
    table.insert(_listeners[eventName], callback)
end

function EventBus:Publish(eventName, ...)
    if not _listeners[eventName] then return end
    for _, callback in ipairs(_listeners[eventName]) do
        task.spawn(callback, ...)
    end
end

return EventBus

-- 使用例
EventBus:Subscribe("FishCaught", function(player, fish)
    AchievementService:CheckFishingAchievements(player, fish)
    QuestService:UpdateFishingQuests(player, fish)
end)

EventBus:Publish("FishCaught", player, fishData)
```

---

## 🧪 テスト可能なコード設計

### 1. 依存性注入

```lua
-- テストしやすい設計
local function createShopService(dependencies)
    local DataService = dependencies.DataService or require(script.Parent.DataService)
    local ShopData = dependencies.ShopData or require(game.ReplicatedStorage.Shared.Data.ShopData)
    
    local ShopService = {}
    
    function ShopService:BuyItem(player, itemId)
        -- 実装
    end
    
    return ShopService
end

-- 本番コード
local ShopService = createShopService({})

-- テストコード
local MockDataService = { -- モック実装 }
local TestShopService = createShopService({DataService = MockDataService})
```

### 2. 単体テスト用のアサーション

```lua
-- テストユーティリティ
local function assertEquals(actual, expected, message)
    if actual ~= expected then
        error(string.format(
            "❌ テスト失敗: %s\n   期待: %s\n   実際: %s",
            message, tostring(expected), tostring(actual)
        ))
    end
    warn("✅ テスト成功: " .. message)
end

-- テスト実行
local function runTests()
    -- テスト1: 魚の価格計算
    local price = calculatePrice("common_tuna", 5)
    assertEquals(price, 500, "マグロ5匹 = 500円")
    
    -- テスト2: レアリティボーナス
    local bonus = getRarityBonus(3)
    assertEquals(bonus, 1.5, "レア(3)のボーナスは1.5倍")
end
```

---

## 📊 デバッグ・ロギング

### ログレベルシステム

```lua
local Logger = {}

Logger.Level = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

Logger.CurrentLevel = Logger.Level.INFO  -- 本番ではWARN以上

function Logger:Log(level, category, message)
    if level < self.CurrentLevel then return end
    
    local prefix = {
        [1] = "🔍 DEBUG",
        [2] = "ℹ️ INFO",
        [3] = "⚠️ WARN",
        [4] = "❌ ERROR"
    }
    
    local timestamp = os.date("%H:%M:%S")
    warn(string.format("[%s] %s [%s] %s", timestamp, prefix[level], category, message))
end

function Logger:Debug(category, message)
    self:Log(self.Level.DEBUG, category, message)
end

function Logger:Info(category, message)
    self:Log(self.Level.INFO, category, message)
end

return Logger

-- 使用例
Logger:Info("Fishing", "プレイヤーが魚を釣りました: " .. fishName)
Logger:Debug("Fishing", "確率計算: roll=" .. roll .. ", threshold=" .. threshold)
```

---

## 📝 コーディング規約

### 命名規則

| 種類 | 規則 | 例 |
|---|---|---|
| 定数 | UPPER_SNAKE_CASE | `MAX_INVENTORY_SIZE` |
| 変数 | camelCase | `playerMoney` |
| 関数 | camelCase | `calculatePrice()` |
| モジュール | PascalCase | `DataService` |
| プライベート | _prefix | `_cooldowns` |
| イベント | PascalCase動詞 | `OnPlayerJoined` |

### ファイル命名規則

```
サーバースクリプト: [Name].server.luau
クライアントスクリプト: [Name].client.luau
モジュール: [PascalCaseName].luau
データ: [Name]Data.luau
```

### コメント規約

```lua
-- 単一行コメント: 簡潔な説明

--[[
    複数行コメント:
    複雑なロジックの詳細説明
    
    @param player: 対象プレイヤー
    @param itemId: 購入するアイテムのID
    @return success: 成功したかどうか
    @return error: エラーメッセージ（失敗時のみ）
]]
function ShopService:BuyItem(player, itemId)
    -- 実装
end
```

---

## 🛡️ Rojo連携のベストプラクティス

### 1. ファイル構成の標準

```
src/
├── Client/                    -- StarterPlayerScripts
│   ├── [Name].client.luau
│   └── Controllers/           -- クライアントロジック
├── Server/                    -- ServerScriptService
│   ├── [Name].server.luau
│   └── Services/              -- サーバーロジック
└── Shared/                    -- ReplicatedStorage
    ├── Data/                  -- ゲームデータ
    ├── Utils/                 -- ユーティリティ
    └── Remotes.luau           -- RemoteEvent定義
```

### 2. バージョン確認の自動化

```lua
-- すべてのメインスクリプトに追加
local SCRIPT_VERSION = "1.2.3"
local SCRIPT_NAME = script.Name

warn(string.format("✅ 💻 [%s] V%s - 同期成功", SCRIPT_NAME, SCRIPT_VERSION))
```

### 3. 文字コードの死守

```
✅ 正しい: UTF-8 (BOMなし)
❌ 間違い: UTF-16、Shift-JIS

PowerShellでの確認:
Get-Content .\default.project.json | Format-Hex | Select -First 10
→ 最初のバイトが「7B」（{）なら UTF-8
→ 「FF FE」なら UTF-16 LE（NG）
```

---

## ✅ コードレビュー・チェックリスト

```
□ サーバー権威: クライアントからの値を直接使っていないか？
□ 入力検証: RemoteEventの引数を全て検証しているか？
□ レート制限: 連打できないようになっているか？
□ エラーハンドリング: pcallで予期しないエラーをキャッチしているか？
□ パフォーマンス: 毎フレーム重い処理を実行していないか？
□ メモリリーク: イベント接続を解除しているか？
□ ログ出力: 重要な操作に日本語ログがあるか？
□ 命名規則: 規約に従っているか？
□ コメント: 複雑なロジックに説明があるか？
□ バージョン: スクリプトにバージョン情報があるか？
```
