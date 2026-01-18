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

	local container = Instance.new("Frame", screenGui)
	container.Size = UDim2.new(0, 0, 0, 0); container.Position = UDim2.new(0.5, 0, 0.45, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5); container.BackgroundTransparency = 1
    
	local burst = Instance.new("ImageLabel", container)
	burst.Size = UDim2.new(2.5, 0, 2.5, 0); burst.Position = UDim2.new(0.5, 0, 0.5, 0); burst.AnchorPoint = Vector2.new(0.5, 0.5)
	burst.Image = "rbxassetid://6031301411"; burst.ImageColor3 = rarityColor; burst.BackgroundTransparency = 1; burst.ZIndex = 1
    
	local fishImage = Instance.new("ImageLabel", container)
	fishImage.Size = UDim2.new(1, 0, 1, 0); fishImage.Image = imageId or "rbxassetid://16024926500"
	fishImage.BackgroundTransparency = 1; fishImage.ZIndex = 10
    
	container:TweenSize(UDim2.new(0, 350, 0, 350), "Out", "Back", 0.6)
	task.spawn(function() while container.Parent do burst.Rotation += 1; task.wait(0.01) end end)
	task.wait(4)
	screenGui:Destroy()
end

fishingEvent.OnClientEvent:Connect(function(itemName, price, imageId, weightStr)
	if itemName == "HIT" then
		-- 🎣 画面中央特大HIT通知（絶対に逃さない！）
		warn("✨ [FishingUI] !!! HIT! CLICK!! を表示中 !!!")
		
		local sg = Instance.new("ScreenGui", playerGui)
		sg.Name = "ActionNotice"
		sg.DisplayOrder = 1000 -- 最前面に
		
		local label = Instance.new("TextLabel", sg)
		label.Size = UDim2.new(1, 0, 0.3, 0)
		label.Position = UDim2.new(0, 0, 0.35, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.LuckiestGuy
		label.Text = "HIT! CLICK!!"
		label.TextColor3 = Color3.fromRGB(255, 230, 0) -- 鮮やかな黄色
		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Color3.fromRGB(255, 0, 0) -- 赤い縁取り
		label.TextScaled = true
		label.ZIndex = 110
		
		-- 演出：ドーンと拡大して、少しプルプルする
		label.Size = UDim2.new(1, 0, 0, 0)
		local info = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		TweenService:Create(label, info, {Size = UDim2.new(1, 0, 0.3, 0)}):Play()
		
		-- 繰り返し点滅させる
		task.spawn(function()
			for i = 1, 6 do
				if not label.Parent then break end
				label.Visible = not label.Visible
				task.wait(0.15)
			end
			if label.Parent then label.Visible = true end
		end)
		
		-- 1.5秒後に自動消去
		task.delay(1.5, function() if sg then sg:Destroy() end end)
	else
		showCatchMessage(itemName, price, imageId, weightStr)
	end
end)
