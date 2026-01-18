-- [Rojo] ServerFishingHandler.server.luau
-- 🎓 同期の確実性を高めるための再プッシュ。画像なし魚の排除ロジック内蔵。

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("FishingEvent")
local catchSound = game:GetService("SoundService"):WaitForChild("CatchSound")
local FishData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishData"))

warn("🌊 [ServerFishing] 最新の抽選システム（画像必須モード）が稼働しました！")

remote.OnServerEvent:Connect(function(player, action)
	if action == "HIT" then
		remote:FireClient(player, "HIT")
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local money = leaderstats and leaderstats:FindFirstChild("Money")
	local maxBagSize = player:GetAttribute("MaxStorage") or 5

	local fishCount = 0
	local allItems = {}
	for _, item in pairs(player.Backpack:GetChildren()) do table.insert(allItems, item) end
	for _, item in pairs(player.Character:GetChildren()) do table.insert(allItems, item) end
	for _, item in pairs(allItems) do
		if item:IsA("Tool") and item.Name ~= "FishingRod" then fishCount = fishCount + 1 end
	end

	if fishCount >= maxBagSize then
		remote:FireClient(player, "BAG_FULL")
		return
	end

	local rarityBoost = player:GetAttribute("RarityBoost") or 1.0
	local totalChance = 0
	local boostedFishes = {}

	for _, fish in pairs(FishData) do
		-- ★厳格な画像・出現率チェック
		local hasImage = fish.imageId and fish.imageId ~= "" and fish.imageId ~= "rbxassetid://0"
		local chance = fish.chance or 0
		if not hasImage or chance <= 0 then continue end
		
		if fish.rarity == "Rare" then chance = chance * rarityBoost
		elseif fish.rarity == "Legendary" then chance = chance * (rarityBoost * 1.5) end
		
		totalChance = totalChance + chance
		table.insert(boostedFishes, {fish = fish, boostedChance = chance})
	end

	local randomNumber = math.random() * totalChance
	local foundFish = nil
	local currentChance = 0

	for _, item in pairs(boostedFishes) do
		currentChance = currentChance + item.boostedChance
		if randomNumber <= currentChance then foundFish = item.fish; break end
	end

	if foundFish then
		catchSound:Play()
		print("⚖️ 抽選成功: " .. foundFish.name)
		
		local minW = foundFish.minWeight or 0.1
		local maxW = foundFish.maxWeight or 1.0
		local weight = minW + (math.random() * (maxW - minW))
		local weightStr = string.format("%.2f", weight) .. "kg"

		local fishTool = Instance.new("Tool")
		fishTool.Name = foundFish.name .. " (" .. weightStr .. ")"
		fishTool.TextureId = foundFish.imageId
		fishTool.RequiresHandle = false
		fishTool:SetAttribute("Value", foundFish.price)
		fishTool.Parent = player:WaitForChild("Backpack")

		remote:FireClient(player, foundFish.name, foundFish.price, foundFish.imageId, weightStr)
	end
end)
