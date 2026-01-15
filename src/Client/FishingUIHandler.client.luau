-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- StarterGui > FishingUIHandler (LocalScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- メッセージを表示する関数
local function showCatchMessage(itemName, price)
	-- もしScreenGuiがなければ作る（君が作ったものがあればそれを使うように調整もできるよ！）
	local screenGui = playerGui:FindFirstChild("CatchGui") or Instance.new("ScreenGui")
	screenGui.Name = "CatchGui"
	screenGui.Parent = playerGui

	-- メッセージラベルの作成
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.4, 0, 0.1, 0)
	label.Position = UDim2.new(0.3, 0, 0.4, 0)
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.BackgroundTransparency = 0.5
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.BorderSizePixel = 0
	label.Parent = screenGui

	if price > 0 then
		label.Text = "✨ " .. itemName .. " をゲット！ (" .. price .. "円) ✨"
		label.TextColor3 = Color3.fromRGB(255, 255, 0) -- 金色っぽく
	else
		label.Text = "👟 " .. itemName .. " が釣れた... (0円)"
		label.TextColor3 = Color3.fromRGB(200, 200, 200) -- グレー
	end

	-- 3秒後に消える
	task.wait(3)
	label:Destroy()
end

-- サーバーからの通知を受け取る
fishingEvent.OnClientEvent:Connect(function(itemName, price)
	print("クライアント受信: " .. itemName .. " を釣りました！")
	showCatchMessage(itemName, price)
end)
