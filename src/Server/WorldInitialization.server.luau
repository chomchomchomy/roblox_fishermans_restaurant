-- WorldInitialization.server.luau
-- 🌍 [World Builder] 自動建築システム
-- 🎓 教育者の解説：
-- 「プレイしなくても世界ができる」のは、このスクリプトがサーバー起動時に走るからです。
-- 昨日の完璧な地形と屋台を、自動で召喚します。

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local MapBuilder = require(Shared:WaitForChild("MapBuilder"))

warn("🏗️ [World] サーバーを検知。世界の自動建築を開始します...")

-- 世界を構築
local function initialize()
    -- 昨日のTerrain方式で海と島、そしてレストランを建てる
    MapBuilder.buildAll()
    warn("✨ [World] すべての建築が完了しました。最高の開発体験をどうぞ！")
end

-- 実行！
task.spawn(initialize)
