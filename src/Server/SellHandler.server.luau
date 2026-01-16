-- SellHandler.server.luau
-- 魚を売却する仕組み (進化対応版)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))
local remote = ReplicatedStorage:WaitForChild("FishingEvent")

local function setupSellLogic(counter)
    if counter:FindFirstChild("SellPrompt") then return end

    local prompt = Instance.new("ProximityPrompt", counter)
    prompt.Name = "SellPrompt"
    prompt.ActionText = "魚を売る"
    prompt.ObjectText = "カウンター"
    prompt.HoldDuration = 0.5
    prompt.Parent = counter

    prompt.Triggered:Connect(function(player)
        local leaderstats = player:FindFirstChild("leaderstats")
        local money = leaderstats and leaderstats:FindFirstChild("Money")
        local backpack = player:FindFirstChild("Backpack")
        local character = player.Character
        if not money or not backpack then return end

        local totalEarnings = 0
        local fishSold = 0
        local allItems = {}
        for _, item in pairs(backpack:GetChildren()) do table.insert(allItems, item) end
        if character then
            for _, item in pairs(character:GetChildren()) do table.insert(allItems, item) end
        end

        for _, item in pairs(allItems) do
            if item:IsA("Tool") and item.Name ~= "FishingRod" then
                local price = 0
                for _, data in pairs(FishData) do
                    if data.name == item.Name then price = data.price break end
                end
                totalEarnings += price
                fishSold += 1
                item:Destroy()
            end
        end

        if fishSold > 0 then
            money.Value += totalEarnings
            remote:FireClient(player, "SELL_RESULTS", totalEarnings, fishSold)
        end
    end)
end

-- 監視ループ
task.spawn(function()
    while true do
        local stand = workspace:FindFirstChild("FoodStand")
        local counter = stand and stand:FindFirstChild("SellCounter")
        if counter then
            setupSellLogic(counter)
        end
        task.wait(2)
    end
end)
