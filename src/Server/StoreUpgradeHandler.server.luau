-- StoreUpgradeHandler.server.luau
-- 店舗進化（StoreStage）の管理とアンロック処理

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- アップグレード用のパーツ（看板やボタン）を生成する
local function setupUpgradeSign()
    local stand = workspace:WaitForChild("FoodStand", 10)
    if not stand then return end

    -- 看板の土台
    local sign = Instance.new("Part")
    sign.Name = "UpgradeSign"
    sign.Size = Vector3.new(3, 1, 0.5)
    sign.Position = stand.PrimaryPart.Position + Vector3.new(8, 3, -5) -- 屋台の横らへん
    sign.Color = Color3.fromRGB(150, 100, 50)
    sign.Material = Enum.Material.Wood
    sign.Anchored = true
    sign.Parent = workspace

    local gui = Instance.new("SurfaceGui")
    gui.Parent = sign
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "店舗拡張：1000円\n(調理師を雇う)"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.LuckiestGuy
    textLabel.Parent = gui

    -- プロンプト
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "店舗をアップグレード！"
    prompt.ObjectText = "夢のマイショップ"
    prompt.HoldDuration = 2.0
    prompt.Parent = sign

    prompt.Triggered:Connect(function(player)
        local stage = player:GetAttribute("StoreStage") or 0
        local leaderstats = player:FindFirstChild("leaderstats")
        local money = leaderstats and leaderstats:FindFirstChild("Money")

        if not money then return end

        if stage == 0 then
            local cost = 1000
            if money.Value >= cost then
                money.Value -= cost
                player:SetAttribute("StoreStage", 1)
                
                -- 通報エフェクトとか
                print("🎊 [" .. player.Name .. "] がレストランをアップグレードしました！")
                textLabel.Text = "店舗拡張：完了！\n(シェフが到着しました)"
                prompt.Enabled = false
            else
                print("❌ お金が足りません！ (必要: " .. cost .. "円)")
            end
        else
            print("すでに追加ステージに到達しています。")
        end
    end)
end

task.spawn(setupUpgradeSign)
