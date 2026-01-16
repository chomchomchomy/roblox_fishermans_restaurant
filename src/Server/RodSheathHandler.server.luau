-- RodSheathHandler.server.luau
-- 竿を装備していない時に背中に表示する演出

local Players = game:GetService("Players")

-- 背負う位置の微調整（ここをいじると角度や位置が変わるよ！）
local BACK_OFFSET = CFrame.new(0, 0, 0.6) * CFrame.Angles(0, 0, math.rad(45)) 

local function updateSheath(player, character)
	local tool = player.Backpack:FindFirstChild("FishingRod") or character:FindFirstChild("FishingRod")
	if not tool then return end

	local handle = tool:FindFirstChild("Handle")
	if not handle then return end

	-- すでに背中にあるかチェック
	local existingSheath = character:FindFirstChild("BackRod")

	-- 竿が手に持たれている（Characterの中にある）場合
	if tool.Parent == character then
		if existingSheath then
			existingSheath:Destroy() -- 背中の竿を消す
		end
	else
		-- 竿がしまわれている（Backpackの中にある）場合
		if not existingSheath then
			-- 背中の竿を作成（本物のHandleをクローンする）
			local backRod = handle:Clone()
			backRod.Name = "BackRod"
			backRod.CanCollide = false
			backRod.CanTouch = false
			backRod.CanQuery = false
			
			-- 竿についている音やスクリプトを止める
			for _, child in pairs(backRod:GetChildren()) do
				if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("Sound") then
					child:Destroy()
				end
			end
			
			backRod.Parent = character

			-- 背中（UpperTorso）にくっつける
			local torso = character:WaitForChild("UpperTorso", 5) or character:WaitForChild("Torso", 5)
			if torso then
				local weld = Instance.new("Motor6D")
				weld.Name = "BackWeld"
				weld.Part0 = torso
				weld.Part1 = backRod
				weld.C0 = BACK_OFFSET
				weld.Parent = backRod
				print("🎒 [" .. player.Name .. "] が竿を背負いました！")
			end
		end
	end
end

-- プレイヤーがログインした時の処理
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		-- 装備が変わった（親が変わった）のを監視する
		player.Backpack.ChildAdded:Connect(function() updateSheath(player, character) end)
		player.Backpack.ChildRemoved:Connect(function() updateSheath(player, character) end)
		character.ChildAdded:Connect(function() updateSheath(player, character) end)
		character.ChildRemoved:Connect(function() updateSheath(player, character) end)
		
		-- 最初の一回
		task.wait(1)
		updateSheath(player, character)
	end)
end)

-- すでにいるプレイヤー用（Studioテスト用）
for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		updateSheath(player, player.Character)
	end
end
