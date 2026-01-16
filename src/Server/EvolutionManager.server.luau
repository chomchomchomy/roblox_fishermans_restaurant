-- EvolutionManager.server.luau
-- 店舗の進化（アップグレード）を管理するサーバースクリプト

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local MapBuilder = require(Shared:WaitForChild("MapBuilder"))

-- 全ての ProximityPrompt を監視する
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt, player)
    local board = prompt.Parent
    if board.Name ~= "UpgradeBoard" then return end

    local costStr = string.match(board:FindFirstChildOfClass("SurfaceGui").TextLabel.Text, "費用: (%d+)")
    local cost = tonumber(costStr) or 0
    local nextStage = tonumber(string.match(prompt.ActionText, "Stage (%d+)")) or 1
    local buildingType = prompt.ObjectText -- "Restaurant" or "Shop"

    local leaderstats = player:FindFirstChild("leaderstats")
    local money = leaderstats and leaderstats:FindFirstChild("Money")

    if money and money.Value >= cost then
        -- 支払い
        money.Value -= cost
        print("🎉 [" .. player.Name .. "] が " .. buildingType .. " を Stage " .. nextStage .. " に進化させました！")

        -- 演出
        MapBuilder.playUpgradeEffect(board.Position)

        -- 建築
        if buildingType == "Restaurant" then
            MapBuilder.buildRestaurant(nextStage)
        elseif buildingType == "Shop" then
            MapBuilder.buildUpgradeShop(nextStage)
        end
        
        -- 古いボードは建築関数内でフォルダごと消えるのでOK
    else
        print("❌ お金が足りません！ (必要: " .. cost .. ")")
    end
end)

print("🏢 [EvolutionManager] システム起動。プレイヤーの投資を待機中...")
