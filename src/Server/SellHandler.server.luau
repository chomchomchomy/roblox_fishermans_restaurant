-- SellHandler.server.luau
-- 🎓 教育者の解説：シェフに直接「魚を売る」ためのスクリプト（名前判定・吹き出し対応版）

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chat = game:GetService("Chat")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local FishData = require(Shared:WaitForChild("FishData"))

-- 売却処理のセットアップ
local function setupChefSellLogic(chefModel)
    local targetPart = chefModel:FindFirstChild("HumanoidRootPart") or chefModel:FindFirstChild("Torso") or chefModel:FindFirstChild("UpperTorso") or chefModel:FindFirstChild("Head")
    
    if not targetPart then return end
    if targetPart:FindFirstChild("SellPrompt") then return end

    -- ボタン（ProximityPrompt）の作成
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "SellPrompt"
    prompt.ActionText = "魚を売る" 
    prompt.ObjectText = "シェフ"
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 15
    prompt.RequiresLineOfSight = false
    prompt.Parent = targetPart

    -- ボタンが押された時の処理
    prompt.Triggered:Connect(function(player)
        local leaderstats = player:FindFirstChild("leaderstats")
        local money = leaderstats and leaderstats:FindFirstChild("Money")
        local backpack = player:FindFirstChild("Backpack")
        
        if not money or not backpack then return end

        local totalEarnings = 0
        local fishCount = 0
        local items = backpack:GetChildren()
        
        local character = player.Character
        if character then
            for _, v in pairs(character:GetChildren()) do
                if v:IsA("Tool") then table.insert(items, v) end
            end
        end

        for _, item in pairs(items) do
            -- 🎓 教育者のコツ：アイテム名には「(0.5kg)」などの重さが含まれているので
            -- 文字列の部分一致（string.find）を使って判定するか、
            -- あるいはツールに設定された「Value」属性を直接読み取ります。
            
            if item:IsA("Tool") and item.Name ~= "FishingRod" then
                local price = item:GetAttribute("Value") -- FishingHandlerで設定した売値
                
                if price then
                    -- 属性から直接価格を取得できた場合
                    totalEarnings += price
                    fishCount += 1
                    item:Destroy()
                else
                    -- 属性がない場合のバックアップ：FishDataから名前を探す
                    for _, data in pairs(FishData) do
                        -- 名前の一部が含まれているかチェック（例：「アジ」が「アジ (0.4kg)」に含まれるか）
                        if string.find(item.Name, data.name) then
                            totalEarnings += data.price
                            fishCount += 1
                            item:Destroy()
                            break
                        end
                    end
                end
            end
        end

        if fishCount > 0 then
            money.Value += totalEarnings
            -- 成功時の吹き出し
            local msg = "毎度！" .. fishCount .. "匹で " .. totalEarnings .. " Goldだ！"
            Chat:Chat(chefModel:FindFirstChild("Head") or targetPart, msg, Enum.ChatColor.White)
            print("💰 [売買成立] シェフ「" .. msg .. "」")
        else
            -- 【社長オーダー】魚を持っていない時
            local failMsg = "おや、売れる魚を持っていないようだよ。"
            Chat:Chat(chefModel:FindFirstChild("Head") or targetPart, failMsg, Enum.ChatColor.White)
            print("👨‍🍳 [シェフ] 「" .. failMsg .. "」")
        end
    end)
end

-- 監視ループ
task.spawn(function()
    while true do
        local chef = workspace:FindFirstChild("Chef")
        if chef then
            setupChefSellLogic(chef)
        end
        task.wait(2)
    end
end)

print("👨‍🍳 [SellHandler] 名判定・吹き出し対応システム、完全稼働！")
