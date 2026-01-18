-- CustomerManager.server.luau
-- 🎓 教育者の解説：お店にお客さんを呼び込むための魔法（NPCスポナー）

local Players = game:GetService("Players")
local Chat = game:GetService("Chat")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 設定
local CUSTOMER_IDS = {
    1,          -- Roblox (デフォルト)
    286241773,  -- プロ釣り師風
    156,        -- シンプルな人
    161044319,  -- 観光客風
}
local SPAWN_INTERVAL = 20 -- 20秒ごとにお客さんが来る

-- お客さんを一人作成する関数
local function spawnCustomer()
    local foodStand = workspace:FindFirstChild("FoodStand")
    local basePos = Vector3.new(40, 1.5, 90) -- デフォルト（焚き火）の位置
    
    if foodStand then
        if foodStand:IsA("Model") then
            basePos = foodStand:GetPivot().Position
        elseif foodStand:IsA("BasePart") then
            basePos = foodStand.Position
        elseif foodStand:IsA("Folder") then
            -- 焚き火フォルダの場合、中身のBonfireを探す
            local b = foodStand:FindFirstChild("Bonfire") or foodStand:FindFirstChildWhichIsA("BasePart")
            if b then basePos = b.Position end
        end
    end
    
    -- 出現位置（屋台から少し離れた場所）
    local spawnPos = basePos + Vector3.new(math.random(-30, 30), 0, 40)
    -- 待ち合わせ場所（屋台の真ん前）
    local targetPos = basePos + Vector3.new(math.random(-5, 5), 0, 10)

    -- ランダムなアバターでお客さんを作成
    local userId = CUSTOMER_IDS[math.random(#CUSTOMER_IDS)]
    local customer
    local success, err = pcall(function()
        customer = Players:CreateHumanoidModelFromUserId(userId)
    end)
    
    if not success or not customer then return end
    
    customer.Name = "Customer"
    customer.Parent = workspace
    customer:PivotTo(CFrame.new(spawnPos))
    
    -- 名前を「お腹を空かせたお客さん」にする
    local hum = customer:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayName = "お腹を空かせたお客さん"
        -- 屋台まで歩かせる！
        task.wait(1)
        hum:MoveTo(targetPos)
        
        -- 到着待ち
        hum.MoveToFinished:Connect(function()
            -- 到着したら吹き出しで喋る
            Chat:Chat(customer.Head, "いい匂いだな。焼き魚をくれないか？", Enum.ChatColor.Blue)
            
            -- 【社長オーダーへの布石】売却用のボタンを追加
            local targetPart = customer:FindFirstChild("HumanoidRootPart") or customer.PrimaryPart
            if targetPart then
                local prompt = Instance.new("ProximityPrompt", targetPart)
                prompt.ActionText = "焼き魚を売る"
                prompt.ObjectText = "お客さん"
                prompt.HoldDuration = 0.5
                
                -- お客さんに売る処理（ステップ4に関連）
                prompt.Triggered:Connect(function(player)
                    local backpack = player:FindFirstChild("Backpack")
                    local cookedFish = nil
                    
                    -- 焼き魚を持っているかチェック
                    for _, item in pairs(backpack:GetChildren()) do
                        if item:IsA("Tool") and item:GetAttribute("IsCooked") then
                            cookedFish = item
                            break
                        end
                    end
                    
                    if cookedFish then
                        local price = cookedFish:GetAttribute("Value") or 50
                        local leaderstats = player:FindFirstChild("leaderstats")
                        local money = leaderstats and leaderstats:FindFirstChild("Money")
                        if money then money.Value += price end
                        
                        Chat:Chat(customer.Head, "うまい！" .. price .. " Gold払うよ！", Enum.ChatColor.Green)
                        cookedFish:Destroy()
                        prompt:Destroy()
                        
                        -- 満足して帰る
                        task.wait(2)
                        hum:MoveTo(spawnPos)
                        hum.MoveToFinished:Connect(function() customer:Destroy() end)
                    else
                        Chat:Chat(customer.Head, "焼き魚が食べたいんだ...", Enum.ChatColor.Red)
                    end
                end)
            end
        end)
    end
end

-- 定期的に呼び出す（ゲーム開始して少し待ってから）
task.delay(10, function()
    while true do
        spawnCustomer()
        task.wait(SPAWN_INTERVAL)
    end
end)

print("🚶‍♂️ [CustomerManager] お客さん来店システム、準備完了！")
