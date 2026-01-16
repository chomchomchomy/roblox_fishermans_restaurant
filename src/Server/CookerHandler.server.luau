-- CookerHandler.server.luau
-- レストラン内での調理・自動売却システム (進化対応版)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

local function setupRestaurantLogic(grill)
    if grill:FindFirstChild("CookPrompt") then return end

    local smoke = grill:FindFirstChildOfClass("Smoke")
    local fire = grill:FindFirstChildOfClass("ParticleEmitter") or Instance.new("ParticleEmitter", grill)
    fire.Texture = "rbxassetid://241539266"
    fire.Rate = 0

    local prompt = Instance.new("ProximityPrompt", grill)
    prompt.Name = "CookPrompt"
    prompt.ActionText = "魚を調理して売る"
    prompt.ObjectText = "最新鋭グリル"
    prompt.HoldDuration = 2.0

    prompt.Triggered:Connect(function(player)
        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character
        local items = {}
        for _, i in pairs(backpack:GetChildren()) do if i:IsA("Tool") and i.Name ~= "FishingRod" then table.insert(items, i) end end
        if char then
            for _, i in pairs(char:GetChildren()) do if i:IsA("Tool") and i.Name ~= "FishingRod" then table.insert(items, i) end end
        end

        if #items > 0 then
            print("🍳 [" .. player.Name .. "] が調理を開始しました...")
            if smoke then smoke.Enabled = true end
            fire.Rate = 50
            task.wait(3)

            local totalEarn = 0
            for _, fish in pairs(items) do
                local price = 10
                for _, data in pairs(FishData) do
                    if data.name == fish.Name then price = data.price break end
                end
                totalEarn += math.floor(price * 1.5)
                fish:Destroy()
            end

            local leaderstats = player:FindFirstChild("leaderstats")
            local money = leaderstats and leaderstats:FindFirstChild("Money")
            if money then
                money.Value += totalEarn
                print("💰 調理完了！ 1.5倍（" .. totalEarn .. "円）獲得")
            end
            if smoke then smoke.Enabled = false end
            fire.Rate = 0
        end
    end)
end

-- 監視ループ
task.spawn(function()
    while true do
        local stand = workspace:FindFirstChild("FoodStand")
        local grill = stand and stand:FindFirstChild("CookingStation")
        if grill then
            setupRestaurantLogic(grill)
        end
        task.wait(2)
    end
end)
