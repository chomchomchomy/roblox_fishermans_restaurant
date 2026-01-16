-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- StarterGui > FishingUIHandler (LocalScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- メッセージを表示する関数
-- メッセージを表示する関数
local function showCatchMessage(itemName, price, imageId, weightStr)
	print("🎞️ 演出スタート！ 魚: " .. itemName .. " (" .. weightStr .. ")")
	
	local screenGui = playerGui:FindFirstChild("CatchGui") or Instance.new("ScreenGui")
	screenGui.Name = "CatchGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- メインコンテナ
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 400, 0, 400)
	container.Position = UDim2.new(0.5, -200, 0.4, 0)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	-- お魚の画像
	local fishImage = Instance.new("ImageLabel")
	fishImage.Size = UDim2.new(0, 250, 0, 250)
	fishImage.Position = UDim2.new(0.5, -125, 0, 0)
	fishImage.Image = imageId or "rbxassetid://16024926500"
	fishImage.BackgroundTransparency = 1
	fishImage.ZIndex = 12
	fishImage.Parent = container

	-- 名前パネル
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 50)
	nameLabel.Position = UDim2.new(0, 0, 0, 260)
	nameLabel.BackgroundTransparency = 0.5
	nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Text = itemName
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.LuckiestGuy
	nameLabel.ZIndex = 15
	nameLabel.Parent = container
	
	Instance.new("UICorner", nameLabel).CornerRadius = UDim.new(0, 10)

	-- 重さラベル
	local weightLabel = Instance.new("TextLabel")
	weightLabel.Size = UDim2.new(1, 0, 0, 30)
	weightLabel.Position = UDim2.new(0, 0, 0, 320)
	weightLabel.BackgroundTransparency = 1
	weightLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	weightLabel.Text = weightStr or "0.0kg"
	weightLabel.TextSize = 24
	weightLabel.Font = Enum.Font.GothamBold
	weightLabel.ZIndex = 15
	weightLabel.Parent = container

	-- アニメーション：ドカンと大きく弾む！
	fishImage.Size = UDim2.new(0, 0, 0, 0)
	fishImage:TweenSize(UDim2.new(0, 250, 0, 250), "Out", "Back", 0.5)

	task.wait(3)
	container:Destroy()
	print("🧹 演出終了：画面をお掃除しました")
end

-- ★NEW：ヒットの合図「！」と指示を画面に出す魔法
local function showHitEffect()
	print("📢 ヒット演出：ユーザーにクリック指示を出します")
	local screenGui = playerGui:FindFirstChild("CatchGui") or Instance.new("ScreenGui")
	screenGui.Name = "CatchGui"
	screenGui.Parent = playerGui

	-- デカい「！」
	local hitLabel = Instance.new("TextLabel")
	hitLabel.Size = UDim2.new(0.5, 0, 0.4, 0)
	hitLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
	hitLabel.BackgroundTransparency = 1
	hitLabel.Text = "❗"
	hitLabel.TextScaled = true
	hitLabel.Font = Enum.Font.GothamBold
	hitLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	hitLabel.Rotation = -10
	hitLabel.ZIndex = 20
	hitLabel.Parent = screenGui

	-- ★指示テキスト：「クリック！」
	local clickLabel = Instance.new("TextLabel")
	clickLabel.Size = UDim2.new(0.4, 0, 0.2, 0)
	clickLabel.Position = UDim2.new(0.3, 0, 0.45, 0)
	clickLabel.BackgroundTransparency = 1
	clickLabel.Text = "CLICK!" -- または「クリックして！」
	clickLabel.TextScaled = true
	clickLabel.Font = Enum.Font.LuckiestGuy -- 勢いのあるフォント
	clickLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- 黄色
	clickLabel.ZIndex = 21
	clickLabel.Parent = screenGui
	
	-- 演出：点滅させて目立たせる！
	task.spawn(function()
		for i = 1, 6 do
			clickLabel.Visible = not clickLabel.Visible
			task.wait(0.1)
		end
		clickLabel.Visible = true
	end)

	-- 竿のプログラム側で設定した時間（2.5秒弱）待ってから消す
	task.wait(1.5) -- 指示はパッと消えていい
	hitLabel:Destroy()
	clickLabel:Destroy()
