-- MapBuilder.luau
-- マップの設計図をコードとして保存するモジュール
local MapBuilder = {}

local terrain = workspace.Terrain

-- NPCsを作成するヘルパー関数 (高品質なR6キャラクター風)
local function createNPC(name, color, pos, lookAt)
    local model = Instance.new("Model")
    model.Name = name
    
    -- 胴体 (Torso)
    local torso = Instance.new("Part", model)
    torso.Name = "Torso"
    torso.Size = Vector3.new(2, 2, 1)
    torso.Color = color
    torso.Material = Enum.Material.SmoothPlastic
    torso.Anchored = true
    
    -- 頭 (Head)
    local head = Instance.new("Part", model)
    head.Name = "Head"
    head.Size = Vector3.new(1.2, 1.2, 1.2)
    head.Shape = Enum.PartType.Ball
    head.Color = Color3.fromRGB(255, 204, 153) -- 肌色
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = true
    
    -- 腕 (Arms)
    local la = Instance.new("Part", model)
    la.Name = "LeftArm"
    la.Size = Vector3.new(1, 2, 1)
    la.Color = Color3.fromRGB(255, 204, 153)
    la.Anchored = true
    
    local ra = Instance.new("Part", model)
    ra.Name = "RightArm"
    ra.Size = Vector3.new(1, 2, 1)
    ra.Color = Color3.fromRGB(255, 204, 153)
    ra.Anchored = true
    
    -- 足 (Legs)
    local ll = Instance.new("Part", model)
    ll.Name = "LeftLeg"
    ll.Size = Vector3.new(1, 2, 1)
    ll.Color = Color3.fromRGB(50, 50, 50) -- ズボンの色
    ll.Anchored = true
    
    local rl = Instance.new("Part", model)
    rl.Name = "RightLeg"
    rl.Size = Vector3.new(1, 2, 1)
    rl.Color = Color3.fromRGB(50, 50, 50)
    rl.Anchored = true
    
    -- 位置関係を人間らしく配置
    torso.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0), lookAt)
    head.CFrame = torso.CFrame * CFrame.new(0, 1.6, 0)
    la.CFrame = torso.CFrame * CFrame.new(-1.5, 0, 0)
    ra.CFrame = torso.CFrame * CFrame.new(1.5, 0, 0)
    ll.CFrame = torso.CFrame * CFrame.new(-0.5, -2, 0)
    rl.CFrame = torso.CFrame * CFrame.new(0.5, -2, 0)
    
    local hum = Instance.new("Humanoid", model)
    model.PrimaryPart = torso
    model.Parent = workspace
    return model
end

-- 1. 世界の土台（海と島）
function MapBuilder.buildBase()
    -- 地形を一旦リセット
    terrain:Clear()
    
    -- 巨大な深海 (深さ180スタッド)
    -- 中心を少し下に下げて、表面が海面(Y=0)の少し下に来るようにする
    terrain:FillBlock(CFrame.new(0, -95, 0), Vector3.new(4000, 180, 4000), Enum.Material.Water)
    
    -- 快適な砂浜の島 (半径150スタッド、厚さ10スタッドの円盤)
    -- Cylinderはデフォルトで垂直方向(Y軸)を向いているので、回転は不要！
    -- Position = (0, -4, 0) で、上端が Y=1 になるように設定
    local islandCFrame = CFrame.new(0, -4, 0)
    terrain:FillCylinder(islandCFrame, 8, 150, Enum.Material.Sand)
    
    -- ベースプレートがあれば消す
    if workspace:FindFirstChild("Baseplate") then
        workspace.Baseplate:Destroy()
    end
    
    print("🏝️ Base Island and Ocean built (Flat version)!")
end

