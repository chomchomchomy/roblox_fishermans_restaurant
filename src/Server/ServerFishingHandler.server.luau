-- サービスの取得
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("FishingEvent")
local catchSound = game:GetService("SoundService"):WaitForChild("CatchSound")

-- ★NEW：お魚の大帳簿を読み込む（Sharedフォルダにあるよ）
local FishData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("FishData"))

remote.OnServerEvent:Connect(function(player, action)
	-- ヒット信号の処理
	if action == "HIT" then
		remote:FireClient(player, "HIT")
		return
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local money = leaderstats and leaderstats:FindFirstChild("Money")
	local maxBagSize = player:GetAttribute("MaxStorage") or 5

	-- ★バッグ（Backpack + 持っているモノ）の中のお魚を数える
	local fishCount = 0
	local allItems = {}
	for _, item in pairs(player.Backpack:GetChildren()) do table.insert(allItems, item) end
	for _, item in pairs(player.Character:GetChildren()) do table.insert(allItems, item) end

	for _, item in pairs(allItems) do
		if item:IsA("Tool") and item.Name ~= "FishingRod" then
			fishCount = fishCount + 1
		end
	end

	if fishCount >= maxBagSize then
		warn(player.Name .. "のバッグがいっぱいです！")
		remote:FireClient(player, "BAG_FULL")
		return
	end

	-- ★プロの抽選マジック（レア度補正あり！）
	local rarityBoost = player:GetAttribute("RarityBoost") or 1.0
	local totalChance = 0
	local boostedFishes = {}

	for _, fish in pairs(FishData) do
		local chance = fish.chance
		-- レア度が高いほどブーストの効果を大きくする
		if fish.rarity == "Rare" then
			chance = chance * rarityBoost
		elseif fish.rarity == "Legendary" then
			chance = chance * (rarityBoost * 1.5)
		end
		
		totalChance = totalChance + chance
		table.insert(boostedFishes, {fish = fish, boostedChance = chance})
	end

	local randomNumber = math.random() * totalChance
	local foundFish = nil
	local currentChance = 0

	for _, item in pairs(boostedFishes) do
		currentChance = currentChance + item.boostedChance
		if randomNumber <= currentChance then
			foundFish = item.fish
			break
		end
	end

	-- 音を鳴らす
	catchSound:Play()

	-- 結果を送信
	if foundFish then
		print("⚖️ 抽選結果: " .. foundFish.name .. " (確率: " .. foundFish.chance .. "%)")
		
		-- ★NEW：お魚を「ツール」としてバッグ（Backpack）に入れる
		-- これにより、標準のホットバーにスロットとして並びます！
		local fishTool = Instance.new("Tool")
		fishTool.Name = foundFish.name
		fishTool.RequiresHandle = false -- 持ち手なし
		fishTool:SetAttribute("Value", foundFish.price)
		fishTool.ToolTip = "売値: " .. foundFish.price .. "円"
		
		-- ホットバーに表示されるアイコン（絵文字をアイコンにするのは少し工夫が必要ですが、
		-- まずは名前がスロットに出るようになります）
		
		-- プレイヤーの持ち物（Backpack）に入れる
		fishTool.Parent = player:WaitForChild("Backpack")

		remote:FireClient(player, foundFish.name, foundFish.price, foundFish.emoji)
	end
end)
