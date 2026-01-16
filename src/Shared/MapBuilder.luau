-- MapBuilder.luau
-- マップの設計図：Stage 0 配置完成版（シェフ直売・看板右・焚火中央）
local MapBuilder = {}

local terrain = workspace.Terrain
local Players = game:GetService("Players")

-- NPCsを作成するヘルパー関数 (高品質アバター召喚)
local function createNPC(name, userId, pos, lookAt)
    -- 同名がいれば削除
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == name then obj:Destroy() end
    end

    print("👤 [" .. name .. "] を召喚中... (UserId: " .. userId .. ")")
    
    local model
    local success, err = pcall(function()
        model = Players:CreateHumanoidModelFromUserId(userId)
    end)

    if not success or not model then
        warn("⚠️ アバター召喚失敗: " .. tostring(err))
        model = Instance.new("Model")
        local torso = Instance.new("Part", model)
        torso.Name = "Torso"; torso.Size = Vector3.new(2, 2, 1); torso.Anchored = true
        Instance.new("Humanoid", model)
        model.PrimaryPart = torso
    end

    model.Name = name
    model.Parent = workspace
    
    -- 位置合わせ
    model:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))

    -- 組み立て完了を待ってから固定と向き設定
    task.spawn(function()
        task.wait(2.0)
        if model and model.Parent then
            for _, p in pairs(model:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Anchored = true
                    p.CanCollide = true
                end
            end
            -- 海（Z方向）を正対させる
            local currentPos = model:GetPivot().Position
            model:PivotTo(CFrame.lookAt(currentPos, Vector3.new(currentPos.X, currentPos.Y, currentPos.Z + 10)))
        end
    end)

    return model
end

-- 舞台構築
function MapBuilder.buildBase()
    terrain:Clear()
    terrain:FillBlock(CFrame.new(0, -52, 0), Vector3.new(2000, 100, 2000), Enum.Material.Water)
    terrain:FillBlock(CFrame.new(0, -5, 0), Vector3.new(300, 10, 300), Enum.Material.Sand)
    if workspace:FindFirstChild("Baseplate") then workspace.Baseplate:Destroy() end
end

function MapBuilder.buildPier()
    if workspace:FindFirstChild("FishingPier") then workspace.FishingPier:Destroy() end
    local folder = Instance.new("Folder", workspace); folder.Name = "FishingPier"
    local startZ, length, height, width = 130, 100, 2.5, 14
    for i = 0, length, 4 do
        local plank = Instance.new("Part", folder)
        plank.Size = Vector3.new(width, 1, 3.8); plank.CFrame = CFrame.new(0, height, startZ + i); 
        plank.Material = Enum.Material.WoodPlanks; plank.Color = Color3.fromRGB(110, 85, 60); plank.Anchored = true
    end
end

-- 進化ボード
function MapBuilder.createUpgradeBoard(parent, cost, pos, nextStage, buildingType)
    local board = Instance.new("Part", parent)
    board.Name = "UpgradeBoard"; board.Size = Vector3.new(4, 5, 0.5); board.Position = pos
    board.Color = Color3.fromRGB(50, 200, 50); board.Anchored = true
    board.CFrame = CFrame.new(board.Position) * CFrame.Angles(0, math.rad(180), 0) -- 海向き

    local sg = Instance.new("SurfaceGui", board); sg.Face = Enum.NormalId.Front
    local txt = Instance.new("TextLabel", sg); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
    txt.Text = "🔨 進化させる\n費用: " .. cost .. " Gold"; txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold; txt.TextScaled = true

    local prompt = Instance.new("ProximityPrompt", board); prompt.ActionText = "進化させる (Stage " .. nextStage .. ")"
    prompt.ObjectText = buildingType; prompt.HoldDuration = 1.0
end

-- 演出：紙吹雪
function MapBuilder.playUpgradeEffect(pos)
    local part = Instance.new("Part")
    part.Anchored, part.CanCollide = true, false; part.Transparency = 1; part.Position = pos + Vector3.new(0, 5, 0); part.Parent = workspace
    local confetti = Instance.new("ParticleEmitter")
    confetti.Texture = "rbxassetid://6071575923"
    confetti.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
    confetti.Rate = 200; confetti.Parent = part
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9060788686"; sound.Parent = part; sound:Play()
    task.delay(4, function() part:Destroy() end)
end

-- 3. レストラン (Stage 0: シェフに直接話しかけるスタイル)
function MapBuilder.buildRestaurant(stage)
    if workspace:FindFirstChild("FoodStand") then workspace.FoodStand:Destroy() end
    local folder = Instance.new("Folder", workspace); folder.Name = "FoodStand"
    folder:SetAttribute("Stage", stage)
    local basePos = Vector3.new(40, 1.5, 110)

    if stage == 0 then
        -- 焚き火 (中央)
        local bonfire = Instance.new("Part", folder)
        bonfire.Name = "Bonfire"; bonfire.Position = basePos; bonfire.Anchored = true
        Instance.new("Fire", bonfire)

        -- シェフ (左側：桟橋から見て X+)
        -- カウンターをなくし、焚き火のすぐ左側に立たせる
        local npcPos = basePos + Vector3.new(8, 0, 1) -- 焚き火の横
        createNPC("Chef", 524027791, npcPos, npcPos + Vector3.new(0, 0, 50))

        -- 進化ボード (右側：桟橋から見て X-)
        MapBuilder.createUpgradeBoard(folder, 500, basePos + Vector3.new(-8, 1.5, 0), 1, "Restaurant")
        
        print("🍳 [Stage 0] シェフに直接話しかけて魚を売れるようになりました！")
    else
        -- Stage 1 以降（将来の屋台）
        local stand = Instance.new("Part", folder)
        stand.Size = Vector3.new(15, 1, 10); stand.Position = basePos; stand.Anchored = true
        stand.Color = Color3.fromRGB(150, 100, 50)
        print("🏗️ Stage " .. stage .. " 建築中...")
    end
end

-- すべて構築
function MapBuilder.buildAll()
    MapBuilder.buildBase(); MapBuilder.buildPier(); MapBuilder.buildRestaurant(0)
    local spawn = workspace:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation", workspace)
    spawn.Position = Vector3.new(0, 5, 120); spawn.Anchored = true
end

return MapBuilder
