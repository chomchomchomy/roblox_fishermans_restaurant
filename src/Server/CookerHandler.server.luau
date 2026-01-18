-- CookerHandler.server.luau
-- 🎓 教育者の解説：焚き火でお魚を焼くための魔法（超・安定版）

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

local COOK_TIME = 5

local function setupBonfireLogic()
    -- 探し方をさらに確実にします
    local bonfire = workspace:FindFirstChild("Bonfire", true)
    
    if not bonfire then 
        -- もしなければ、FoodStandの中を直接探す
        local fs = workspace:FindFirstChild("FoodStand")
        bonfire = fs and fs:FindFirstChild("Bonfire")
    end
    
    if not bonfire then return end
    if bonfire:FindFirstChild("CookPrompt") then return end

    print("🔥 [Cooker] 焚き火を検知！調理ボタンを装着します。")

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "CookPrompt"
    prompt.ActionText = "魚を焼く"
    prompt.ObjectText = "焚き火"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = bonfire

    prompt.Triggered:Connect(function(player)
        local backpack = player:FindFirstChild("Backpack")
        if not backpack then return end

        local fishToCook = nil
        -- プレイヤーの手に持っているもの、またはカバンの中を確認
        local items = player.Character:GetChildren()
        for _, v in pairs(backpack:GetChildren()) do table.insert(items, v) end

        for _, item in pairs(items) do
            if item:IsA("Tool") and item.Name ~= "FishingRod" and not item:GetAttribute("IsCooked") then
                fishToCook = item
                break
            end
        end

        if fishToCook then
            local originalName = fishToCook.Name
            local originalPrice = fishToCook:GetAttribute("Value") or 10
            fishToCook:Destroy()

            prompt.Enabled = false
            prompt.ActionText = "🔥 ジューーッ..."
            
            task.wait(COOK_TIME)

            -- 焼き上がりの生成
            local grilled = Instance.new("Tool")
            grilled.Name = "🔥 焼き" .. originalName
            grilled.ToolTip = "香ばしく焼けた魚！"
            grilled:SetAttribute("IsCooked", true)
            grilled:SetAttribute("Value", math.floor(originalPrice * 2.0))
            grilled.RequiresHandle = false
            
            -- 画像の引継ぎ
            for _, data in pairs(FishData) do
                if string.find(originalName, data.name) then
                    grilled.TextureId = data.imageId
                    break
                end
            end
            
            grilled.Parent = backpack
            prompt.Enabled = true
            prompt.ActionText = "魚を焼く"
            print("✅ 焼き上がりました！: " .. grilled.Name)
        else
            print("❌ 焼ける魚を持っていません")
        end
    end)
end

task.spawn(function()
    while true do
        setupBonfireLogic()
        task.wait(2)
    end
end)
