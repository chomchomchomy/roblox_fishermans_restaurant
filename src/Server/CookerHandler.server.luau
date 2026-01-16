-- CookerHandler.server.luau
-- レストラン内での調理システム（10秒待機後の高単価変換）

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

local function setupRestaurant()
    local stand = workspace:WaitForChild("FoodStand", 10)
    if not stand then return end

    local counter = stand:FindFirstChild("SellCounter")
    if not counter then return end

    -- 調理場（グリル）を設置
    local grill = Instance.new("Part")
    grill.Name = "CookingStation"
    grill.Size = Vector3.new(4, 0.5, 4)
    grill.Position = counter.Position + Vector3.new(-4, 2.3, 0)
    grill.Color = Color3.fromRGB(30, 30, 30)
    grill.Material = Enum.Material.Metal
    grill.Anchored = true
    grill.Parent = stand

    -- パーティクル（調理中の火）
    local fire = Instance.new("ParticleEmitter")
    fire.Enabled = false
    fire.Texture = "rbxassetid://241539266"
    fire.Rate = 50
    fire.Lifetime = NumberRange.new(0.5, 1)
    fire.Parent = grill

    -- 調理プロンプト
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "魚をじっくり焼く (10秒)"
    prompt.ObjectText = "最新鋭グリル"
    prompt.HoldDuration = 1.0 
    prompt.Parent = grill

    prompt.Triggered:Connect(function(player)
        if player:GetAttribute("IsCooking") then
            warn("すでに調理中です！")
            return
        end

        local backpack = player:FindFirstChild("Backpack")
        local char = player.Character
        local items = {}
        
        -- 手に持っている魚を優先的に調理
        if char then
            for _, i in pairs(char:GetChildren()) do
                if i:IsA("Tool") and i.Name ~= "FishingRod" and not i.Name:find("焼き魚") then
                    table.insert(items, i)
                end
            end
        end
        
        -- バックパックの魚も入れる
        if #items == 0 and backpack then
            for _, i in pairs(backpack:GetChildren()) do
                if i:IsA("Tool") and i.Name ~= "FishingRod" and not i.Name:find("焼き魚") then
                    table.insert(items, i)
                end
            end
        end

        if #items > 0 then
            player:SetAttribute("IsCooking", true)
            print("🍳 [" .. player.Name .. "] がじっくり調理を開始しました (10秒待ち)")
            fire.Enabled = true
            
            -- 調理する魚の価値を記憶
            local cookedFishes = {}
            for _, fish in pairs(items) do
                local originalValue = fish:GetAttribute("Value") or 10
                table.insert(cookedFishes, {name = fish.Name, value = math.floor(originalValue * 2.5)})
                fish:Destroy()
            end

            -- 10秒待機（ここが修行！）
            task.wait(10)

            print("💰 調理完了！")
            fire.Enabled = false
            
            -- 「焼き魚」として戻す
            for _, data in pairs(cookedFishes) do
                local grilled = Instance.new("Tool")
                grilled.Name = "🔥焼き魚 (" .. data.name .. ")"
                grilled:SetAttribute("Value", data.value)
                grilled.ToolTip = "売値: " .. data.value .. "円 (調理済み)"
                grilled.RequiresHandle = false
                grilled.Parent = player:WaitForChild("Backpack")
            end
            
            player:SetAttribute("IsCooking", false)
        else
            warn("焼くための生魚を持っていません！")
        end
    end)
end

task.spawn(setupRestaurant)
