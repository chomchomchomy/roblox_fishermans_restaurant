-- [Rojo管理] このスクリプトはVS Code（Antigravity）で編集してね！
-- ServerScriptService > ServerFishingHandler
local remote = game.ReplicatedStorage:WaitForChild("FishingEvent")
local catchSound = game:GetService("SoundService"):WaitForChild("CatchSound")

local fishTable = {
	{name = "マグロ", price = 200, chance = 5},
	{name = "タイ",   price = 50,  chance = 15},
	{name = "アジ",   price = 10,  chance = 30},
}
local junkItems = {"空き缶", "長靴", "海藻", "流木"}

remote.OnServerEvent:Connect(function(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local money = leaderstats and leaderstats:FindFirstChild("Money")

	local randomNumber = math.random(1, 100)
	local foundFish = nil
	local currentChance = 0

	for _, fish in pairs(fishTable) do
		currentChance = currentChance + fish.chance
		if randomNumber <= currentChance then
			foundFish = fish
			break
		end
	end

	-- ★ ここで釣れた音（ジャボーン！）を鳴らす
	catchSound:Play()

	if foundFish then
		if money then money.Value = money.Value + foundFish.price end
		remote:FireClient(player, foundFish.name, foundFish.price)
	else
		local junk = junkItems[math.random(1, #junkItems)]
		remote:FireClient(player, junk, 0)
	end
end)
