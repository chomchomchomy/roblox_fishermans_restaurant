-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- プレイヤーがゲームに参加したときに実行される魔法の合図
game.Players.PlayerAdded:Connect(function(player)

	-- 「leaderstats」という名前のフォルダを、プレイヤーの中に作成します
	-- ※この名前にすると、Robloxが自動的に画面右上に表示してくれます！
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- お金のデータを作ります（整数を入れるための箱：IntValue）
	local money = Instance.new("IntValue")
	money.Name = "Money" -- 画面に表示される名前です
	money.Value = 0      -- 最初は0円からスタート！
	money.Parent = leaderstats

end)
