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

	-- ★プロの抽選マジック：帳簿の中から1つ選ぶよ
	local totalChance = 0
	for _, fish in pairs(FishData) do
		totalChance = totalChance + fish.chance
	end

	local randomNumber = math.random(1, totalChance)
	local foundFish = nil
	local currentChance = 0

	for _, fish in pairs(FishData) do
		currentChance = currentChance + fish.chance
		if randomNumber <= currentChance then
			foundFish = fish
			break
		end
	end

	-- 音を鳴らす
	catchSound:Play()

	-- 結果を送信（大帳簿に書いてある情報をそのまま送る！）
	if foundFish then
		print("⚖️ 抽選結果: " .. foundFish.name .. " (確率: " .. foundFish.chance .. "%)")
		if money then money.Value = money.Value + foundFish.price end
		remote:FireClient(player, foundFish.name, foundFish.price, foundFish.emoji)
	end
end)
