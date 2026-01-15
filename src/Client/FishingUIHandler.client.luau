-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- StarterGui > FishingUIHandler (LocalScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- メッセージを表示する関数
-- メッセージを表示する関数
local function showCatchMessage(itemName, price, emoji)
	print("🎞️ 釣り上げ演出開始: " .. itemName)
	
	local screenGui = playerGui:FindFirstChild("CatchGui") or Instance.new("ScreenGui")
	screenGui.Name = "CatchGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- ★最終兵器：送られてきた絵文字をそのまま使う！
	local fishLabel = Instance.new("TextLabel")
	fishLabel.Name = "FishEmoji"
	fishLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	fishLabel.Size = UDim2.new(0, 0, 0, 0)
	fishLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
	fishLabel.BackgroundTransparency = 1
	fishLabel.Text = emoji or "🐟"
	fishLabel.TextScaled = true
	fishLabel.ZIndex = 12
	fishLabel.Parent = screenGui
	
	-- 演出：ドカンと大きく弾む！
	fishLabel:TweenSize(UDim2.new(0, 300, 0, 300), "Out", "Back", 0.5)
	
	print("✅ 演出スタート！ 絵文字: " .. tostring(emoji))

	-- メッセージラベル（名前と値段）
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Size = UDim2.new(0.6, 0, 0.1, 0)
	label.Position = UDim2.new(0.5, 0, 0.75, 0)
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.BackgroundTransparency = 0.5
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.ZIndex = 15
	label.Parent = screenGui

	if price > 0 then
		label.Text = "✨ " .. itemName .. " をゲット！ (" .. price .. "円) ✨"
		label.TextColor3 = Color3.fromRGB(255, 255, 0)
	else
		label.Text = "👟 " .. itemName .. " が釣れた... (0円)"
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
	end

	-- 3秒後に消える
	task.wait(3)
	fishLabel:Destroy()
	label:Destroy()
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

-- サーバーからの通知を受け取る
fishingEvent.OnClientEvent:Connect(function(itemName, price, emoji)
	if itemName == "HIT" then
		showHitEffect()
	else
		print("クライアント受信: " .. itemName .. " を釣りました！")
		showCatchMessage(itemName, price, emoji)
	end
end)
