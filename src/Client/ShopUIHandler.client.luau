-- ShopUIHandler.client.luau
-- 釣具屋のUI（購入・アップグレード画面）

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ShopEvent = ReplicatedStorage:WaitForChild("ShopEvent")
local RodData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RodData"))

local function createShopUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopGui"
	screenGui.Enabled = false
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- 背景
	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.new(0, 500, 0, 400)
	frame.Position = UDim2.new(0.5, -250, 0.5, -200)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 15)
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(50, 100, 255)
	uiStroke.Thickness = 3
	uiStroke.Parent = frame

	-- タイトル
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "🛠️ LEGENDARY GEAR SHOP"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 24
	title.Font = Enum.Font.GothamBlack
	title.Parent = frame

	-- 閉じるボタン
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -50, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = frame
	
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
	closeBtn.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)

	-- アイテムリスト
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, -40, 1, -100)
	scrollingFrame.Position = UDim2.new(0, 20, 0, 70)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
	scrollingFrame.ScrollBarThickness = 5
	scrollingFrame.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scrollingFrame

	-- バッグ拡張ボタン
	local function createItem(name, desc, getCostFunc, onBuy)
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, -10, 0, 80)
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scrollingFrame
		
		Instance.new("UICorner", itemFrame)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
		nameLabel.Position = UDim2.new(0, 15, 0, 10)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 18
		nameLabel.Parent = itemFrame

		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.6, 0, 0, 30)
		descLabel.Position = UDim2.new(0, 15, 0, 40)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = desc
		descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 14
		descLabel.Parent = itemFrame

		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0, 120, 0, 50)
		buyBtn.Position = UDim2.new(1, -135, 0.5, -25)
		buyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.Font = Enum.Font.GothamBlack
		buyBtn.TextSize = 16
		buyBtn.Parent = itemFrame
		
		Instance.new("UICorner", buyBtn)

		-- 更新用
		local function update()
			local cost = getCostFunc()
			buyBtn.Text = "BUY: " .. cost .. "円"
		end
		
		buyBtn.MouseButton1Click:Connect(function()
			onBuy()
		end)
		
		update()
		return update
	end

	-- バッグ
	createItem("🎒 バッグ拡張", "持ち運び量を増やす", 
		function()
			local level = player:GetAttribute("BagLevel") or 1
			return level * 300
		end,
		function()
			ShopEvent:FireServer("BUY_UPGRADE", "BAG_SIZE")
		end
	)

	-- 竿の速度
	createItem("⚡ 釣りの速度", "魚がかかるのが早くなる", 
		function()
			local level = player:GetAttribute("FishingSpeedLevel") or 1
			return level * 200
		end,
		function()
			ShopEvent:FireServer("BUY_UPGRADE", "FISHING_SPEED")
		end
	)

	-- 竿の新調
	local function updateRodItem()
		local currentTier = player:GetAttribute("RodTier") or 1
		local nextTier = currentTier + 1
		local rodInfo = RodData[nextTier]
		
		if rodInfo then
			return createItem("🎣 竿の新調: " .. rodInfo.name, "速度とレア度が大幅アップ！",
				function() return rodInfo.price end,
				function() ShopEvent:FireServer("BUY_ROD") end
			)
		end
	end
	
	local refreshRod = updateRodItem()

	return screenGui
end

local shopGui = createShopUI()

ShopEvent.OnClientEvent:Connect(function(action)
	if action == "OPEN" then
		shopGui.Enabled = true
	elseif action == "SUCCESS" then
		-- 更新したいけど、今は一旦閉じるか、自動でラベルが変わるか
		print("購入成功！")
	end
end)
