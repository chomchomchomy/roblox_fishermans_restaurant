-- ShopHandler.server.luau
-- 釣具屋でのアップグレード処理 (進化対応版)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shopEvent = ReplicatedStorage:FindFirstChild("ShopEvent") or Instance.new("RemoteEvent", ReplicatedStorage)
shopEvent.Name = "ShopEvent"

local function setupShopLogic(counter)
    if counter:FindFirstChild("ShopPrompt") then return end

    local prompt = Instance.new("ProximityPrompt", counter)
    prompt.Name = "ShopPrompt"
    prompt.ActionText = "アップグレード"
    prompt.ObjectText = "伝説の釣具屋"
    prompt.HoldDuration = 0.5
    prompt.KeyboardKeyCode = Enum.KeyCode.E

    prompt.Triggered:Connect(function(player)
        shopEvent:FireClient(player, "OPEN")
    end)
end

-- 購入処理
shopEvent.OnServerEvent:Connect(function(player, action, itemType)
    local leaderstats = player:FindFirstChild("leaderstats")
    local money = leaderstats and leaderstats:FindFirstChild("Money")
    if not money then return end

    if action == "BUY_UPGRADE" then
        if itemType == "FISHING_SPEED" then
            local currentLevel = player:GetAttribute("FishingSpeedLevel") or 1
            local cost = currentLevel * 200
            if money.Value >= cost then
                money.Value -= cost
                player:SetAttribute("FishingSpeedLevel", currentLevel + 1)
                local newSpeed = 1.0 - (currentLevel * 0.05)
                if newSpeed < 0.3 then newSpeed = 0.3 end
                player:SetAttribute("FishingSpeed", newSpeed)
                shopEvent:FireClient(player, "SUCCESS")
            end
        elseif itemType == "BAG_SIZE" then
            local currentLevel = player:GetAttribute("BagLevel") or 1
            local cost = currentLevel * 300
            if money.Value >= cost then
                money.Value -= cost
                player:SetAttribute("BagLevel", currentLevel + 1)
                local newSize = 5 + (currentLevel * 3)
                player:SetAttribute("MaxStorage", newSize)
                shopEvent:FireClient(player, "SUCCESS")
            end
        end
    end
end)

-- 監視ループ
task.spawn(function()
    while true do
        local shop = workspace:FindFirstChild("UpgradeShop")
        local counter = shop and shop:FindFirstChild("UpgradeCounter")
        if counter then
            setupShopLogic(counter)
        end
        task.wait(2)
    end
end)
