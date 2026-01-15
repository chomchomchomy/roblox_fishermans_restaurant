-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- FishingRod > RodScript (LocalScript)
local tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local isFishing = false

-- リソースの取得
local remote = game.ReplicatedStorage:WaitForChild("FishingEvent")
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
	if target and target.Name == "FishingSpot" then
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

		print("キャスト完了：このまま3秒待ちます")

		-- 4. 釣りの待機時間（投げた姿勢をキープ）
		task.wait(2.6) 

		-- 5. サーバーへ結果を送信
		remote:FireServer()

		-- 6. 【重要】後片付け（ここで元に戻る）
		task.wait(0.5) -- 釣り上げた余韻
		beam.Enabled = false
		rootPart.Anchored = false 
		tool.Grip = normalGrip -- 竿を元の位置に戻す
		isFishing = false

		print("リセット完了：次のキャストが可能です")
	end
end)
