-- MapBuilder.luau
-- マップの設計図：Stage 0 & Stage 1（本格屋台への進化）
local MapBuilder = {}

local terrain = workspace.Terrain
local Players = game:GetService("Players")

-- NPCsを作成するヘルパー関数 (高品質アバター召喚)
local function createNPC(name, userId, pos, lookAt)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == name then obj:Destroy() end
    end
    print("👤 [" .. name .. "] を召喚中...")
    
    local model
    local success, err = pcall(function()
        model = Players:CreateHumanoidModelFromUserId(userId)
    end)

    if not success or not model then
        model = Instance.new("Model")
        local torso = Instance.new("Part", model)
        torso.Name = "Torso"; torso.Size = Vector3.new(2, 2, 1); torso.Anchored = true
        Instance.new("Humanoid", model)
        model.PrimaryPart = torso
    end

    model.Name = name
    model.Parent = workspace
    model:PivotTo(CFrame.new(pos + Vector3.new(0, 3, 0)))

    task.spawn(function()
        task.wait(2.0)
        if model and model.Parent then
            for _, p in pairs(model:GetDescendants()) do
                if p:IsA("BasePart") then p.Anchored = true; p.CanCollide = true end
            end
            local currentPos = model:GetPivot().Position
            model:PivotTo(CFrame.lookAt(currentPos, Vector3.new(currentPos.X, currentPos.Y, currentPos.Z + 10)))
        end
    end)
    return model
end

-- 進化ボード
function MapBuilder.createUpgradeBoard(parent, cost, pos, nextStage, buildingType)
    local board = Instance.new("Part", parent)
    board.Name = "UpgradeBoard"; board.Size = Vector3.new(4, 5, 0.5); board.Position = pos
    board.Color = Color3.fromRGB(50, 200, 40); board.Anchored = true
    board.CFrame = CFrame.new(board.Position) * CFrame.Angles(0, math.rad(180), 0)

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
    part.Anchored, part.CanCollide = true, false; part.Transparency = 1; part.Position = pos; part.Parent = workspace
    local confetti = Instance.new("ParticleEmitter")
    confetti.Texture = "rbxassetid://6071575923"
    confetti.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 0))})
    confetti.Rate = 300; confetti.Speed = NumberRange.new(20, 50); confetti.Parent = part
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9060788686"; sound.Parent = part; sound:Play()
    task.delay(4, function() part:Destroy() end)
end

-- 3. レストラン (進化システム)
function MapBuilder.buildRestaurant(stage)
    if workspace:FindFirstChild("FoodStand") then workspace.FoodStand:Destroy() end
    local folder = Instance.new("Folder", workspace); folder.Name = "FoodStand"
    folder:SetAttribute("Stage", stage)
    local basePos = Vector3.new(40, 1.5, 110)

    if stage == 0 then
        -- Stage 0: 焚き火キャンプ
        local bonfire = Instance.new("Part", folder); bonfire.Name = "Bonfire"; bonfire.Position = basePos; bonfire.Anchored = true
        Instance.new("Fire", bonfire)
        createNPC("Chef", 524027791, basePos + Vector3.new(8, 0, 1), basePos + Vector3.new(0, 0, 50))
        MapBuilder.createUpgradeBoard(folder, 500, basePos + Vector3.new(-8, 1.5, 0), 1, "Restaurant")
        print("🍳 [Stage 0] 焚き火レストラン構築完了")
    elseif stage == 1 then
        -- Stage 1: 小さな木製屋台
        local floor = Instance.new("Part", folder)
        floor.Size = Vector3.new(16, 1, 12); floor.Position = basePos; floor.Color = Color3.fromRGB(120, 90, 60); floor.Material = Enum.Material.WoodPlanks; floor.Anchored = true

        -- カウンター
        local counter = Instance.new("Part", folder)
        counter.Name = "SellCounter"; counter.Size = Vector3.new(14, 4, 3); counter.Position = basePos + Vector3.new(0, 2, 4); counter.Color = Color3.fromRGB(150, 110, 70); counter.Material = Enum.Material.Wood; counter.Anchored = true

        -- 屋根の支柱
        for x = -7, 7, 14 do
            for z = -5, 5, 10 do
                local p = Instance.new("Part", folder)
                p.Size = Vector3.new(1, 10, 1); p.Position = basePos + Vector3.new(x, 5, z); p.Material = Enum.Material.Wood; p.Anchored = true
            end
        end

        -- 屋根（少しオシャレに）
        local roof = Instance.new("Part", folder)
        roof.Size = Vector3.new(18, 1, 14); roof.Position = basePos + Vector3.new(0, 10, 0); roof.Color = Color3.fromRGB(180, 50, 50); roof.Material = Enum.Material.Fabric; roof.Anchored = true
        
        -- シェフの配置（カウンターの後ろ）
        createNPC("Chef", 524027791, basePos + Vector3.new(0, 0, -2), basePos + Vector3.new(0, 0, 50))
        
        -- 次の進化ボード (Stage 2へ：費用 2000 Gold)
        MapBuilder.createUpgradeBoard(folder, 2000, basePos + Vector3.new(-12, 1.5, 0), 2, "Restaurant")
        
        print("🏗️ [Stage 1] 本格屋台へ進化しました！")
    end
end

function MapBuilder.buildAll()
    MapBuilder.buildBase(); MapBuilder.buildPier(); MapBuilder.buildRestaurant(0)
    local spawn = workspace:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation", workspace)
    spawn.Position = Vector3.new(0, 5, 120); spawn.Anchored = true
end

return MapBuilder
