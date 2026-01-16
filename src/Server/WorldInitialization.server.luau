local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

-- 🌊 環境演出（見た目）の設定
-- このスクリプトはゲーム開始時に「演出」だけを行います。
-- マップの形自体（島や屋台）は消したり作ったりしません。
local function applyWorldAesthetics()
    -- 水の美しさ
    Terrain.WaterColor = Color3.fromRGB(0, 180, 220)
    Terrain.WaterTransparency = 0.8
    Terrain.WaterWaveSize = 0.15
    Terrain.WaterWaveSpeed = 8
    
    -- ライティング（南国の光）
    Lighting.ClockTime = 14 -- 太陽が一番映える時間
    Lighting.Brightness = 3
    Lighting.OutdoorAmbient = Color3.fromRGB(130, 140, 150)
    
    print("✨ [World] Aesthetics applied! Ready for fishing.")
end

applyWorldAesthetics()
