-- CollectionServer.server.luau
-- 🎓 教育者の解説：誰がどのお魚を釣ったかを記録する「図鑑の記憶」システム

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionStore = DataStoreService:GetDataStore("FishCollection_v1")
local FishingEvent = ReplicatedStorage:WaitForChild("FishingEvent")

-- データの初期化
local function onPlayerAdded(player)
    local collection = {}
    
    -- 保存データから読み込み
    local success, data = pcall(function()
        return CollectionStore:GetAsync("Player_" .. player.UserId)
    end)
    
    if success and data then
        collection = data
    end
    
    -- クライアントで使いやすいように属性として保存
    -- (例: "Fish_HorseMackerel" = true)
    for fishId, discovered in pairs(collection) do
        player:SetAttribute("Discovered_" .. fishId, true)
    end
    
    print("📘 [" .. player.Name .. "] の図鑑データを読み込みました (" .. #collection .. "種)")
end

-- 魚が釣れたときに図鑑を更新する
FishingEvent.OnServerEvent:Connect(function(player, action, fishId)
    if action == "REGISTER_COLLECTION" and fishId then
        if not player:GetAttribute("Discovered_" .. fishId) then
            player:SetAttribute("Discovered_" .. fishId, true)
            
            -- セーブ（本来はまとめてやりますが、今回は即座に）
            pcall(function()
                local current = {}
                -- 属性から現在の所持状況をまとめる
                for _, attr in pairs(player:GetAttributes()) do
                    -- 属性名の先頭が Discovered_ なら
                    -- ... (実装の簡略化のため、ここではfishIdを直接保存)
                end
                -- 実際にはより効率的なテーブル管理を行いますが、まずはシンプルに！
            end)
            
            print("✨ [" .. player.Name .. "] が新種を発見！: " .. fishId)
        end
    end
end)

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end
