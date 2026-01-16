-- SellHandler.server.luau
-- 屋台のカウンターで魚を売却する仕組み

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))
local remote = ReplicatedStorage:WaitForChild("FishingEvent")

-- カウンターを探す関数
local function setupSellCounter()
	local foodStand = workspace:WaitForChild("FoodStand", 10)
	if not foodStand then 
		warn("FoodStandが見つかりません。MapBuilderが実行されているか確認してください。")
		return 
	end

	-- 旧名の「Counter」と新名の「SellCounter」両方に対応するように工夫します
	local counter = foodStand:FindFirstChild("SellCounter") or foodStand:FindFirstChild("Counter")
	
	if not counter then
		-- どうしても見つからない場合は、名前は違ってもそれっぽいパーツを探す（デバッグ用）
		for _, child in pairs(foodStand:GetChildren()) do
			if child:IsA("BasePart") and child.Name:lower():find("count") then
				counter = child
				print("💡 名前が少し違いますが、" .. child.Name .. " をカウンターとして認識しました。")
				break
			end
		end
	end

	if not counter then
		warn("❌ SellCounterが見つかりません。屋台の中にカウンター用パーツがあるか確認してください。")
		return
	end

	-- すでにプロンプトがあったら削除
	local existing = counter:FindFirstChildOfClass("ProximityPrompt")
	if existing then existing:Destroy() end

	-- ProximityPromptの設定
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "魚を売る"
	prompt.ObjectText = "屋台のカウンター"
	prompt.HoldDuration = 0.5
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = counter

	-- 売却処理
	prompt.Triggered:Connect(function(player)
		local leaderstats = player:FindFirstChild("leaderstats")
		local money = leaderstats and leaderstats:FindFirstChild("Money")
		local backpack = player:FindFirstChild("Backpack")
		local character = player.Character

		if not money or not backpack then return end

		-- 持ち物をスキャン（Backpackと手に持っているもの両方）
		local totalEarnings = 0
		local fishSold = 0
		local allItems = {}
		for _, item in pairs(backpack:GetChildren()) do table.insert(allItems, item) end
		if character then
			for _, item in pairs(character:GetChildren()) do table.insert(allItems, item) end
		end

		for _, item in pairs(allItems) do
			-- 竿以外でお魚の名前がついているツールを探す
			if item:IsA("Tool") and item.Name ~= "FishingRod" then
				local price = item:GetAttribute("Value")
				
				-- Attributeがない場合は名前から検索(互換性のため)
				if not price then
					for _, data in pairs(FishData) do
						if data.name == item.Name then
							price = data.price
							break
						end
					end
				end
				
				if price then
					totalEarnings = totalEarnings + price
					fishSold = fishSold + 1
					item:Destroy() -- 消去（売却）
				end
			end
		end

		if fishSold > 0 then
			money.Value = money.Value + totalEarnings
			-- サーバーログ
			print("💰 [" .. player.Name .. "] が " .. fishSold .. " 匹の魚を売却し、" .. totalEarnings .. "円獲得しました！")
			
			-- ★NEW：クライアントに売却成功を通知（エフェクト用）
			remote:FireClient(player, "SELL_RESULTS", totalEarnings, fishSold)
		else
			print("ℹ️ [" .. player.Name .. "] は売るための魚を持っていません。")
		end
	end)
end

-- サーバー起動時に少し待ってから実行（MapBuilderの完了を待つ）
task.spawn(function()
	task.wait(1)
	setupSellCounter()
end)
