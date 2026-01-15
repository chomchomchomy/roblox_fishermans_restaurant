-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- FishingRod > RodScript (LocalScript)
local tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local isFishing = false
local isBiting = false -- ★NEW：魚が食いついている最中かどうかのフラグ

-- リソースの取得
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("FishingEvent")
local throwSound = game:GetService("SoundService"):WaitForChild("ThrowSound")

-- パーツ類
local handle = tool:WaitForChild("Handle")
local beam = handle:WaitForChild("Beam")
local rodTip = handle:WaitForChild("RodTip")

-- HookPosの自動作成（糸の先端を固定する場所）
local hookPos = handle:FindFirstChild("HookPos")
if not hookPos then
	hookPos = Instance.new("Attachment")
	hookPos.Name = "HookPos"
	hookPos.Parent = workspace.Terrain -- 世界側に配置
end

-- グリップ設定
local normalGrip = CFrame.new(0, -3.7, 0) -- 通常時（数字はモデルに合わせて微調整してください）
local swingGrip = normalGrip * CFrame.Angles(math.rad(60), 0, 0) -- 投げた時の角度

-- 初期化
tool.Grip = normalGrip
beam.Attachment0 = rodTip
beam.Attachment1 = hookPos
beam.Enabled = false

-- ★竿の先端を特定する関数
local function updateRodTip()
	local size = handle.Size
	if size.X > size.Y and size.X > size.Z then
		rodTip.Position = Vector3.new(size.X/2, 0, 0)
	elseif size.Y > size.X and size.Y > size.Z then
		rodTip.Position = Vector3.new(0, size.Y/2, 0)
	else
		rodTip.Position = Vector3.new(0, 0, -size.Z/2) -- 竿の向きに合わせてマイナス調整
	end
end

-- クリックした時の処理
tool.Activated:Connect(function()
	if isFishing then return end

	local target = mouse.Target
	
	-- ★プロの魔法：素材が「水（Water）」、または名前が「FishingSpot」なら釣りを許可！
	if target and (target.Material == Enum.Material.Water or target.Name:find("FishingSpot") or target:IsA("Terrain")) then
		isFishing = true

		-- 1. 準備
		updateRodTip()
		rootPart.Anchored = true -- 体を固定
		throwSound:Play()

		-- 2. 竿を前へ倒す（投げた姿勢になる）
		tool.Grip = swingGrip

		-- 3. 0.4秒後に糸（Beam）を出す
		task.wait(0.4) 
		hookPos.WorldPosition = mouse.Hit.p
		beam.Enabled = true
		
		-- ★NEW：水しぶきの音を鳴らす！
		local splash = game:GetService("SoundService"):FindFirstChild("SplashSound")
		if splash then splash:Play() end

		-- 4. 釣りの待機時間（魚が寄ってくるまで）
		task.wait(2.2)

		-- ★ヒット状態！ここで止まってクリックを待つ
		print("🎣 魚が食いついた！クリックして合わせろ！")
		isBiting = true -- 「食いつき中」フラグをオンにする
		remote:FireServer("HIT") -- 画面に「！」を出す
		
		-- プレイヤーがクリックするのを待つ（最大2.5秒）
		local reactionTime = 2.5
		local clicked = false
		local startTime = tick()
		
		-- クリックされるか、時間が切れるまでループ
		while tick() - startTime < reactionTime do
			if not isBiting then -- tool.Activated で false にされたらクリック成功
				clicked = true
				break
			end
			task.wait(0.05)
		end
		
		if clicked then
			-- ★クリック成功！巻き上げ開始
			print("🎯 タイミングバッチリ！巻き上げ開始！")
			
			-- 巻き上げ演出（ガクガク動かす！）
			local splashEffect = ReplicatedStorage:FindFirstChild("SplashEffect")
			local currentSplash = nil
			if splashEffect then
				currentSplash = splashEffect:Clone()
				currentSplash.Parent = hookPos
				currentSplash.Enabled = true
			end

			local reelStartTime = tick()
			while tick() - reelStartTime < 1.0 do
				-- 竿の角度をランダムに少し変えてガクガクさせる
				local shake = CFrame.Angles(math.rad(60 + math.random(-5, 5)), math.rad(math.random(-5, 5)), 0)
				tool.Grip = normalGrip * shake
				task.wait(0.05)
			end

			-- サーバーへ釣り上げ完了を報告
			print("📡 サーバーへ釣り上げ完了を報告")
			remote:FireServer()

			if currentSplash then currentSplash:Destroy() end
		else
			-- ★失敗：魚に逃げられた！
			print("🐟 ああー！魚に逃げられた...")
		end

		-- 6. 【重要】後片付け
		isBiting = false
		task.wait(0.5) -- 演出の余韻
		beam.Enabled = false
		rootPart.Anchored = false 
		tool.Grip = normalGrip -- 竿を元の位置に戻す
		isFishing = false

		print("リセット完了：次のキャストが可能です")
	end
end)

-- ★NEW：クリックされた時の処理（食いつき中なら巻き上げを許可する）
tool.Activated:Connect(function()
	if isBiting then
		isBiting = false -- whileループを抜けさせる合図
		print("🖱️ クリック検知：合わせに成功！")
	end
end)