-- 2. 桟橋（ Pier）の建築
function MapBuilder.buildPier()
    -- 既存の桟橋があれば削除
    if workspace:FindFirstChild("FishingPier") then
        workspace.FishingPier:Destroy()
    end

    local folder = Instance.new("Folder", workspace)
    folder.Name = "FishingPier"
    
    -- 島の中心(0,0,0)から、海(Z方向)に向かって伸ばす
    -- 半径150の島なので、130あたりから開始して海へ突き出す
    local startZ = 130 
    local length = 100
    local height = 2.5 -- 砂浜(Y=1)から少し浮かせた高さ
    local width = 14
    
    for i = 0, length, 4 do
        local plank = Instance.new("Part")
        plank.Name = "Plank"
        plank.Size = Vector3.new(width, 1, 3.8)
        plank.CFrame = CFrame.new(0, height, startZ + i)
        plank.Color = Color3.fromRGB(110, 85, 60)
        plank.Material = Enum.Material.WoodPlanks
        plank.Transparency = 0 -- 念のため
        plank.Anchored = true
        plank.Parent = folder
        
        -- 支柱
        if i % 12 == 0 then
            for side = -1, 1, 2 do
                local post = Instance.new("Part")
                post.Name = "Post"
                post.Size = Vector3.new(2, 40, 2)
                post.Position = plank.Position + Vector3.new((width/2 - 1) * side, -20, 0)
                post.Color = Color3.fromRGB(70, 55, 45)
                post.Material = Enum.Material.Wood
                post.Anchored = true
                post.Parent = folder
            end
        end
    end
    print("🌊 Pier extended into the deep ocean!")
end

-- 3. 海辺の屋台（Food Stand）の建築
function MapBuilder.buildFoodStand()
    if workspace:FindFirstChild("FoodStand") then
        workspace.FoodStand:Destroy()
    end

    local folder = Instance.new("Folder", workspace)
    folder.Name = "FoodStand"
    
    -- 海を背にした（島を向いた）ときに「左奥」へ移動
    -- 桟橋が X=0 なので X=40, 島の内側なので Z=90 
    local basePos = Vector3.new(40, 1.5, 90) 
    
    -- 1. 床
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(16, 1.2, 22)
    floor.Position = basePos
    floor.Color = Color3.fromRGB(110, 90, 70)
    floor.Material = Enum.Material.WoodPlanks
    floor.Anchored, floor.Parent = true, folder

    -- 2. メインカウンター (島側)
    local counter = Instance.new("Part")
    counter.Name = "SellCounter"
    counter.Size = Vector3.new(16, 4, 2)
    counter.Position = basePos + Vector3.new(0, 2, -8) -- 島の中心側
    counter.Color = Color3.fromRGB(80, 60, 40)
    counter.Material = Enum.Material.Wood
    counter.Anchored, counter.Parent = true, folder

    -- 3. （調理台は削除しました：視界スッキリ！）

    -- 4. 柱 (ショップに合わせて高さを14.0に！)
    for x = -1, 1, 2 do
        for z = -1, 1, 2 do
            local pole = Instance.new("Part", folder)
            pole.Size = Vector3.new(1.2, 14, 1.2)
            pole.Position = basePos + Vector3.new(7 * x, 7.5, 10 * z)
            pole.Color = Color3.fromRGB(80, 60, 40)
            pole.Material = Enum.Material.Wood
            pole.Anchored = true
        end
    end

    -- 5. 屋根 (社長の指示で「赤」に変更！)
    local roof = Instance.new("Part")
    roof.Name = "Roof"
    roof.Size = Vector3.new(20, 1, 26)
    roof.Position = basePos + Vector3.new(0, 14.5, 0)
    roof.Color = Color3.fromRGB(160, 40, 40) -- 情熱の赤！
    roof.Material = Enum.Material.Metal
    roof.Anchored, roof.Parent = true, folder

    -- 6. 看板 (RESTAURANT)
    -- ... (既存の看板コードはそのまま)
    local sign = Instance.new("Part")
    sign.Name = "RestaurantSign"
    sign.Size = Vector3.new(16, 4, 1)
    sign.Position = basePos + Vector3.new(0, 17.0, -12.5) 
    sign.Color = Color3.fromRGB(0, 255, 150)
    sign.Material = Enum.Material.Neon
    sign.Anchored, sign.Parent = true, folder
    -- (プロンプト文字設定は省略せず維持)
    local sg = Instance.new("SurfaceGui", sign)
    sg.Face = Enum.NormalId.Front
    sg.LightInfluence = 0
    local text = Instance.new("TextLabel", sg)
    text.Size = UDim2.new(0.9, 0, 0.8, 0)
    text.Position = UDim2.new(0.05, 0, 0.1, 0)
    text.BackgroundTransparency = 1
    text.Text = "RESTAURANT"
    text.TextColor3 = Color3.fromRGB(255, 0, 0)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold

    -- 7. 客席セット (テーブルと椅子)
    for i = -1, 1, 2 do
        local tablePos = basePos + Vector3.new(5 * i, 1.5, 2)
        local table = Instance.new("Part", folder)
        table.Name = "CustomerTable"
        table.Size = Vector3.new(4, 3, 4)
        table.Position = tablePos
        table.Color = Color3.fromRGB(100, 80, 60)
        table.Material = Enum.Material.Wood
        table.Anchored = true

        -- 料理提供エリア (透明なパーツ)
        local serveArea = Instance.new("Part", table)
        serveArea.Name = "ServeArea"
        serveArea.Size = Vector3.new(3, 0.2, 3)
        serveArea.Position = tablePos + Vector3.new(0, 1.6, 0)
        serveArea.Transparency = 0.8
        serveArea.Color = Color3.fromRGB(255, 255, 255)
        serveArea.Anchored = true

        -- 椅子
        for side = -1, 1, 2 do
            local chair = Instance.new("Part", folder)
            chair.Size = Vector3.new(2, 1.5, 2)
            chair.Position = tablePos + Vector3.new(0, 0, 3.5 * side)
            chair.Color = Color3.fromRGB(80, 60, 40)
            chair.Anchored = true
        end
    end

    -- 8. 最新鋭グリル (CookerHandlerがこれを使います)
    local grill = Instance.new("Part", folder)
    grill.Name = "CookingStation"
    grill.Size = Vector3.new(4, 0.5, 4)
    grill.Position = basePos + Vector3.new(-4, 2.3, -8) -- カウンター横
    grill.Color = Color3.fromRGB(30, 30, 30)
    grill.Material = Enum.Material.Metal
    grill.Anchored = true

    -- 煙と火のエフェクト
    local smoke = Instance.new("Smoke", grill)
    smoke.Enabled = false
    smoke.Size = 2
    smoke.Opacity = 0.3

    -- 9. シェフNPC (カウンターの後ろ：Z軸を奥へ)
    createNPC("Chef", Color3.fromRGB(200, 50, 50), basePos + Vector3.new(0, 0, -4), basePos + Vector3.new(0, 0, -20))

    print("🍱 [ワールドビルダー] レストランの内装とシェフの配置が完了しました！")
