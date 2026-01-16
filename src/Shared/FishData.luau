-- FishData.luau
-- お魚のマスターデータ（完全復旧・検証済ID版）

local FishData = {
	{
		name = "アジ",
		price = 15,
		chance = 35,
		rarity = "Common",
		imageId = "rbxassetid://12618848829", -- 公開されている魚のアイコン
		minWeight = 0.2,
		maxWeight = 0.8
	},
	{
		name = "アカゾナエ・キング（真鯛）",
		price = 120,
		chance = 20,
		rarity = "Uncommon",
		imageId = "rbxassetid://10688386456", -- ユーザー提供・確認済ID
		minWeight = 1.0,
		maxWeight = 6.0
	},
	{
		name = "ブルーフィン・タイタン（藍翼の巨鮪）",
		price = 1800,
		chance = 5,
		rarity = "Rare",
		imageId = "rbxassetid://18526823378", -- 公開画像：Blue Tang
		minWeight = 50.0,
		maxWeight = 250.0
	},
	{
		name = "プラチナ・シャドウ（銀影の流波）",
		price = 950,
		chance = 8,
		rarity = "Rare",
		imageId = "rbxassetid://8174284465", -- ユーザーのスタジオにいたリアル魚
		minWeight = 5.0,
		maxWeight = 20.0
	},
	{
		name = "サンセット_バースト（黄金の太陽）",
		price = 250,
		chance = 12,
		rarity = "Rare",
		imageId = "rbxassetid://259914000", -- 検証済：金魚画像
		minWeight = 2.0,
		maxWeight = 5.0
	},
	{
		name = "コバルト・ガイア（蒼海帝アンコウ）",
		price = 3500,
		chance = 2,
		rarity = "Legendary",
		imageId = "rbxassetid://5439350551", -- アンコウ画像
		minWeight = 50.0,
		maxWeight = 300.0
	},
	{
		name = "ヴォルタニック・イール（迅雷の電気鰻）",
		price = 850,
		chance = 6,
		rarity = "Rare",
		imageId = "rbxassetid://1208433382", -- 電気鰻画像
		minWeight = 3.0,
		maxWeight = 15.0
	},
	{
		name = "スチール・ファントム（鋼鉄の幻影）",
		price = 2200,
		chance = 2,
		rarity = "Legendary",
		imageId = "rbxassetid://8174284465",
		minWeight = 100.0,
		maxWeight = 600.0
	},
	{
		name = "アビス・ナイトメア（深淵の暴食者：サメ）",
		price = 5000,
		chance = 1,
		rarity = "Legendary",
		imageId = "rbxassetid://8589597517", -- 検証済：サメ画像
		minWeight = 400.0,
		maxWeight = 1500.0
	},
	{
		name = "クリムゾン・エンペラー（深紅の皇帝エイ）",
		price = 4200,
		chance = 2,
		rarity = "Legendary",
		imageId = "rbxassetid://9712173925", -- エイ画像
		minWeight = 80.0,
		maxWeight = 400.0
	},
	{
		name = "フレイム・クラウン（橙煌の道化師）",
		price = 180,
		chance = 12,
		rarity = "Uncommon",
		imageId = "rbxassetid://1159999522", -- 検証済：クマノミ画像
		minWeight = 0.1,
		maxWeight = 0.3
	},
	{
		name = "コバルト・ティアラ（紺碧の姫君）",
		price = 220,
		chance = 10,
		rarity = "Uncommon",
		imageId = "rbxassetid://14397671101", 
		minWeight = 0.2,
		maxWeight = 0.5
	},
	{
		name = "バースト・パニッシュ（憤怒のハリセンボン）",
		price = 600,
		chance = 8,
		rarity = "Uncommon",
		imageId = "rbxassetid://47791562", 
		minWeight = 0.5,
		maxWeight = 3.0
	},
	{
		name = "ルナ・メデューサ（夢幻の紫海月）",
		price = 450,
		chance = 9,
		rarity = "Uncommon",
		imageId = "rbxassetid://874987797", -- クラゲ画像
		minWeight = 0.1,
		maxWeight = 0.5
	},
	{
		name = "亡霊の残響（ゴースト・ボーン）",
		price = 10,
		chance = 5,
		rarity = "Junk",
		imageId = "rbxassetid://303496942", -- 缶
		minWeight = 0.5,
		maxWeight = 1.0
	},
	{
		name = "空き缶",
		price = 0,
		chance = 10,
		rarity = "Junk",
		imageId = "rbxassetid://303496942",
		minWeight = 0.3,
		maxWeight = 0.3
	}
}

return FishData
