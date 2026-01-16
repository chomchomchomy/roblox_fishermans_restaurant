-- MapBuilder.luau
-- マップの設計図をコードとして保存するモジュール
local MapBuilder = {}

local terrain = workspace.Terrain

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
    counter.Name = "Counter"
    counter.Size = Vector3.new(16, 4, 2)
    counter.Position = basePos + Vector3.new(0, 2, -8) -- 島の中心側
    counter.Color = Color3.fromRGB(80, 60, 40)
    counter.Material = Enum.Material.Wood
    counter.Anchored, counter.Parent = true, folder

    -- 3. （調理台は削除しました：視界スッキリ！）

    -- 4. 柱
    for x = -1, 1, 2 do
        for z = -1, 1, 2 do
            local pole = Instance.new("Part")
            pole.Size = Vector3.new(1.2, 10, 1.2)
            pole.Position = basePos + Vector3.new(7 * x, 5.5, 10 * z)
            pole.Color = Color3.fromRGB(80, 60, 40)
            pole.Material = Enum.Material.Wood
            pole.Anchored, pole.Parent = true, folder
        end
    end

    -- 5. 屋根
    local roof = Instance.new("Part")
    roof.Name = "Roof"
    roof.Size = Vector3.new(20, 1, 26)
    roof.Position = basePos + Vector3.new(0, 10.5, 0)
    roof.Color = Color3.fromRGB(160, 40, 40)
    roof.Material = Enum.Material.Fabric
    roof.Anchored, roof.Parent = true, folder

    print("🍱 [World Builder] The Stand is now next to the Pier, facing the Island!")
end

-- すべてを一括構築
function MapBuilder.buildAll()
    MapBuilder.buildBase()
    MapBuilder.buildPier()
    MapBuilder.buildFoodStand() -- 屋台を追加！
    
    -- スパーン地点を中央に！
    local spawn = workspace:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation", workspace)
    spawn.Position = Vector3.new(0, 5, 0)
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Anchored = true
    
    print("✅ Full Map & Restaurant Synchronized from Code!")
end

return MapBuilder