end

-- ローカル通知（他のクライアントスクリプトからの呼び出し）を受け取る
local localNotice = ReplicatedStorage:FindFirstChild("LocalNotice")
if not localNotice then
	localNotice = Instance.new("BindableEvent")
	localNotice.Name = "LocalNotice"
	localNotice.Parent = ReplicatedStorage
end

local function showBagFullWarning()
	print("バッグがいっぱいです！")
	-- バッグ満杯時の警告表示（もっと目立つように！）
	local screenGui = playerGui:FindFirstChild("CatchGui") or Instance.new("ScreenGui")
	screenGui.Name = "CatchGui"
	screenGui.Parent = playerGui

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 400, 0, 80)
	container.Position = UDim2.new(0.5, -200, 0.3, 0)
	container.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	container.BorderSizePixel = 0
	container.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = container

	local warnLabel = Instance.new("TextLabel")
	warnLabel.Size = UDim2.new(1, 0, 1, 0)
	warnLabel.BackgroundTransparency = 1
	warnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	warnLabel.Text = "🚨 バッグがいっぱいです！屋台で売ってきましょう！"
	warnLabel.TextScaled = true
	warnLabel.Font = Enum.Font.GothamBlack
	warnLabel.Parent = container
	
	-- アニメーション：パルス（ドクンドクンと動く）
	container:TweenSize(UDim2.new(0, 420, 0, 90), "Out", "Quad", 0.2, true, function()
		container:TweenSize(UDim2.new(0, 400, 0, 80), "Out", "Quad", 0.2, true)
	end)

	task.wait(2.5)
	container:Destroy()
end

localNotice.Event:Connect(function(msg)
	if msg == "BAG_FULL" then
		showBagFullWarning()
	end
end)

-- サーバーからの通知を受け取る
fishingEvent.OnClientEvent:Connect(function(itemName, price, imageId, weightStr)
	if itemName == "HIT" then
		showHitEffect()
	elseif itemName == "BAG_FULL" then
		showBagFullWarning()
	elseif itemName == "SELL_RESULTS" then
		local totalMoney = price -- 第2引数をpriceとして受け取っている
		local count = imageId -- 第3引数をimageId(count)として受け取っている
		
		print("💰 売却完了: " .. totalMoney .. "円")
		
		-- 売却成功のエフェクト表示
		local screenGui = playerGui:FindFirstChild("CatchGui") or Instance.new("ScreenGui")
		screenGui.Name = "CatchGui"
		screenGui.Parent = playerGui

		local sellLabel = Instance.new("TextLabel")
		sellLabel.Size = UDim2.new(0, 400, 0, 50)
		sellLabel.Position = UDim2.new(0.5, -200, 0.45, 0)
		sellLabel.BackgroundTransparency = 1
		sellLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- ゴールド色
		sellLabel.Text = "💰 +" .. totalMoney .. " Gold! (" .. count .. "匹売却)"
		sellLabel.TextScaled = true
		sellLabel.Font = Enum.Font.LuckiestGuy
		sellLabel.Parent = screenGui
		
		-- 上にふわっと消えていくアニメーション
		sellLabel:TweenPosition(UDim2.new(0.5, -200, 0.35, 0), "Out", "Quart", 1.5)
		task.spawn(function()
			for i = 0, 1, 0.05 do
				sellLabel.TextTransparency = i
				task.wait(0.075)
			end
			sellLabel:Destroy()
		end)
	else
		print("クライアント受信: " .. itemName .. " を釣りました！")
		showCatchMessage(itemName, price, imageId, weightStr)
	end
end)
