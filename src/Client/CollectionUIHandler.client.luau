-- CollectionUIHandler.client.luau
-- 🎓 アセットマネージャーの解説：
-- プレミアムなデザインの魚図鑑UI。データから自動的にグリッドを生成します。

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

-- UIの作成（メインフレーム）
local function createUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CollectionGui"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- 開くためのボタン
    local openBtn = Instance.new("TextButton")
    openBtn.Name = "OpenBtn"
    openBtn.Size = UDim2.new(0, 50, 0, 50)
    openBtn.Position = UDim2.new(0, 20, 0.5, -25)
    openBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
    openBtn.Text = "📘"
    openBtn.TextSize = 30
    openBtn.Font = Enum.Font.GothamBold
    openBtn.TextColor3 = Color3.new(1,1,1)
    openBtn.Parent = gui
    
    local corner = Instance.new("UICorner", openBtn)
    corner.CornerRadius = UDim.new(0, 10)

    -- メインの図鑑枠
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.2, 0, 1.2, 0) -- 最初は下に隠しておく
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Thickness = 3
    stroke.Color = Color3.fromRGB(50, 180, 255)
    
    -- タイトル
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundTransparency = 1
    title.Text = "🩵 FISH COLLECTION 🩵"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    -- スクロールエリア
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0.95, 0, 0.8, 0)
    scroll.Position = UDim2.new(0.025, 0, 0.15, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.Parent = mainFrame
    
    local grid = Instance.new("UIGridLayout", scroll)
    grid.CellSize = UDim2.new(0, 100, 0, 100)
    grid.CellPadding = UDim2.new(0, 10, 0, 10)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- スロットの生成
    local function updateGrid()
        scroll:ClearAllChildren()
        Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0, 100, 0, 100)
        
        for _, data in pairs(FishData) do
            local slot = Instance.new("Frame")
            slot.Name = data.id
            slot.BackgroundColor3 = Color3.fromRGB(40, 45, 50)
            slot.Parent = scroll
            Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 10)
            
            local isDiscovered = player:GetAttribute("Discovered_" .. data.id)
            
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0.8, 0, 0.8, 0)
            icon.Position = UDim2.new(0.1, 0, 0.1, 0)
            icon.BackgroundTransparency = 1
            icon.Parent = slot
            
            if isDiscovered then
                icon.Image = data.imageId
                -- レア度に応じた縁取り
                local s = Instance.new("UIStroke", slot)
                s.Thickness = 2
                if data.rarity == "Legendary" then s.Color = Color3.fromRGB(255, 215, 0)
                elseif data.rarity == "Rare" then s.Color = Color3.fromRGB(200, 50, 255)
                else s.Color = Color3.fromRGB(100, 100, 100) end
            else
                icon.Image = "rbxassetid://12345678" -- シルエット（仮）
                icon.ImageColor3 = Color3.new(0,0,0)
                icon.ImageTransparency = 0.5
            end
        end
    end

    -- 開閉アニメーション
    local isOpen = false
    openBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetPos = isOpen and UDim2.new(0.2, 0, 0.15, 0) or UDim2.new(0.2, 0, 1.2, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = targetPos}):Play()
        if isOpen then updateGrid() end
    end)
end

task.spawn(createUI)