end

-- 4. アップグレード・ショップの建築
function MapBuilder.buildUpgradeShop()
    if workspace:FindFirstChild("UpgradeShop") then
        workspace.UpgradeShop:Destroy()
    end

    local folder = Instance.new("Folder", workspace)
    folder.Name = "UpgradeShop"

    -- 屋台の隣（X=68）に配置
    local basePos = Vector3.new(68, 1.5, 90)

    -- 1. 床 (少し高級感のあるダークウッド)
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(16, 1.2, 22)
    floor.Position = basePos
    floor.Color = Color3.fromRGB(60, 50, 40)
    floor.Material = Enum.Material.WoodPlanks
    floor.Anchored, floor.Parent = true, folder

    -- 2. アップグレードカウンター
    local counter = Instance.new("Part")
    counter.Name = "UpgradeCounter" -- 指定通りの名前
    counter.Size = Vector3.new(16, 4, 3)
    counter.Position = basePos + Vector3.new(0, 2, -7)
    counter.Color = Color3.fromRGB(50, 100, 150) -- 青ベース
    counter.Material = Enum.Material.SmoothPlastic
    counter.Anchored, counter.Parent = true, folder

    -- 3. ネオン看板 (LEGENDARY GEAR) - 屋根の上にぴったり配置
    local sign = Instance.new("Part")
    sign.Name = "ShopSign"
    sign.Size = Vector3.new(16, 4, 1)
    -- 屋根の高さ14.5 + 厚み0.5 + 看板の半分2.0 = 17.0 でぴったり接着
    sign.Position = basePos + Vector3.new(0, 17.0, -12.5) 
    sign.Color = Color3.fromRGB(0, 180, 255)
    sign.Material = Enum.Material.Neon
    sign.Anchored, sign.Parent = true, folder

    -- 看板のテキスト (SurfaceGui)
    local sg = Instance.new("SurfaceGui", sign)
    sg.Face = Enum.NormalId.Front
    sg.LightInfluence = 0
    local text = Instance.new("TextLabel", sg)
    -- 文字を枠内に収めつつ最大化 (0.9, 0.8)
    text.Size = UDim2.new(0.9, 0, 0.8, 0)
    text.Position = UDim2.new(0.05, 0, 0.1, 0)
    text.BackgroundTransparency = 1
    text.Text = "LEGENDARY GEAR" -- 伝説の装備！
    text.TextColor3 = Color3.fromRGB(255, 0, 0) -- 燃えるような赤
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold

    -- 7. 背面の壁 (展示用：新設)
    local backWall = Instance.new("Part")
    backWall.Name = "BackWall"
    backWall.Size = Vector3.new(16, 14, 1)
    backWall.Position = basePos + Vector3.new(0, 7.5, 10.5) -- 柱の奥に配置
    backWall.Color = Color3.fromRGB(50, 50, 55)
    backWall.Material = Enum.Material.Wood
    backWall.Anchored, backWall.Parent = true, folder

    -- 4. 展示用の「壁掛け」釣り竿 (突き抜け防止版)
    for i = -1, 1 do
        -- 竿のモデル用グループ
        local rodModel = Instance.new("Model", folder)
        rodModel.Name = "DisplayRodModel"

        -- 竿の持ち手 (Handle)
        local handle = Instance.new("Part", rodModel)
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.6, 3, 0.6)
        -- 壁（Z=10.5）に沿わせて配置
        handle.CFrame = CFrame.new(basePos + Vector3.new(5 * i, 3.5, 9.5))
        handle.Color = Color3.fromRGB(30, 30, 30)
        handle.Material = Enum.Material.Rubber
        handle.Anchored = true

        -- リール (Reel)
        local reel = Instance.new("Part", rodModel)
        reel.Name = "Reel"
        reel.Size = Vector3.new(0.8, 0.8, 0.8)
        reel.CFrame = handle.CFrame * CFrame.new(0, 0.5, -0.4)
        reel.Color = Color3.fromRGB(150, 150, 150)
        reel.Material = Enum.Material.Metal
        reel.Anchored = true

        -- 竿の本体 (RodBody) - さらに短く(サイズ7)して、屋根(14)に絶対に当たらないように調整
        local rodBody = Instance.new("Part", rodModel)
        rodBody.Name = "RodBody"
        rodBody.Size = Vector3.new(0.3, 7, 0.3)
        rodBody.CFrame = handle.CFrame * CFrame.new(0, 4.5, 0) -- 位置を調整
        rodBody.Color = Color3.fromRGB(200, 180, 50) -- 高級感のあるゴールド
        rodBody.Material = Enum.Material.Metal
        rodBody.Anchored = true
    end

    -- 5. 柱 (力強いメタリックな柱)
    for x = -1, 1, 2 do
        for z = -1, 1, 2 do
            local pole = Instance.new("Part", folder)
            pole.Size = Vector3.new(1.2, 14, 1.2)
            pole.Position = basePos + Vector3.new(7 * x, 7.5, 10 * z)
            pole.Color = Color3.fromRGB(40, 40, 40)
            pole.Material = Enum.Material.Metal
            pole.Anchored = true
        end
    end

    -- 6. 屋根 (位置を高く)
    local roof = Instance.new("Part")
    roof.Name = "Roof"
    roof.Size = Vector3.new(20, 1, 26)
    roof.Position = basePos + Vector3.new(0, 14.5, 0)
    roof.Color = Color3.fromRGB(40, 50, 70)
    roof.Material = Enum.Material.SmoothPlastic
    roof.Anchored, roof.Parent = true, folder

    -- 8. ベテラン漁師NPC (カウンターの後ろ：Z軸を奥へ)
    createNPC("VeteranFisherman", Color3.fromRGB(50, 80, 150), basePos + Vector3.new(0, 0, -3), basePos + Vector3.new(0, 0, -20))

    print("🛠️ [ワールドビルダー] 釣具屋にベテラン漁師が着任しました！")
end

-- すべてを一括構築
function MapBuilder.buildAll()
    -- 【重要】古いNPCが残っている場合は全て削除（重複防止の徹底）
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == "Chef" or child.Name == "VeteranFisherman" or child.Name == "OldChef" then
            child:Destroy()
        end
    end

    MapBuilder.buildBase()
    MapBuilder.buildPier()
    MapBuilder.buildFoodStand()
    MapBuilder.buildUpgradeShop()
    
    -- スポーン地点を桟橋とショップの近くに配置
    local spawn = workspace:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation", workspace)
    spawn.Position = Vector3.new(0, 5, 120) 
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Anchored = true
    
    print("✅ [ワールドビルダー] 古いデータを一掃し、全ての要素をクリーンに同期しました！")
end

return MapBuilder
