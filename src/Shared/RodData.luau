-- RodData.luau
-- 釣り竿の性能データを管理するモジュール

local RodData = {
	{
		id = "Starter",
		name = "初心者の竿",
		price = 0,
		speed = 1.0, -- 標準
		rarityBoost = 1.0,
		color = Color3.fromRGB(100, 100, 100)
	},
	{
		id = "Pro",
		name = "プロの竿",
		price = 1000,
		speed = 0.7, -- 30%速い
		rarityBoost = 1.5,
		color = Color3.fromRGB(50, 150, 255)
	},
	{
		id = "Legendary",
		name = "伝説の銀竿",
		price = 5000,
		speed = 0.4, -- めっちゃ速い
		rarityBoost = 3.0,
		color = Color3.fromRGB(200, 200, 200)
	},
	{
		id = "God",
		name = "神の金竿",
		price = 25000,
		speed = 0.2, -- 爆速
		rarityBoost = 10.0,
		color = Color3.fromRGB(255, 215, 0)
	}
}

return RodData
