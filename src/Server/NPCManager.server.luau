-- NPCManager.server.luau
-- StoreStageに応じたNPCの出現と自動化ロジックの管理

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

-- Chef NPCの生成 (簡単なダミー)
local function spawnChef(player)
    local stand = workspace:WaitForChild("FoodStand", 10)
    if not stand then return end

    -- すでにあれば何もしない
    if stand:FindFirstChild("ChefNPC_" .. player.Name) then return end

    print("👨‍🍳 [" .. player.Name .. "] 専用のシェフを召喚します")

    local chef = Instance.new("Part")
    chef.Name = "ChefNPC_" .. player.Name
    chef.Size = Vector3.new(2, 5, 1)
    chef.Position = stand:FindFirstChild("SellCounter").Position + Vector3.new(-2, 3, -4)
    chef.Color = Color3.fromRGB(255, 200, 200)
    chef.Anchored = true
    chef.Parent = stand

    -- 名前を表示
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = chef
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = chef

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. "のお抱えシェフ"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.LuckiestGuy
    nameLabel.Parent = billboard

    -- ★自動調理・売却ループ
    task.spawn(function()
        while chef and chef.Parent do
            task.wait(5) -- 5秒ごとにチェック

            local char = player.Character
            if not char then continue end

            -- プレイヤーが近く（15スタッド以内）にいる時だけ働く
            local dist = (char.PrimaryPart.Position - chef.Position).Magnitude
            if dist < 15 then
                local backpack = player:FindFirstChild("Backpack")
                local leaderstats = player:FindFirstChild("leaderstats")
                local money = leaderstats and leaderstats:FindFirstChild("Money")
                if not money or not backpack then continue end

                local totalValue = 0
                local count = 0

                -- 魚をすべてスキャンして「その場で売却」
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name ~= "FishingRod" then
                        local val = item:GetAttribute("Value") or 10
                        -- シェフ補正：生魚なら2.5倍、すでに焼き魚ならそのまま（またはさらに高く？）
                        -- ここでは「シェフが焼いて売ってくれた」として一律2.5倍
                        totalValue += math.floor(val * 2.5)
                        count += 1
                        item:Destroy()
                    end
                end

                if count > 0 then
                    money.Value += totalValue
                    print("🍳 シェフのお仕事: " .. count .. "匹を極上料理にして売却！ +" .. totalValue .. "円")
                    
                    -- クライアントに通知（FishingUIHandlerのSELL_RESULTSを再利用）
                    local fishingEvent = ReplicatedStorage:FindFirstChild("FishingEvent")
                    if fishingEvent then
                        fishingEvent:FireClient(player, "SELL_RESULTS", totalValue, count)
                    end
                end
            end
        end
    end)
end

-- 属性変更の監視
local function onPlayerAdded(player)
    player:GetAttributeChangedSignal("StoreStage"):Connect(function()
        local stage = player:GetAttribute("StoreStage") or 0
        if stage >= 1 then
            spawnChef(player)
        end
    end)
    
    -- 最初からStage1以上なら即座に
    if (player:GetAttribute("StoreStage") or 0) >= 1 then
        spawnChef(player)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
