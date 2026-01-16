-- Leaderboard.server.luau
-- プレイヤーのデータ管理（お金・能力値・セーブ機能）

local DataStoreService = game:GetService("DataStoreService")
local PlayerData = DataStoreService:GetDataStore("FishermansData_V1")
local Players = game:GetService("Players")

local function setupPlayer(player)
	-- leaderstats (右上の表示)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new("IntValue")
	money.Name = "Money"
	money.Parent = leaderstats

	-- ★セーブデータの読み込み
	local success, data = pcall(function()
		return PlayerData:GetAsync(tostring(player.UserId))
	end)

	if success and data then
		-- 保存されたデータがあれば反映
		money.Value = data.Money or 0
		player:SetAttribute("MaxStorage", data.MaxStorage or 5)
		player:SetAttribute("FishingSpeed", data.FishingSpeed or 1)
		player:SetAttribute("StoreStage", data.StoreStage or 0)
		print("💾 [" .. player.Name .. "] のデータを復元しました")
	else
		-- 初めてのプレイ、またはエラー時は初期値
		money.Value = 0
		player:SetAttribute("MaxStorage", 5)
		player:SetAttribute("FishingSpeed", 1)
		player:SetAttribute("StoreStage", 0)
		print("🆕 [" .. player.Name .. "] の新規データを作成しました")
	end
	
	-- 持ち物管理用のフォルダ（非表示）
	local bag = player:FindFirstChild("Bag") or Instance.new("Folder")
	bag.Name = "Bag"
	bag.Parent = player
end

-- ★データセーブ関数
local function savePlayer(player)
	local money = player.leaderstats.Money.Value
	local maxStorage = player:GetAttribute("MaxStorage")
	local fishingSpeed = player:GetAttribute("FishingSpeed")
	local storeStage = player:GetAttribute("StoreStage")

	local data = {
		Money = money,
		MaxStorage = maxStorage,
		FishingSpeed = fishingSpeed,
		StoreStage = storeStage
	}

	local success, err = pcall(function()
		PlayerData:SetAsync(tostring(player.UserId), data)
	end)

	if success then
		print("💾 [" .. player.Name .. "] のデータを保存しました")
	else
		warn("❌ [" .. player.Name .. "] の保存に失敗: " .. err)
	end
end

-- プレイヤー参加・退室イベント
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(savePlayer)

-- Studioテスト用（すでにいる人に対応）
for _, player in pairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-- サーバー終了時（全員保存）
game:BindToClose(function()
	for _, player in pairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)
