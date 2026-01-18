-- [[ 🌟 PREMUM FISHING UI - VER 1.6 (Screen HIT Edition) 🌟 ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local fishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

warn("✅ [FishingUI] 画面中央HIT方式 V1.6 - 同期に成功しました！")

local RARITY_COLORS = {
	Common = Color3.fromRGB(150, 150, 150),
	Uncommon = Color3.fromRGB(100, 255, 100),
	Rare = Color3.fromRGB(50, 150, 255),
	Legendary = Color3.fromRGB(255, 200, 0),
}

local function showCatchMessage(itemName, price, imageId, weightStr)
	warn("🎞️ [Premium Effect] 演出開始: " .. itemName)
	
	local rarity = "Common"
	for _, fish in pairs(FishData) do
		if string.find(itemName, fish.name) then rarity = fish.rarity; break end
	end
	local rarityColor = RARITY_COLORS[rarity] or RARITY_COLORS.Common

	local screenGui = Instance.new("ScreenGui", playerGui)
	screenGui.Name = "CatchCelebration"; screenGui.DisplayOrder = 100
	
	local bg = Instance.new("Frame", screenGui)
	bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.new(0, 0, 0); bg.BackgroundTransparency = 1
	TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.6}):Play()

	-- 中央のメインコンテナ（画面のど真ん中に固定）
	local container = Instance.new("Frame", screenGui)
	container.Size = UDim2.new(0, 450, 0, 450) -- 少し大きくして余裕を持たせる
	container.Position = UDim2.new(0.5, 0, 0.5, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
    
	local burst = Instance.new("ImageLabel", container)
	burst.Size = UDim2.new(1.3, 0, 1.3, 0); burst.Position = UDim2.new(0.5, 0, 0.5, 0); burst.AnchorPoint = Vector2.new(0.5, 0.5)
	burst.Image = "rbxassetid://6031301411"; burst.ImageColor3 = rarityColor; burst.BackgroundTransparency = 1; burst.ZIndex = 1
    
	local fishImage = Instance.new("ImageLabel", container)
	fishImage.Size = UDim2.new(0.6, 0, 0.6, 0); fishImage.Position = UDim2.new(0.5, 0, 0.5, 0); fishImage.AnchorPoint = Vector2.new(0.5, 0.5)
	fishImage.Image = imageId or "rbxassetid://16445347915"
	fishImage.BackgroundTransparency = 1; fishImage.ZIndex = 10
	fishImage.ScaleType = Enum.ScaleType.Fit
	
	-- 「YOU GOT!」メッセージ（お魚のすぐ上、枠内に収める）
	local gotTitle = Instance.new("TextLabel", container)
	gotTitle.Size = UDim2.new(1, 0, 0.12, 0); gotTitle.Position = UDim2.new(0.5, 0, 0.22, 0); gotTitle.AnchorPoint = Vector2.new(0.5, 1)
	gotTitle.Text = "YOU GOT!!"; gotTitle.TextColor3 = Color3.new(1, 1, 1); gotTitle.TextScaled = true; gotTitle.Font = Enum.Font.LuckiestGuy; gotTitle.BackgroundTransparency = 1; gotTitle.ZIndex = 15
	gotTitle.TextStrokeTransparency = 0; gotTitle.TextStrokeColor3 = Color3.new(0,0,0)

	-- 魚の名前（お魚のすぐ下）
	local nameLabel = Instance.new("TextLabel", container)
	nameLabel.Size = UDim2.new(1.2, 0, 0.15, 0); nameLabel.Position = UDim2.new(0.5, 0, 0.8, 0); nameLabel.AnchorPoint = Vector2.new(0.5, 0)
	nameLabel.Text = itemName; nameLabel.TextColor3 = rarityColor; nameLabel.TextScaled = true; nameLabel.Font = Enum.Font.LuckiestGuy; nameLabel.BackgroundTransparency = 1; nameLabel.ZIndex = 15
	nameLabel.TextStrokeTransparency = 0; nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    
	-- 詳細情報
	local infoLabel = Instance.new("TextLabel", container)
	infoLabel.Size = UDim2.new(1, 0, 0.06, 0); infoLabel.Position = UDim2.new(0.5, 0, 0.96, 0); infoLabel.AnchorPoint = Vector2.new(0.5, 0)
	infoLabel.Text = "Price: $" .. price .. " | Weight: " .. weightStr
	infoLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8); infoLabel.TextScaled = true; infoLabel.Font = Enum.Font.GothamBold; infoLabel.ZIndex = 15; infoLabel.BackgroundTransparency = 1

	-- 登場アニメーション
	container.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 450)}):Play()
	
	task.spawn(function() while container.Parent do burst.Rotation += 1; task.wait(0.01) end end)

	task.wait(4)
	if screenGui and screenGui.Parent then screenGui:Destroy() end
end

local function showWarning(msg)
	local sg = Instance.new("ScreenGui", playerGui); sg.Name = "WarningUI"
	local label = Instance.new("TextLabel", sg)
	label.Size = UDim2.new(1, 0, 0.1, 0); label.Position = UDim2.new(0, 0, 0.2, 0)
	label.BackgroundTransparency = 1; label.Font = Enum.Font.LuckiestGuy
	label.Text = msg; label.TextColor3 = Color3.new(1, 0, 0); label.TextScaled = true
	label.TextStrokeTransparency = 0
	
	TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0.15, 0)}):Play()
	task.delay(2, function() if sg then sg:Destroy() end end)
end

-- 各種イベント待ち
fishingEvent.OnClientEvent:Connect(function(itemName, price, imageId, weightStr)
	if itemName == "HIT" then
		-- (ヒット演出：既にあるので省略せず維持)
		warn("✨ [FishingUI] !!! HIT! CLICK!! を表示中 !!!")
		local sg = Instance.new("ScreenGui", playerGui); sg.Name = "ActionNotice"; sg.DisplayOrder = 1000
		local label = Instance.new("TextLabel", sg)
		label.Size = UDim2.new(1, 0, 0.3, 0); label.Position = UDim2.new(0, 0, 0.35, 0)
		label.BackgroundTransparency = 1; label.Font = Enum.Font.LuckiestGuy; label.Text = "HIT! CLICK!!"; label.TextColor3 = Color3.fromRGB(255, 230, 0)
		label.TextStrokeTransparency = 0; label.TextStrokeColor3 = Color3.fromRGB(255, 0, 0); label.TextScaled = true; label.ZIndex = 110
		label.Size = UDim2.new(1, 0, 0, 0)
		TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0.3, 0)}):Play()
		task.delay(1.5, function() if sg then sg:Destroy() end end)
	elseif itemName == "BAG_FULL" then
		showWarning("BAG IS FULL!!")
	else
		showCatchMessage(itemName, price, imageId, weightStr)
	end
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localNotice = ReplicatedStorage:WaitForChild("LocalNotice")
localNotice.Event:Connect(function(msgType)
	if msgType == "BAG_FULL" then
		showWarning("BAG IS FULL!!")
	end
end)
