-- MapBuilder.luau
-- 🌊 [World Builder] 最終安定版：焚き火と海辺の境界線
local MapBuilder = {}
local terrain = workspace.Terrain
local Players = game:GetService("Players")

function MapBuilder.buildBase()
    terrain:Clear()
    -- 透き通る海
    terrain:FillBlock(CFrame.new(0, -95, 0), Vector3.new(4000, 180, 4000), Enum.Material.Water)
    -- 平らな砂島（半径150）
    terrain:FillCylinder(CFrame.new(0, -4, 0), 8, 150, Enum.Material.Sand)
    
    -- ゴミ掃除
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name == "Baseplate" or obj.Name == "Sea" or (obj:IsA("BasePart") and obj.Size.X > 200) then
            obj:Destroy()
        end
    end
end

function MapBuilder.buildFoodStand()
    if workspace:FindFirstChild("FoodStand") then workspace.FoodStand:Destroy() end
    local folder = Instance.new("Folder", workspace); folder.Name = "FoodStand"
    local bPos = Vector3.new(40, 1.5, 90) -- 焚き火
    local bonfire = Instance.new("Part", folder); bonfire.Name = "Bonfire"; bonfire.Size = Vector3.new(8, 2, 8); bonfire.Position = bPos
    bonfire.Color = Color3.fromRGB(70, 50, 30); bonfire.Material = Enum.Material.Slate; bonfire.Anchored = true
    Instance.new("Fire", bonfire).Size = 10
    
    -- シェフ
    local chef = workspace:FindFirstChild("Chef") or Players:CreateHumanoidModelFromUserId(524027791)
    chef.Name = "Chef"; chef.Parent = workspace
    chef:PivotTo(CFrame.new(bPos + Vector3.new(12, 0, 0)))
    for _, p in pairs(chef:GetDescendants()) do if p:IsA("BasePart") then p.Anchored = true end end
end

function MapBuilder.buildAll()
    MapBuilder.buildBase()
    MapBuilder.buildFoodStand()
    
    -- ★究極の出現地点（焚き火と海の中間）
    local spawn = workspace:FindFirstChild("SpawnLocation") or Instance.new("SpawnLocation", workspace)
    spawn.Name = "SpawnLocation"
    -- 焚き火(Z=90) と 海辺(Z=150) の中間 = Z=120
    spawn.Position = Vector3.new(40, 5, 120) 
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Anchored = true
    spawn.Transparency = 0.5
    
    warn("✨ [World] 焚き火と海の中間にスポーン地点を設定しました。")
end

return MapBuilder
