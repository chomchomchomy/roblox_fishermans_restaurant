-- ShopHandler.server.luau
-- 釣具屋でのアップグレード処理

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")

-- ★NEW：ショップイベントの作成
local shopEvent = ReplicatedStorage:FindFirstChild("ShopEvent")
if not shopEvent then
    shopEvent = Instance.new("RemoteEvent")
    shopEvent.Name = "ShopEvent"
    shopEvent.Parent = ReplicatedStorage
end

-- ショップのカウンターを探す
local function setupShopCounter()
    local shop = workspace:WaitForChild("UpgradeShop", 10)
    if not shop then 
        warn("UpgradeShopが見つかりません。")
        return 
    end

    local counter = shop:FindFirstChild("UpgradeCounter")
    if not counter then
        warn("UpgradeCounterが見つかりません。")
        return
    end

    -- 近接プロンプトの設定
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "アップグレード"
    prompt.ObjectText = "伝説の釣具屋"
    prompt.HoldDuration = 0.5
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.Parent = counter

    -- プロンプト実行時
    prompt.Triggered:Connect(function(player)
        print("🛒 [" .. player.Name .. "] がショップを開きました")
        shopEvent:FireClient(player, "OPEN")
    end)
end

local RodData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RodData"))

-- 購入処理
shopEvent.OnServerEvent:Connect(function(player, action, itemType)
    local leaderstats = player:FindFirstChild("leaderstats")
    local money = leaderstats and leaderstats:FindFirstChild("Money")
    if not money then return end

    if action == "BUY_UPGRADE" then
        if itemType == "FISHING_SPEED" then
            local currentLevel = player:GetAttribute("FishingSpeedLevel") or 1
            local cost = currentLevel * 500
            
            if money.Value >= cost then
                money.Value -= cost
                player:SetAttribute("FishingSpeedLevel", currentLevel + 1)
                
                -- すでにある倍率にさらに0.9倍（10%速く）
                local currentSpeed = player:GetAttribute("FishingSpeed") or 1.0
                player:SetAttribute("FishingSpeed", currentSpeed * 0.9)
                
                print("💰 [" .. player.Name .. "] 修行により釣りの速度が向上！")
                shopEvent:FireClient(player, "SUCCESS", "FISHING_SPEED")
            end
        elseif itemType == "BAG_SIZE" then
            local currentLevel = player:GetAttribute("BagLevel") or 1
            local cost = currentLevel * 400
            
            if money.Value >= cost then
                money.Value -= cost
                player:SetAttribute("BagLevel", currentLevel + 1)
                local newSize = 5 + (currentLevel * 5)
                player:SetAttribute("MaxStorage", newSize)
                
                print("💰 [" .. player.Name .. "] バッグ拡張完了(容量: " .. newSize .. ")")
                shopEvent:FireClient(player, "SUCCESS", "BAG_SIZE")
            end
        end
    elseif action == "BUY_ROD" then
        local currentTier = player:GetAttribute("RodTier") or 1
        local nextTier = currentTier + 1
        local rodInfo = RodData[nextTier]

        if rodInfo and money.Value >= rodInfo.price then
            money.Value -= rodInfo.price
            player:SetAttribute("RodTier", nextTier)
            player:SetAttribute("FishingSpeed", rodInfo.speed)
            player:SetAttribute("RarityBoost", rodInfo.rarityBoost)
            
            -- 竿の見た目を変えるために属性セット
            player:SetAttribute("RodColor", rodInfo.color)
            
            print("💰 [" .. player.Name .. "] が " .. rodInfo.name .. " を購入しました！")
            shopEvent:FireClient(player, "SUCCESS", "ROD", nextTier)
        end
    end
end)

task.spawn(function()
    task.wait(1)
    setupShopCounter()
end)
