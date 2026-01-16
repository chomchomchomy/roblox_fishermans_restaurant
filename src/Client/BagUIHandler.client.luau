-- BagUIHandler.client.luau
-- 【デバッグ特別版】一行ごとにログを出し、UIを強制表示する

print("🚩 [DEBUG 0] BagUIHandlerのファイル読み込みが開始されました！")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("🚩 [DEBUG 1] プレイヤー名: " .. player.Name)

-- 通信パーツやデータの確認
local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)
if not sharedFolder then
    print("❌ [ERROR] ReplicatedStorageの中にSharedフォルダが見つかりません！")
end

local FishData = require(sharedFolder:WaitForChild("FishData"))
print("🚩 [DEBUG 2] お魚データ読み込み完了: " .. #FishData .. "種類")

-- UIの土台作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DEBUG_BagUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999 -- 最前面
screenGui.Parent = player:WaitForChild("PlayerGui")
print("🚩 [DEBUG 3] ScreenGuiをPlayerGuiに作成しました。")

-- コンテナ（枠が見えるようにわざと色をつけます）
local container = Instance.new("Frame")
container.Name = "DEBUG_Container"
container.Size = UDim2.new(0, 300, 0, 100)
container.Position = UDim2.new(0.5, -150, 0.5, -50) -- ★画面のど真ん中に表示！
container.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- ★真っ赤にして目立たせる！
container.BackgroundTransparency = 0.5
container.ZIndex = 1000
container.Parent = screenGui
print("🚩 [DEBUG 4] 画面中央に赤いデバッグ窓を作成しました。")

local capacityLabel = Instance.new("TextLabel")
capacityLabel.Size = UDim2.new(1, 0, 1, 0)
capacityLabel.BackgroundTransparency = 1
capacityLabel.Text = "バッグ状況を確認中..."
capacityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
capacityLabel.TextSize = 25
capacityLabel.Parent = container

-- バッグ監視の開始
task.spawn(function()
    print("🚩 [DEBUG 5] Bagフォルダの待機を開始します...")
    local bag = player:WaitForChild("Bag", 15) -- 15秒待機
    
    if not bag then
        print("❌ [ERROR] 15秒待ってもフォルダ 'Bag' がプレイヤー内に見つかりません！")
        capacityLabel.Text = "❌ バッグフォルダなし！"
        return
    end
    
    print("🚩 [DEBUG 6] Bagフォルダを発見！")
    
    local function refresh()
        local count = #bag:GetChildren()
        print("🚩 [DEBUG 7] UI更新を実行: 現在の数 " .. count)
        capacityLabel.Text = "👜 バッグ: " .. count .. " / 5"
    end
    
    bag.ChildAdded:Connect(refresh)
    bag.ChildRemoved:Connect(refresh)
    refresh()
    print("🚩 [DEBUG 8] 監視セットアップがすべて完了しました！")
end)

print("✅ [DEBUG END] スクリプトの最後まで到達しました。")
