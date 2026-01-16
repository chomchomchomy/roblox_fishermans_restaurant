-- MapBuilder.luau
-- マップの設計図：Stage 0 徹底リファイン版（焚き火とリアルな丸太）
local MapBuilder = {}

local terrain = workspace.Terrain
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 演習：紙吹雪エフェクト
function MapBuilder.playUpgradeEffect(pos)
    local part = Instance.new("Part")
    part.Anchored, part.CanCollide = true, false
    part.Transparency = 1; part.Position = pos + Vector3.new(0, 5, 0); part.Parent = workspace

    local confetti = Instance.new("ParticleEmitter")
    confetti.Texture = "rbxassetid://6071575923"
    confetti.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    confetti.Rate = 300; confetti.Parent = part

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9060788686"
    sound.Parent = part; sound:Play()

    task.delay(3, function() confetti.Enabled = false; task.wait(4); part:Destroy() end)
end

-- 1. 世界の土台（フラットな砂浜）
function MapBuilder.buildBase()
    terrain:Clear()
    terrain:FillBlock(CFrame.new(0, -52, 0), Vector3.new(2000, 100, 2000), Enum.Material.Water)
    terrain:FillBlock(CFrame.new(0, -5, 0), Vector3.new(300, 10, 300), Enum.Material.Sand)
    if workspace:FindFirstChild("Baseplate") then workspace.Baseplate:Destroy() end
end

-- 2. 桟橋
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

-- 進化用ボード
function MapBuilder.createUpgradeBoard(parent, cost, pos, nextStage, buildingType)
    local board = Instance.new("Part", parent)
    board.Name = "UpgradeBoard"; board.Size = Vector3.new(4, 5, 0.5); board.Position = pos
    board.Color = Color3.fromRGB(50, 200, 50); board.Anchored = true

    local sg = Instance.new("SurfaceGui", board); sg.Face = Enum.NormalId.Front
    local txt = Instance.new("TextLabel", sg); txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
    txt.Text = "🔨 進化させる\n費用: " .. cost .. " Gold"; txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.Font = Enum.Font.GothamBold; txt.TextScaled = true

    local prompt = Instance.new("ProximityPrompt", board); prompt.ActionText = "進化させる (Stage " .. nextStage .. ")"
    prompt.ObjectText = buildingType; prompt.HoldDuration = 1.0
end

-- 3. レストラン (Stage 0: 焚き火とリアルな丸太)
function MapBuilder.buildRestaurant(stage)
    if workspace:FindFirstChild("FoodStand") then workspace.FoodStand:Destroy() end
    local folder = Instance.new("Folder", workspace); folder.Name = "FoodStand"
    folder:SetAttribute("Stage", stage)
    local basePos = Vector3.new(40, 1.5, 90)

    if stage == 0 then
        -- 焚き火
        local bonfire = Instance.new("Part", folder)
        bonfire.Name = "Bonfire"; bonfire.Size = Vector3.new(4, 1, 4); bonfire.Position = basePos; 
        bonfire.Color = Color3.fromRGB(50, 30, 20); bonfire.Material = Enum.Material.Wood; bonfire.Anchored = true
        Instance.new("Fire", bonfire).Size = 6

        -- リアルな丸太の椅子 (MeshPartを使用)
        for i = -1, 1, 2 do
            local log = Instance.new("MeshPart", folder)
            log.Name = "LogSeat"
            -- ツールボックスでよく使われる高品質な丸太のMeshID
            log.MeshId = "rbxassetid://474339116" 
            log.TextureID = "rbxassetid://474339145"
            log.Size = Vector3.new(2, 6, 2)
            -- 横に倒して配置
            log.CFrame = CFrame.new(basePos + Vector3.new(6 * i, 0, 0)) * CFrame.Angles(0, 0, math.pi/2)
            log.Anchored = true
        end

        -- 進化ボード
        MapBuilder.createUpgradeBoard(folder, 500, basePos + Vector3.new(12, 2.5, 0), 1, "Restaurant")
        
        print("🔥 [Stage 0] 焚き火と丸太のみの静かなスタートです")
    else
        -- Stage 1以降は一旦、看板のみ出す（後ほど各Stageをリタイア）
        local tempSign = Instance.new("Part", folder)
        tempSign.Size = Vector3.new(10, 5, 1); tempSign.Position = basePos + Vector3.new(0, 5, 0); tempSign.Anchored = true
        print("🏗️ Stage " .. stage .. " は現在建築中です...")
    end
end

-- 4. 釣具屋 (今は保留)
function MapBuilder.buildUpgradeShop(stage)
    if workspace:FindFirstChild("UpgradeShop") then workspace.UpgradeShop:Destroy() end
    -- 今は何もしない
end

-- 5. すべてを構築
function MapBuilder.buildAll()
    MapBuilder.buildBase()
    MapBuilder.buildPier()
    MapBuilder.buildRestaurant(0)
    MapBuilder.buildUpgradeShop(0)
    
    local spawn = workspace:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation", workspace)
    spawn.Position = Vector3.new(0, 5, 120); spawn.Anchored = true
    print("🚀 [ワールドビルダー] 第1歩：焚き火の完成です！")
end

return MapBuilder
