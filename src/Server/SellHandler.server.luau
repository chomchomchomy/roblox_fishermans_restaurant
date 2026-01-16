-- SellHandler.server.luau
-- 🎓 教育者の解説：シェフに直接「魚を売る」ためのスクリプトです

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

-- 売却処理のセットアップ
local function setupChefSellLogic(chefModel)
    local rootPart = chefModel:WaitForChild("HumanoidRootPart", 5)
    if not rootPart then return end
    
    if rootPart:FindFirstChild("SellPrompt") then return end

    -- シェフ自身にボタンを追加
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "SellPrompt"
    prompt.ActionText = "魚をシェフに渡す"
    prompt.ObjectText = "シェフ"
    prompt.HoldDuration = 0.5
    prompt.Parent = rootPart

    prompt.Triggered:Connect(function(player)
        local leaderstats = player:FindFirstChild("leaderstats")
        local money = leaderstats and leaderstats:FindFirstChild("Money")
        local backpack = player:FindFirstChild("Backpack")
        
        if not money or not backpack then return end

        local totalEarnings = 0
        local fishCount = 0
        
        -- 手持ちアイテムのチェック
        local items = backpack:GetChildren()
        local character = player.Character
        if character then
            for _, v in pairs(character:GetChildren()) do
                if v:IsA("Tool") then table.insert(items, v) end
            end
        end

        for _, item in pairs(items) do
            if item:IsA("Tool") and item.Name ~= "FishingRod" then
                for _, data in pairs(FishData) do
                    if data.name == item.Name then
                        totalEarnings += data.price
                        fishCount += 1
                        item:Destroy()
                        break
                    end
                end
            end
        end

        if fishCount > 0 then
            money.Value += totalEarnings
            print("👨‍🍳 [シェフ] 「いい魚だ！" .. totalEarnings .. " Gold で買い取らせてもらうよ！」")
        else
            print("👨‍🍳 [シェフ] 「おや、売れる魚を持っていないようだね。」")
        end
    end)
end

-- 常に「シェフ」が世界にいるか監視する
task.spawn(function()
    while true do
        local chef = workspace:FindFirstChild("Chef")
        if chef then
            setupChefSellLogic(chef)
        end
        task.wait(2)
    end
end)

print("👨‍🍳 [SellHandler] シェフの買い取り受付システム、起動！")
