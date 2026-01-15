-- [Rojo管理] お魚のマスターデータ（大帳簿）
local FishData = {
	-- 確率(chance)の合計が100になるように調整するのがプロのコツ！
	{name = "アジ",     price = 10,   chance = 40, emoji = "🐟", rarity = "Common"},
	{name = "タイ",     price = 50,   chance = 20, emoji = "🐡", rarity = "Uncommon"},
	{name = "マグロ",   price = 200,  chance = 5,  emoji = "🐟", rarity = "Rare"},
	{name = "金魚",     price = 500,  chance = 2,  emoji = "🐠", rarity = "Legendary"},
	{name = "タコ",     price = 80,   chance = 10, emoji = "🐙", rarity = "Uncommon"},
	{name = "カニ",     price = 120,  chance = 8,  emoji = "🦀", rarity = "Rare"},
	{name = "空き缶",   price = 0,    chance = 10, emoji = "🥫", rarity = "Junk"},
	{name = "長靴",     price = 0,    chance = 5,  emoji = "👞", rarity = "Junk"}
}

-- ログ機能：今何種類の魚がいるか教えてあげる
print("📖 お魚帳簿を読み込みました！ 現在の種類数: " .. #FishData)

return FishData
