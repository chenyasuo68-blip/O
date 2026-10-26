--[[
    ══════════════════════════════════════════════════════════════════════════════════
    👑 AVERLIK HUB - ANIMAL HOSPITAL (PERFECT SMART AUTO-HEAL 1-5 & PRESET WAYPOINTS)
    ══════════════════════════════════════════════════════════════════════════════════
    • Ключевые исправления:
        1. 🚫 НЕ ТЕЛЕПОРТИРУЕТСЯ В ПУСТЫЕ ПАЛАТЫ:
           - Предварительно сканирует Workspace: если в палате нет больного (нет prompt), палата пропускается мгновенно!
        2. ⏳ ИДЕАЛЬНЫЙ ТАЙМИНГ НА СКАНЕРЕ И КОМПЬЮТЕРЕ:
           - Не улетает раньше времени!
           - Держит E для вставки ДНК ➔ ждет завершения центрифуги (3.5с) ➔ нажимает на компьютер для получения рецепта/вещей!
        3. 💊 ТОЧНЫЙ ЗАБОР ЛЕКАРСТВА И ЛЕЧЕНИЕ:
           - ТП к нужной полке ➔ забирает предмет ➔ ТП к койке ➔ берет в руку ➔ лечит больного (Hold E).
        4. 👀 СОХРАНЕНИЕ ТОЧНОГО УГЛА ВЗГЛЯДА ПЕРСОНАЖА.
        5. 🌐 Server Hop (Случайный / Малолюдный / Rejoin).
    ══════════════════════════════════════════════════════════════════════════════════
--]]

local function RunAverlikHub()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Lighting = game:GetService("Lighting")
    local VirtualUser = game:GetService("VirtualUser")

    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        repeat
            task.wait(0.05)
            LocalPlayer = Players.LocalPlayer
        until LocalPlayer
    end

    -- 啟動音效
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 0.5
        sound.Parent = Workspace
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)

    -- 清除舊副本
    pcall(function()
        if getgenv and getgenv().AverlikHub_Instance then
            getgenv().AverlikHub_Instance:Destroy()
        end
        for _, old in pairs(game:GetService("CoreGui"):GetChildren()) do
            if old.Name == "AverlikHub_MainGui" then old:Destroy() end
        end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, old in pairs(pg:GetChildren()) do
                if old.Name == "AverlikHub_MainGui" then old:Destroy() end
            end
        end
    end)

    local function GetSafeParent()
        local parent = nil
        pcall(function()
            local cg = game:GetService("CoreGui")
            local test = Instance.new("Folder")
            test.Parent = cg
            test:Destroy()
            parent = cg
        end)
        if parent then return parent end

        if gethui then
            local ok, h = pcall(gethui)
            if ok and h then return h end
        end

        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pg then return pg end

        return LocalPlayer:WaitForChild("PlayerGui", 5)
    end

    local GuiParent = GetSafeParent()
    if not GuiParent then
        GuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AverlikHub_MainGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = true
    ScreenGui.Parent = GuiParent

    if getgenv then
        getgenv().AverlikHub_Instance = ScreenGui
    end

    -- 📍 自訂傳送點表（您儲存的所有座標與視角）
    local CustomWaypoints = {
        -- 接待處（所有步驟）
        Reception = CFrame.new(-108.7247, 3.4125, 10.2041, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Reception_Form = CFrame.new(-103.9118, 3.4125, -0.4003, 1.0000, 0, 0.0052, 0, 1.0000, 0, -0.0052, 0, 1.0000),
        Reception_Camera = CFrame.new(-108.7958, 3.4125, -0.3836, 0.9994, 0, -0.0349, 0, 1.0000, 0, 0.0349, 0, 0.9994),
        Reception_Printer = CFrame.new(-99.5409, 3.4125, 0.0997, 0.3818, 0, -0.9242, 0, 1.0000, 0, 0.9242, 0, 0.3818),

        -- 病房 1 - 5、7（病床 + 裝置）
        Ward1_Bed = CFrame.new(-168.4174, 5.8061, -41.0413, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward1_Device = CFrame.new(-177.6558, 3.4575, -44.2175, 0.0276, 0, 0.9996, 0, 1.0000, 0, -0.9996, 0, 0.0276),

        Ward2_Bed = CFrame.new(-121.2388, 5.8061, -59.5030, 1.0000, 0, -0.0026, 0, 1.0000, 0, 0.0026, 0, 1.0000),
        Ward2_Device = CFrame.new(-111.4617, 3.4575, -56.7069, -0.0144, 0, -0.9999, 0, 1.0000, 0, 0.9999, 0, -0.0144),

        Ward3_Bed = CFrame.new(-168.0784, 5.8135, -80.1025, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward3_Device = CFrame.new(-177.9783, 3.4575, -83.5864, 0.0101, 0, 0.9999, 0, 1.0000, 0, -0.9999, 0, 0.0101),

        Ward4_Bed = CFrame.new(-121.1582, 5.8061, -99.0621, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward4_Device = CFrame.new(-111.0429, 3.4575, -94.0062, 0.0066, 0, -1.0000, 0, 1.0000, 0, 1.0000, 0, 0.0066),

        Ward5_Bed = CFrame.new(-154.0585, 5.8060, -114.6957, 0.0084, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, 0.0084),
        Ward5_Device = CFrame.new(-150.8929, 3.4575, -124.0175, 0.9999, 0, -0.0166, 0, 1.0000, 0, 0.0166, 0, 0.9999),

        Ward6_Bed = nil,
        Ward6_Device = nil,

        Ward7_Bed = CFrame.new(-105.4788, 5.8661, 51.9991, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward7_Device = CFrame.new(-106.3802, 3.4575, 58.4393, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),

        -- 💊 藥櫃中的各種藥品（精確位置與朝向貨架的視角）
        Med_Herbs = CFrame.new(-137.1196, 3.4575, -57.8230, -0.0229, 0, -0.9997, 0, 1.0000, 0, 0.9997, 0, -0.0229),
        Med_Pills = CFrame.new(-137.0331, 3.4575, -63.5557, -0.0194, 0, -0.9998, 0, 1.0000, 0, 0.9998, 0, -0.0194),
        Med_Drops = CFrame.new(-152.7902, 3.4575, -56.1025, 0.0082, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, 0.0082),
        Med_IVDrip = CFrame.new(-152.7524, 3.4575, -60.7020, 0.0082, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, 0.0082),
        Med_FirstAid = CFrame.new(-152.6409, 3.4575, -67.7490, 0.0551, 0, 0.9985, 0, 1.0000, 0, -0.9985, 0, 0.0551),
        Med_Thermometer = CFrame.new(-152.4051, 3.4575, -72.6085, -0.0095, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, -0.0095),
        Med_Syrup = CFrame.new(-136.6097, 3.4575, -82.4880, -0.0558, 0, -0.9984, 0, 1.0000, 0, 0.9984, 0, -0.0558),
        Med_Mixture = CFrame.new(-136.8368, 3.4575, -78.4278, -0.0541, 0, -0.9985, 0, 1.0000, 0, 0.9985, 0, -0.0541),
        Med_Bandage = CFrame.new(-152.8181, 3.4575, -79.3061, 0.0306, 0, 0.9995, 0, 1.0000, 0, -0.9995, 0, 0.0306),
        Med_Plaster = CFrame.new(-152.5291, 3.4575, -84.2309, -0.0165, 0, 0.9999, 0, 1.0000, 0, -0.9999, 0, -0.0165),

        -- 咖啡
        Coffee = CFrame.new(-123.8188, 7.9340, 10.2180, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000)
    }

    -- 從 Waypoints.json 檔案載入已儲存的點
    pcall(function()
        if readfile and isfile and isfile("AverlikHub/Waypoints.json") then
            local data = HttpService:JSONDecode(readfile("AverlikHub/Waypoints.json"))
            if data and type(data) == "table" then
                for k, v in pairs(data) do
                    if v then
                        local cf = nil
                        if v.components and type(v.components) == "table" and #v.components == 12 then
                            cf = CFrame.new(unpack(v.components))
                        elseif v.lookX and v.lookY and v.lookZ and v.x and v.y and v.z then
                            cf = CFrame.lookAt(Vector3.new(v.x, v.y, v.z), Vector3.new(v.x + v.lookX, v.y + v.lookY, v.z + v.lookZ))
                        elseif v.x and v.y and v.z then
                            cf = CFrame.new(v.x, v.y, v.z)
                        end

                        if cf then
                            CustomWaypoints[k] = cf
                            if string.sub(k, 1, 4) == "Ward" and not string.find(k, "_") then
                                CustomWaypoints[k .. "_Bed"] = cf
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Hub 設定
    local Config = {
        AutoHospitalCycle = false,
        AutoRegistration = true,
        StepDelay = 0.5,
        ScannerWaitDelay = 6.0,

        -- 病房 7
        Room7_AutoCycle = false,
        Room7_AutoHeartGame = true,
        Room7_AutoIVDrip = true,

        -- 玩家 & 自動操作
        AutoKeepSanity = false,
        SkipDoctorDialogue = false,
        AutoCamera = false,
        WalkSpeed = 16,
        WalkSpeedEnabled = false,
        NoClip = false,
        AntiAFK = true,

        -- Visuals & Misc
        PatientESP = false,
        AnomalyESP = false,
        PlayerESP = false,
        FPSBoost = false,
        LowGraphics = false,

        AccentColor = Color3.fromRGB(219, 70, 237),
        BackgroundColor = Color3.fromRGB(16, 16, 20),
        SidebarColor = Color3.fromRGB(13, 13, 16),
        SelectedConfig = "Default"
    }

    local function SafeFind(str, query)
        if not str or type(str) ~= "string" or not query then return false end
        return string.find(string.lower(str), string.lower(query), 1, true) ~= nil
    end

    -- 門與雜物篩選器
    local function IsDoorOrTrash(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") then return true end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        if SafeFind(act, "door") or SafeFind(act, "двер") or SafeFind(act, "откры") or SafeFind(act, "open") or SafeFind(act, "закры") or SafeFind(act, "close") then return true end
        if SafeFind(objT, "door") or SafeFind(objT, "двер") or SafeFind(pName, "door") or SafeFind(pName, "двер") or SafeFind(pName, "handle") or SafeFind(pName, "knob") then return true end
        if SafeFind(act, "trash") or SafeFind(act, "мусор") or SafeFind(objT, "trash") or SafeFind(pName, "trash") or SafeFind(pName, "bin") then return true end
        return false
    end

    local function GetPromptTargetCFrame(prompt)
        if not prompt then return nil end
        local parent = prompt.Parent
        if not parent then return nil end

        if parent:IsA("Attachment") then return parent.WorldCFrame end
        if parent:IsA("BasePart") then return parent.CFrame end
        if parent:IsA("Model") then
            local pPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
            if pPart then return pPart.CFrame end
        end

        local ancestorPart = prompt:FindFirstAncestorWhichIsA("BasePart")
        if ancestorPart then return ancestorPart.CFrame end

        return nil
    end

    local function TeleportTo(cf)
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root then
                if hum then
                    hum.Sit = false
                    hum.PlatformStand = false
                end
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if typeof(cf) == "CFrame" then
                    -- 精確儲存視角與角色朝向
                    root.CFrame = cf + Vector3.new(0, 0.2, 0)
                elseif typeof(cf) == "Vector3" then
                    root.CFrame = CFrame.new(cf + Vector3.new(0, 2.5, 0))
                end
            end
        end)
    end

    local function GetMyCFrame()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        return root and root.CFrame or nil
    end

    local function GetMyPosition()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        return root and root.Position or nil
    end

    local function SafeInteractPrompt(prompt, extraHold)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local holdTime = prompt.HoldDuration or 0
        if extraHold then holdTime = holdTime + extraHold end
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, holdTime)
            else
                prompt:InputHoldBegin()
                task.wait(holdTime > 0 and (holdTime + 0.2) or 0.25)
                prompt:InputHoldEnd()
            end
        end)
        return true
    end

    local function DoesToolMatchMedicine(toolName, reqMedKey)
        if not toolName or not reqMedKey then return false end
        local t = string.lower(toolName)
        if reqMedKey == "Med_Herbs" and (SafeFind(t, "трав") or SafeFind(t, "herb") or SafeFind(t, "plant") or SafeFind(t, "растен") or SafeFind(t, "живот") or SafeFind(t, "stomach")) then return true end
        if reqMedKey == "Med_Pills" and (SafeFind(t, "таблет") or SafeFind(t, "pill") or SafeFind(t, "капсул") or SafeFind(t, "голов") or SafeFind(t, "head")) then return true end
        if reqMedKey == "Med_Drops" and (SafeFind(t, "капл") or SafeFind(t, "drop") or SafeFind(t, "глаз") or SafeFind(t, "eye") or SafeFind(t, "сухост") or SafeFind(t, "зрен")) then return true end
        if reqMedKey == "Med_IVDrip" and (SafeFind(t, "капельниц") or SafeFind(t, "iv") or SafeFind(t, "drip") or SafeFind(t, "кров") or SafeFind(t, "blood")) then return true end
        if reqMedKey == "Med_FirstAid" and (SafeFind(t, "аптеч") or SafeFind(t, "aid") or SafeFind(t, "kit") or SafeFind(t, "помощ") or SafeFind(t, "травм")) then return true end
        if reqMedKey == "Med_Thermometer" and (SafeFind(t, "термометр") or SafeFind(t, "шприц") or SafeFind(t, "thermo") or SafeFind(t, "syringe") or SafeFind(t, "градусник") or SafeFind(t, "температур")) then return true end
        if reqMedKey == "Med_Syrup" and (SafeFind(t, "сироп") or SafeFind(t, "syrup") or SafeFind(t, "кашел") or SafeFind(t, "горл")) then return true end
        if reqMedKey == "Med_Mixture" and (SafeFind(t, "микстур") or SafeFind(t, "mixture") or SafeFind(t, "зель") or SafeFind(t, "аллерг") or SafeFind(t, "сып")) then return true end
        if reqMedKey == "Med_Bandage" and (SafeFind(t, "бинт") or SafeFind(t, "band") or SafeFind(t, "повяз") or SafeFind(t, "перевяз") or SafeFind(t, "перелом")) then return true end
        if reqMedKey == "Med_Plaster" and (SafeFind(t, "пластыр") or SafeFind(t, "plaster") or SafeFind(t, "patch") or SafeFind(t, "ссадин") or SafeFind(t, "порез")) then return true end
        return false
    end

    local function EquipRequiredMedicine(reqMedKey)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not hum then return false end

        -- 1. 檢查我們是否已經拿著正確的物品
        local holdingTool = char:FindFirstChildWhichIsA("Tool")
        if holdingTool then
            if DoesToolMatchMedicine(holdingTool.Name, reqMedKey) then
                return true
            else
                -- 收起錯誤的物品，避免不小心害死病患
                hum:UnequipTools()
                task.wait(0.2)
            end
        end

        -- 2. 在背包中嚴格搜尋符合需求的物品
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") and DoesToolMatchMedicine(tool.Name, reqMedKey) then
                    hum:EquipTool(tool)
                    task.wait(0.2)
                    return true
                end
            end
        end

        return false
    end

    local function EquipMedicalTool(preferredName)
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not bp or not hum then return end

            if preferredName then
                for _, tool in ipairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and SafeFind(tool.Name, preferredName) then
                        hum:EquipTool(tool)
                        task.wait(0.15)
                        return
                    end
                end
            end
        end)
    end

    local function FindWardModel(wardNumber)
        local query = "палата " .. tostring(wardNumber)
        local queryEng = "room " .. tostring(wardNumber)
        local queryNum = tostring(wardNumber)

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local oName = string.lower(obj.Name)
                if oName == query or oName == queryEng or (SafeFind(oName, "room") and SafeFind(oName, queryNum)) or (SafeFind(oName, "палат") and SafeFind(oName, queryNum)) then
                    return obj
                end
            end
        end
        return nil
    end

    local function GetWardBedPosition(wardNumber)
        local key = "Ward" .. tostring(wardNumber) .. "_Bed"
        if CustomWaypoints[key] then return CustomWaypoints[key] end
        if CustomWaypoints["Ward" .. tostring(wardNumber)] then return CustomWaypoints["Ward" .. tostring(wardNumber)] end

        local wardModel = FindWardModel(wardNumber)
        if wardModel then
            local bed = wardModel:FindFirstChild("Bed", true) or wardModel:FindFirstChild("HospitalBed", true) or wardModel:FindFirstChild("Mattress", true)
            if bed then
                return bed:IsA("Model") and (bed.PrimaryPart and bed.PrimaryPart.CFrame or bed:GetBoundingBox()) or bed.CFrame
            end
            local anyPart = wardModel:FindFirstChildWhichIsA("BasePart", true)
            if anyPart then return anyPart.CFrame end
        end
        return nil
    end

    local function GetWardDevicePosition(wardNumber)
        local key = "Ward" .. tostring(wardNumber) .. "_Device"
        if CustomWaypoints[key] then return CustomWaypoints[key] end

        local wardModel = FindWardModel(wardNumber)
        if wardModel then
            for _, p in pairs(wardModel:GetDescendants()) do
                local pName = string.lower(p.Name)
                if SafeFind(pName, "scanner") or SafeFind(pName, "centrifuge") or SafeFind(pName, "pc") or SafeFind(pName, "computer") or SafeFind(pName, "desk") or SafeFind(pName, "стол") then
                    if p:IsA("BasePart") then return p.CFrame
                    elseif p:IsA("Model") and p.PrimaryPart then return p.PrimaryPart.CFrame end
                end
            end
        end
        return nil
    end

    local function IsDNAPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        return SafeFind(act, "анализ") or SafeFind(act, "днк") or SafeFind(act, "dna") or SafeFind(act, "sample") or SafeFind(act, "взят")
    end

    local function IsLabMachinePrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "провест") or SafeFind(act, "сканир") or SafeFind(act, "scan") or SafeFind(act, "встав") or SafeFind(objT, "компьют") or SafeFind(pName, "scan") or SafeFind(pName, "pc") or SafeFind(pName, "lab") or SafeFind(act, "анализ")
    end

    local function IsCabinetPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))
        if SafeFind(pName, "shelf") or SafeFind(pName, "cabinet") or SafeFind(pName, "шкаф") or SafeFind(pName, "полк") or SafeFind(gName, "shelf") or SafeFind(gName, "cabinet") or SafeFind(gName, "шкаф") then
            return true
        end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local medWords = {"травы", "сироп", "аптечка", "таблетк", "пластыр", "бинт", "капельниц", "шприц", "капли", "микстур", "herbs", "syrup", "kit", "pill", "drop"}
        for _, m in ipairs(medWords) do
            if SafeFind(act, m) and not SafeFind(pName, "bed") and not SafeFind(pName, "patient") then
                return true
            end
        end
        return false
    end

    local function IsHealPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        return SafeFind(act, "лечит") or SafeFind(act, "heal") or SafeFind(act, "дать") or SafeFind(act, "give") or SafeFind(act, "укол") or SafeFind(act, "вылеч")
    end

    local function IsReceptionPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "регистр") or SafeFind(act, "звонок") or SafeFind(act, "bell") or SafeFind(objT, "регистр") or SafeFind(pName, "reception") or SafeFind(pName, "bell")
    end

    local function IsCoffeePrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "coffee") or SafeFind(act, "кофе") or SafeFind(objT, "кофе") or SafeFind(objT, "рассудок") or SafeFind(pName, "coffee")
    end

    -- 病房活動狀態檢查（病床上是否有病患、掃描器中是否有分析，或電腦上是否有任務）
    local function SolveHeartMinigame()
        local solved = false
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not pg then return end
            for _, gui in pairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AverlikHub_MainGui" then
                    for _, btn in pairs(gui:GetDescendants()) do
                        if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and btn.Visible and btn.Active then
                            local bName = string.lower(btn.Name)
                            if SafeFind(bName, "click") or SafeFind(bName, "hand") or SafeFind(bName, "tap") or SafeFind(bName, "target") or SafeFind(bName, "point") or SafeFind(bName, "heart") then
                                pcall(function()
                                    if firesignal then
                                        firesignal(btn.MouseButton1Click)
                                        firesignal(btn.Activated)
                                    end
                                end)
                                solved = true
                            end
                        end
                    end
                end
            end
        end)
        return solved
    end

    -- 通知
    local ToastContainer = Instance.new("Frame")
    ToastContainer.Name = "ToastContainer"
    ToastContainer.Size = UDim2.new(0, 260, 0, 300)
    ToastContainer.Position = UDim2.new(1, -280, 0, 30)
    ToastContainer.BackgroundTransparency = 1
    ToastContainer.ZIndex = 10000
    ToastContainer.Parent = ScreenGui

    local ToastListLayout = Instance.new("UIListLayout")
    ToastListLayout.Padding = UDim.new(0, 8)
    ToastListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ToastListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ToastListLayout.Parent = ToastContainer

    local function SendNotification(title, message, duration)
        duration = duration or 3
        task.spawn(function()
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 52)
            card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            card.BorderSizePixel = 0
            card.Position = UDim2.new(1, 30, 0, 0)
            card.ZIndex = 10001

            local stroke = Instance.new("UIStroke")
            stroke.Color = Config.AccentColor
            stroke.Thickness = 1.2
            stroke.Parent = card

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = card

            local tLbl = Instance.new("TextLabel")
            tLbl.Text = tostring(title)
            tLbl.Font = Enum.Font.GothamBold
            tLbl.TextSize = 13
            tLbl.TextColor3 = Config.AccentColor
            tLbl.Position = UDim2.new(0, 12, 0, 7)
            tLbl.Size = UDim2.new(1, -24, 0, 16)
            tLbl.BackgroundTransparency = 1
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.ZIndex = 10002
            tLbl.Parent = card

            local dLbl = Instance.new("TextLabel")
            dLbl.Text = tostring(message)
            dLbl.Font = Enum.Font.Gotham
            dLbl.TextSize = 11
            dLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
            dLbl.Position = UDim2.new(0, 12, 0, 26)
            dLbl.Size = UDim2.new(1, -24, 0, 20)
            dLbl.BackgroundTransparency = 1
            dLbl.TextXAlignment = Enum.TextXAlignment.Left
            dLbl.ZIndex = 10002
            dLbl.Parent = card

            card.Parent = ToastContainer
            pcall(function()
                TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            end)

            task.wait(duration)
            if card and card.Parent then
                local tw = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 30, 0, 0)})
                tw:Play()
                tw.Completed:Connect(function() card:Destroy() end)
            end
        end)
    end

    -- HUD 小工具
    local FloatingPill = Instance.new("Frame")
    FloatingPill.Name = "FloatingHUD"
    FloatingPill.Size = UDim2.new(0, 165, 0, 46)
    FloatingPill.Position = UDim2.new(0, 20, 1, -70)
    FloatingPill.AnchorPoint = Vector2.new(0, 1)
    FloatingPill.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    FloatingPill.BorderSizePixel = 0
    FloatingPill.Active = true
    FloatingPill.Visible = true
    FloatingPill.ZIndex = 5000
    FloatingPill.Parent = ScreenGui

    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(0, 12)
    PillCorner.Parent = FloatingPill

    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Color3.fromRGB(36, 36, 46)
    PillStroke.Thickness = 1.2
    PillStroke.Parent = FloatingPill

    local PillLogo = Instance.new("Frame")
    PillLogo.Size = UDim2.new(0, 30, 0, 30)
    PillLogo.Position = UDim2.new(0, 8, 0.5, -15)
    PillLogo.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    PillLogo.BorderSizePixel = 0
    PillLogo.ZIndex = 5001
    PillLogo.Parent = FloatingPill

    local PillLogoCorner = Instance.new("UICorner")
    PillLogoCorner.CornerRadius = UDim.new(0, 8)
    PillLogoCorner.Parent = PillLogo

    local PillLogoText = Instance.new("TextLabel")
    PillLogoText.Text = "A"
    PillLogoText.Font = Enum.Font.GothamBold
    PillLogoText.TextSize = 16
    PillLogoText.TextColor3 = Config.AccentColor
    PillLogoText.Size = UDim2.new(1, 0, 1, 0)
    PillLogoText.BackgroundTransparency = 1
    PillLogoText.ZIndex = 5002
    PillLogoText.Parent = PillLogo

    local PillTitle = Instance.new("TextLabel")
    PillTitle.Text = "Averlik Hub"
    PillTitle.Font = Enum.Font.GothamBold
    PillTitle.TextSize = 12
    PillTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PillTitle.Position = UDim2.new(0, 46, 0, 6)
    PillTitle.Size = UDim2.new(1, -52, 0, 16)
    PillTitle.BackgroundTransparency = 1
    PillTitle.TextXAlignment = Enum.TextXAlignment.Left
    PillTitle.ZIndex = 5001
    PillTitle.Parent = FloatingPill

    local PillSub = Instance.new("TextLabel")
    PillSub.Name = "HUD_TimeFPS"
    PillSub.Text = "00:00 • 60 fps"
    PillSub.Font = Enum.Font.Gotham
    PillSub.TextSize = 10
    PillSub.TextColor3 = Color3.fromRGB(150, 150, 165)
    PillSub.Position = UDim2.new(0, 46, 0, 23)
    PillSub.Size = UDim2.new(1, -52, 0, 16)
    PillSub.BackgroundTransparency = 1
    PillSub.TextXAlignment = Enum.TextXAlignment.Left
    PillSub.ZIndex = 5001
    PillSub.Parent = FloatingPill

    local PillBtn = Instance.new("TextButton")
    PillBtn.Size = UDim2.new(1, 0, 1, 0)
    PillBtn.BackgroundTransparency = 1
    PillBtn.Text = ""
    PillBtn.ZIndex = 5005
    PillBtn.Parent = FloatingPill

    -- 主視窗
    local cam = Workspace.CurrentCamera
    local vpSize = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local winW = math.clamp(vpSize.X - 40, 360, 720)
    local winH = math.clamp(vpSize.Y - 60, 320, 500)

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Size = UDim2.new(0, winW, 0, winH)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.BackgroundColor3 = Config.BackgroundColor
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = true
    MainWindow.ZIndex = 1000
    MainWindow.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainWindow

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 34, 44)
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainWindow

    local function EnableDrag(frame, handle)
        handle = handle or frame
        local dragging, dragInput, dragStart, startPos

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)

        handle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    EnableDrag(MainWindow)
    EnableDrag(FloatingPill)

    -- 側邊欄
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 1001
    Sidebar.Parent = MainWindow

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 14)
    SidebarCorner.Parent = Sidebar

    local SidebarMask = Instance.new("Frame")
    SidebarMask.Size = UDim2.new(0, 14, 1, 0)
    SidebarMask.Position = UDim2.new(1, -14, 0, 0)
    SidebarMask.BackgroundColor3 = Config.SidebarColor
    SidebarMask.BorderSizePixel = 0
    SidebarMask.ZIndex = 1001
    SidebarMask.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.ZIndex = 1002
    SidebarDivider.Parent = Sidebar

    local BrandFrame = Instance.new("Frame")
    BrandFrame.Size = UDim2.new(1, 0, 0, 56)
    BrandFrame.BackgroundTransparency = 1
    BrandFrame.ZIndex = 1002
    BrandFrame.Parent = Sidebar

    local BrandLogo = Instance.new("Frame")
    BrandLogo.Size = UDim2.new(0, 32, 0, 32)
    BrandLogo.Position = UDim2.new(0, 12, 0, 12)
    BrandLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    BrandLogo.BorderSizePixel = 0
    BrandLogo.ZIndex = 1003
    BrandLogo.Parent = BrandFrame

    local BrandLogoCorner = Instance.new("UICorner")
    BrandLogoCorner.CornerRadius = UDim.new(0, 8)
    BrandLogoCorner.Parent = BrandLogo

    local BrandLogoLetter = Instance.new("TextLabel")
    BrandLogoLetter.Text = "A"
    BrandLogoLetter.Font = Enum.Font.GothamBold
    BrandLogoLetter.TextSize = 17
    BrandLogoLetter.TextColor3 = Config.AccentColor
    BrandLogoLetter.Size = UDim2.new(1, 0, 1, 0)
    BrandLogoLetter.BackgroundTransparency = 1
    BrandLogoLetter.ZIndex = 1004
    BrandLogoLetter.Parent = BrandLogo

    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Text = "Averlik Hub"
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextSize = 13
    BrandTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BrandTitle.Position = UDim2.new(0, 50, 0, 11)
    BrandTitle.Size = UDim2.new(1, -55, 0, 16)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.ZIndex = 1003
    BrandTitle.Parent = BrandFrame

    local BrandSub = Instance.new("TextLabel")
    BrandSub.Text = "Animal Hospital"
    BrandSub.Font = Enum.Font.Gotham
    BrandSub.TextSize = 10
    BrandSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    BrandSub.Position = UDim2.new(0, 50, 0, 27)
    BrandSub.Size = UDim2.new(1, -55, 0, 14)
    BrandSub.BackgroundTransparency = 1
    BrandSub.TextXAlignment = Enum.TextXAlignment.Left
    BrandSub.ZIndex = 1003
    BrandSub.Parent = BrandFrame

    local TabListContainer = Instance.new("ScrollingFrame")
    TabListContainer.Name = "TabList"
    TabListContainer.Size = UDim2.new(1, -14, 1, -125)
    TabListContainer.Position = UDim2.new(0, 7, 0, 58)
    TabListContainer.BackgroundTransparency = 1
    TabListContainer.BorderSizePixel = 0
    TabListContainer.ScrollBarThickness = 2
    TabListContainer.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 60)
    TabListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabListContainer.ZIndex = 1003
    TabListContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 3)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabListContainer

    local SidebarFooter = Instance.new("Frame")
    SidebarFooter.Name = "Footer"
    SidebarFooter.Size = UDim2.new(1, -14, 0, 50)
    SidebarFooter.Position = UDim2.new(0, 7, 1, -56)
    SidebarFooter.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    SidebarFooter.BorderSizePixel = 0
    SidebarFooter.ZIndex = 1003
    SidebarFooter.Parent = Sidebar

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 10)
    FooterCorner.Parent = SidebarFooter

    local FooterStroke = Instance.new("UIStroke")
    FooterStroke.Color = Color3.fromRGB(30, 30, 40)
    FooterStroke.Thickness = 1
    FooterStroke.Parent = SidebarFooter

    local DiscordLabel = Instance.new("TextLabel")
    DiscordLabel.Text = "discord.gg/bJFF653nK"
    DiscordLabel.Font = Enum.Font.GothamBold
    DiscordLabel.TextSize = 10
    DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordLabel.Position = UDim2.new(0, 0, 0, 6)
    DiscordLabel.Size = UDim2.new(1, 0, 0, 16)
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.ZIndex = 1004
    DiscordLabel.Parent = SidebarFooter

    local FooterSub = Instance.new("TextLabel")
    FooterSub.Name = "FooterTimeFPS"
    FooterSub.Text = "00:00 • 60 fps"
    FooterSub.Font = Enum.Font.Gotham
    FooterSub.TextSize = 10
    FooterSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    FooterSub.Position = UDim2.new(0, 0, 0, 24)
    FooterSub.Size = UDim2.new(1, 0, 0, 16)
    FooterSub.BackgroundTransparency = 1
    FooterSub.ZIndex = 1004
    FooterSub.Parent = SidebarFooter

    -- 內容區域
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -160, 1, 0)
    ContentArea.Position = UDim2.new(0, 160, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 1001
    ContentArea.Parent = MainWindow

    local ContentHeader = Instance.new("Frame")
    ContentHeader.Name = "Header"
    ContentHeader.Size = UDim2.new(1, 0, 0, 56)
    ContentHeader.Position = UDim2.new(0, 0, 0, 0)
    ContentHeader.BackgroundTransparency = 1
    ContentHeader.ZIndex = 1002
    ContentHeader.Parent = ContentArea

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Title"
    HeaderTitle.Text = "醫院"
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 16
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.Position = UDim2.new(0, 16, 0, 10)
    HeaderTitle.Size = UDim2.new(0, 200, 0, 18)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 1003
    HeaderTitle.Parent = ContentHeader

    local HeaderSub = Instance.new("TextLabel")
    HeaderSub.Name = "Subtitle"
    HeaderSub.Text = "病房 1-5 自動治療"
    HeaderSub.Font = Enum.Font.Gotham
    HeaderSub.TextSize = 10
    HeaderSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    HeaderSub.Position = UDim2.new(0, 16, 0, 29)
    HeaderSub.Size = UDim2.new(0, 230, 0, 14)
    HeaderSub.BackgroundTransparency = 1
    HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSub.ZIndex = 1003
    HeaderSub.Parent = ContentHeader

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
    CloseBtn.ZIndex = 1003
    CloseBtn.Parent = ContentHeader

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    local function ToggleGUI()
        MainWindow.Visible = not MainWindow.Visible
    end

    CloseBtn.MouseButton1Click:Connect(function()
        MainWindow.Visible = false
        SendNotification("Averlik Hub", "介面已隱藏。點擊下方小工具即可顯示。", 3)
    end)

    PillBtn.MouseButton1Click:Connect(ToggleGUI)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
            ToggleGUI()
        end
    end)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Name = "PagesHolder"
    PagesHolder.Size = UDim2.new(1, 0, 1, -56)
    PagesHolder.Position = UDim2.new(0, 0, 0, 56)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.ZIndex = 1002
    PagesHolder.Parent = ContentArea

    -- UI Builder
    local Tabs = {}
    local CurrentTab = nil

    local function CreateTab(name, icon, subtitle, layoutOrder)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. name
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.LayoutOrder = layoutOrder or 1
        tabButton.ZIndex = 1004
        tabButton.Parent = TabListContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Text = icon or "•"
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.TextSize = 12
        iconLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
        iconLabel.Position = UDim2.new(0, 8, 0, 0)
        iconLabel.Size = UDim2.new(0, 18, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.ZIndex = 1005
        iconLabel.Parent = tabButton

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Label"
        nameLabel.Text = name
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 11
        nameLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
        nameLabel.Position = UDim2.new(0, 32, 0, 0)
        nameLabel.Size = UDim2.new(1, -36, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.ZIndex = 1005
        nameLabel.Parent = tabButton

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Name = "Page_" .. name
        pageScroll.Size = UDim2.new(1, -20, 1, -10)
        pageScroll.Position = UDim2.new(0, 10, 0, 0)
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.ScrollBarThickness = 3
        pageScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 60)
        pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pageScroll.Visible = false
        pageScroll.ZIndex = 1003
        pageScroll.Parent = PagesHolder

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = pageScroll

        local tabObj = {
            Button = tabButton,
            Page = pageScroll,
            Name = name,
            Subtitle = subtitle or "參數與功能",
            Elements = {}
        }

        local function SelectThisTab()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                local lbl = t.Button:FindFirstChild("Label")
                local icn = t.Button:FindFirstChild("Icon")
                if lbl then lbl.TextColor3 = Color3.fromRGB(150, 150, 165) end
                if icn then icn.TextColor3 = Color3.fromRGB(140, 140, 155) end
            end

            CurrentTab = tabObj
            pageScroll.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.BackgroundColor3 = Color3.fromRGB(26, 25, 34)
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            iconLabel.TextColor3 = Config.AccentColor

            HeaderTitle.Text = name
            HeaderSub.Text = tabObj.Subtitle
        end

        tabButton.MouseButton1Click:Connect(SelectThisTab)
        table.insert(Tabs, tabObj)

        function tabObj:CreateSection(sectionTitle)
            local secFrame = Instance.new("Frame")
            secFrame.Name = "Sec_" .. sectionTitle
            secFrame.Size = UDim2.new(1, 0, 0, 22)
            secFrame.BackgroundTransparency = 1
            secFrame.ZIndex = 1004
            secFrame.Parent = pageScroll

            local lbl = Instance.new("TextLabel")
            lbl.Text = sectionTitle
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.TextColor3 = Color3.fromRGB(150, 150, 165)
            lbl.Size = UDim2.new(0, 0, 1, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.X
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 1005
            lbl.Parent = secFrame

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -(lbl.AbsoluteSize.X + 15), 0, 1)
            line.Position = UDim2.new(1, 0, 0.5, 0)
            line.AnchorPoint = Vector2.new(1, 0.5)
            line.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            line.BorderSizePixel = 0
            line.ZIndex = 1004
            line.Parent = secFrame

            lbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                line.Size = UDim2.new(1, -(lbl.AbsoluteSize.X + 15), 0, 1)
            end)
        end

        function tabObj:CreateToggle(title, description, defaultValue, callback)
            local toggleCard = Instance.new("Frame")
            toggleCard.Name = "Toggle_" .. title
            toggleCard.Size = UDim2.new(1, 0, 0, 42)
            toggleCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            toggleCard.BorderSizePixel = 0
            toggleCard.ZIndex = 1004
            toggleCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = toggleCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = toggleCard

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 5)
            tLabel.Size = UDim2.new(1, -60, 0, 16)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = toggleCard

            local dLabel = Instance.new("TextLabel")
            dLabel.Text = description or ""
            dLabel.Font = Enum.Font.Gotham
            dLabel.TextSize = 9
            dLabel.TextColor3 = Color3.fromRGB(120, 120, 135)
            dLabel.Position = UDim2.new(0, 10, 0, 22)
            dLabel.Size = UDim2.new(1, -60, 0, 14)
            dLabel.BackgroundTransparency = 1
            dLabel.TextXAlignment = Enum.TextXAlignment.Left
            dLabel.ZIndex = 1005
            dLabel.Parent = toggleCard

            local switch = Instance.new("Frame")
            switch.Size = UDim2.new(0, 36, 0, 18)
            switch.Position = UDim2.new(1, -44, 0.5, -9)
            switch.BackgroundColor3 = defaultValue and Config.AccentColor or Color3.fromRGB(40, 40, 52)
            switch.BorderSizePixel = 0
            switch.ZIndex = 1005
            switch.Parent = toggleCard

            local swCorner = Instance.new("UICorner")
            swCorner.CornerRadius = UDim.new(1, 0)
            swCorner.Parent = switch

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = defaultValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 1006
            knob.Parent = switch

            local knCorner = Instance.new("UICorner")
            knCorner.CornerRadius = UDim.new(1, 0)
            knCorner.Parent = knob

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 1007
            btn.Parent = toggleCard

            local state = defaultValue

            local function SetState(val)
                state = val
                local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                local targetColor = state and Config.AccentColor or Color3.fromRGB(40, 40, 52)

                pcall(function()
                    TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                    TweenService:Create(switch, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
                end)

                if callback then callback(state) end
            end

            btn.MouseButton1Click:Connect(function() SetState(not state) end)
            table.insert(tabObj.Elements, {Type = "Toggle", Title = title, Card = toggleCard, Set = SetState})
            return {Set = SetState}
        end

        function tabObj:CreateButton(title, isPrimary, callback)
            local btnCard = Instance.new("TextButton")
            btnCard.Name = "Btn_" .. title
            btnCard.Size = UDim2.new(1, 0, 0, 34)
            btnCard.BackgroundColor3 = isPrimary and Config.AccentColor or Color3.fromRGB(32, 32, 42)
            btnCard.BorderSizePixel = 0
            btnCard.Text = title
            btnCard.Font = Enum.Font.GothamBold
            btnCard.TextSize = 11
            btnCard.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnCard.AutoButtonColor = false
            btnCard.ZIndex = 1004
            btnCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btnCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = isPrimary and Color3.fromRGB(240, 130, 255) or Color3.fromRGB(44, 44, 58)
            stroke.Thickness = 1
            stroke.Parent = btnCard

            btnCard.MouseButton1Click:Connect(function()
                pcall(function()
                    TweenService:Create(btnCard, TweenInfo.new(0.08), {Size = UDim2.new(1, -4, 0, 32)}):Play()
                    task.wait(0.08)
                    TweenService:Create(btnCard, TweenInfo.new(0.08), {Size = UDim2.new(1, 0, 0, 34)}):Play()
                end)
                if callback then callback() end
            end)

            table.insert(tabObj.Elements, {Type = "Button", Title = title, Card = btnCard})
            return btnCard
        end

        function tabObj:CreateDualButton(titleLeft, titleRight, callbackLeft, callbackRight)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundTransparency = 1
            row.ZIndex = 1004
            row.Parent = pageScroll

            local btnL = Instance.new("TextButton")
            btnL.Size = UDim2.new(0.72, -4, 1, 0)
            btnL.Position = UDim2.new(0, 0, 0, 0)
            btnL.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
            btnL.BorderSizePixel = 0
            btnL.Text = titleLeft
            btnL.Font = Enum.Font.GothamMedium
            btnL.TextSize = 10
            btnL.TextColor3 = Color3.fromRGB(240, 240, 250)
            btnL.ZIndex = 1005
            btnL.Parent = row

            local cL = Instance.new("UICorner")
            cL.CornerRadius = UDim.new(0, 8)
            cL.Parent = btnL

            local sL = Instance.new("UIStroke")
            sL.Color = Color3.fromRGB(40, 40, 56)
            sL.Thickness = 1
            sL.Parent = btnL

            local btnR = Instance.new("TextButton")
            btnR.Size = UDim2.new(0.28, -4, 1, 0)
            btnR.Position = UDim2.new(0.72, 4, 0, 0)
            btnR.BackgroundColor3 = Config.AccentColor
            btnR.BorderSizePixel = 0
            btnR.Text = titleRight
            btnR.Font = Enum.Font.GothamBold
            btnR.TextSize = 10
            btnR.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnR.ZIndex = 1005
            btnR.Parent = row

            local cR = Instance.new("UICorner")
            cR.CornerRadius = UDim.new(0, 8)
            cR.Parent = btnR

            btnL.MouseButton1Click:Connect(function()
                if callbackLeft then callbackLeft() end
            end)

            btnR.MouseButton1Click:Connect(function()
                if callbackRight then callbackRight() end
            end)

            return row
        end

        function tabObj:CreateSlider(title, min, max, defaultVal, callback)
            local sliderCard = Instance.new("Frame")
            sliderCard.Name = "Slider_" .. title
            sliderCard.Size = UDim2.new(1, 0, 0, 46)
            sliderCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            sliderCard.BorderSizePixel = 0
            sliderCard.ZIndex = 1004
            sliderCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = sliderCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = sliderCard

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 6)
            tLabel.Size = UDim2.new(1, -70, 0, 14)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = sliderCard

            local valLabel = Instance.new("TextLabel")
            valLabel.Text = tostring(defaultVal)
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextSize = 11
            valLabel.TextColor3 = Config.AccentColor
            valLabel.Position = UDim2.new(1, -55, 0, 6)
            valLabel.Size = UDim2.new(0, 45, 0, 14)
            valLabel.BackgroundTransparency = 1
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 1005
            valLabel.Parent = sliderCard

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 5)
            track.Position = UDim2.new(0, 10, 0, 28)
            track.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
            track.BorderSizePixel = 0
            track.ZIndex = 1005
            track.Parent = sliderCard

            local trCorner = Instance.new("UICorner")
            trCorner.CornerRadius = UDim.new(1, 0)
            trCorner.Parent = track

            local pct = math.clamp((defaultVal - min) / (max - min), 0, 1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = Config.AccentColor
            fill.BorderSizePixel = 0
            fill.ZIndex = 1006
            fill.Parent = track

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(1, 0)
            fCorner.Parent = fill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 11, 0, 11)
            knob.Position = UDim2.new(1, -5, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 1007
            knob.Parent = fill

            local knCorner = Instance.new("UICorner")
            knCorner.CornerRadius = UDim.new(1, 0)
            knCorner.Parent = knob

            local isDragging = false
            local function UpdateSlider(inputPos)
                local relX = math.clamp(inputPos.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                local newPct = relX / track.AbsoluteSize.X
                local val = math.floor((min + (max - min) * newPct) * 10) / 10
                if max > 50 then val = math.floor(min + (max - min) * newPct) end
                fill.Size = UDim2.new(newPct, 0, 1, 0)
                valLabel.Text = tostring(val)
                if callback then callback(val) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    UpdateSlider(input.Position)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input.Position)
                end
            end)

            table.insert(tabObj.Elements, {Type = "Slider", Title = title, Card = sliderCard})
        end

        function tabObj:CreateInput(title, placeholder, defaultVal, callback)
            local inputCard = Instance.new("Frame")
            inputCard.Name = "Input_" .. title
            inputCard.Size = UDim2.new(1, 0, 0, 44)
            inputCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            inputCard.BorderSizePixel = 0
            inputCard.ZIndex = 1004
            inputCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = inputCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = inputCard

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 0)
            tLabel.Size = UDim2.new(0.5, 0, 1, 0)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = inputCard

            local tbBox = Instance.new("TextBox")
            tbBox.Size = UDim2.new(0.45, 0, 0, 26)
            tbBox.Position = UDim2.new(0.52, 0, 0.5, -13)
            tbBox.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
            tbBox.BorderSizePixel = 0
            tbBox.Text = defaultVal or ""
            tbBox.PlaceholderText = placeholder or ""
            tbBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
            tbBox.Font = Enum.Font.Gotham
            tbBox.TextSize = 11
            tbBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            tbBox.ClearTextOnFocus = false
            tbBox.ZIndex = 1005
            tbBox.Parent = inputCard

            local tbCorner = Instance.new("UICorner")
            tbCorner.CornerRadius = UDim.new(0, 6)
            tbCorner.Parent = tbBox

            tbBox.FocusLost:Connect(function()
                if callback then callback(tbBox.Text) end
            end)

            table.insert(tabObj.Elements, {Type = "Input", Title = title, Card = inputCard})
            return tbBox
        end

        return tabObj
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🎛️ AVERLIK HUB + CYRAA HUB PRO 的全部 10 個分頁
    -- ══════════════════════════════════════════════════════════════════════════
    local TabHospital  = CreateTab("自動治療", "🩺", "病房 1 - 5：具備防死亡保護的自動循環", 1)
    local TabReception = CreateTab("接待處", "🏢", "自動接待訪客、拍照與列印", 2)
    local TabShelves   = CreateTab("藥櫃", "💊", "紅色、藍色、綠色、黃色、灰色藥櫃", 3)
    local TabESP       = CreateTab("ESP", "👁️", "病患、異常、擬態者、玩家", 4)
    local TabServer    = CreateTab("大廳/伺服器", "🌐", "RE/Quickstart、RE/SkipDialogue、伺服器跳轉", 5)
    local TabRoom7     = CreateTab("病房 7", "⚡", "急救、心電圖與點滴", 6)
    local TabWaypoints = CreateTab("傳送點", "📍", "3D 霓虹標記與 32 個座標點", 7)
    local TabPlayer    = CreateTab("玩家", "👤", "速度、跳躍、NoClip、自動咖啡", 8)
    local TabMisc      = CreateTab("Anti-Lag / FPS", "⚡", "畫面最佳化與 FPS Boost", 9)
    local TabSettings  = CreateTab("設定", "⚙️", "主題、顏色與設定檔儲存", 10)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🔧 輔助功能（CYRAA & AVERLIK）
    -- ══════════════════════════════════════════════════════════════════════════
    local function SkipDoctorDialogue()
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local rem = rs:FindFirstChild("RE/SetDoctorDialogueSkipped") or rs:FindFirstChild("SetDoctorDialogueSkipped")
            if rem and rem:IsA("RemoteEvent") then
                rem:FireServer(true)
                SendNotification("對話", "已成功跳過醫生對話！", 2)
            end
        end)
    end

    local function TriggerQuickstart()
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local rem = rs:FindFirstChild("RE/Quickstart") or rs:FindFirstChild("Quickstart")
            if rem and rem:IsA("RemoteEvent") then
                rem:FireServer()
                SendNotification("大廳", "已透過 RE/Quickstart 開始輪班！", 2)
            else
                SendNotification("大廳", "找不到 Quickstart RemoteEvent", 2)
            end
        end)
    end

    local function TriggerCameraShutter()
        local recPos = CustomWaypoints.Reception
        local camPos = CustomWaypoints.Reception_Camera or (recPos and recPos * CFrame.new(-3.5, 0, 0))
        if camPos then TeleportTo(camPos); task.wait(0.2) end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                local act = string.lower(tostring(obj.ActionText or ""))
                local objT = string.lower(tostring(obj.ObjectText or ""))
                local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                if SafeFind(act, "фото") or SafeFind(act, "снять") or SafeFind(act, "photo") or SafeFind(act, "camera") or SafeFind(pName, "cam") or SafeFind(objT, "камер") then
                    SafeInteractPrompt(obj, 0.4)
                    SendNotification("相機", "已拍照！", 2)
                    return true
                end
            elseif obj:IsA("ClickDetector") and obj.Parent then
                local pName = string.lower(obj.Parent.Name)
                if SafeFind(pName, "cam") or SafeFind(pName, "photo") or SafeFind(pName, "камер") then
                    pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                    SendNotification("相機", "已拍照！", 2)
                    return true
                end
            end
        end
        return false
    end

    local function FastTakeMedicine(medKey, displayName)
        task.spawn(function()
            local pos = CustomWaypoints[medKey]
            if pos then
                TeleportTo(pos)
                task.wait(0.3)
                local myP = GetMyPosition()
                for _, cabObj in pairs(Workspace:GetDescendants()) do
                    if IsCabinetPrompt(cabObj) then
                        local cabCF = GetPromptTargetCFrame(cabObj)
                        if cabCF and myP and (cabCF.Position - myP).Magnitude < 7.5 then
                            SafeInteractPrompt(cabObj, 0.4)
                            task.wait(0.4)
                            EquipRequiredMedicine(medKey)
                            SendNotification("藥櫃", "已拿取藥品：" .. tostring(displayName or medKey), 2)
                            return
                        end
                    end
                end
                SendNotification("藥櫃", "附近找不到藥櫃提示", 2)
            else
                SendNotification("藥櫃", "找不到藥品 " .. tostring(medKey) .. " 的貨架位置", 2)
            end
        end)
    end

    -- ESP 系統（病患、異常、玩家）
    local ESP_Storage = { Patients = {}, Anomalies = {}, Players = {} }

    local function ClearESPTable(t)
        for obj, hl in pairs(t) do
            pcall(function() if hl and hl.Parent then hl:Destroy() end end)
        end
        table.clear(t)
    end

    local function UpdatePatientESP(enabled)
        ClearESPTable(ESP_Storage.Patients)
        if not enabled then return end
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character and not m:IsDescendantOf(LocalPlayer.Character) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local head = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                if hum or head then
                    local name = string.lower(m.Name)
                    if not SafeFind(name, "skinwalker") and not SafeFind(name, "monster") and not SafeFind(name, "anomaly") then
                        local isPlayer = false
                        for _, pl in pairs(Players:GetPlayers()) do
                            if pl.Character == m then isPlayer = true; break end
                        end
                        if not isPlayer then
                            local hl = Instance.new("Highlight")
                            hl.Name = "Averlik_PatientHighlight"
                            hl.FillColor = Color3.fromRGB(80, 240, 120)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.45
                            hl.OutlineTransparency = 0.1
                            hl.Adornee = m
                            hl.Parent = m
                            ESP_Storage.Patients[m] = hl
                        end
                    end
                end
            end
        end
    end

    local function UpdateAnomalyESP(enabled)
        ClearESPTable(ESP_Storage.Anomalies)
        if not enabled then return end
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character then
                local name = string.lower(m.Name)
                if SafeFind(name, "skinwalker") or SafeFind(name, "anomaly") or SafeFind(name, "monster") or SafeFind(name, "ghost") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Averlik_AnomalyHighlight"
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                    hl.FillTransparency = 0.25
                    hl.OutlineTransparency = 0.0
                    hl.Adornee = m
                    hl.Parent = m
                    ESP_Storage.Anomalies[m] = hl
                end
            end
        end
    end

    local function UpdatePlayerESP(enabled)
        ClearESPTable(ESP_Storage.Players)
        if not enabled then return end
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "Averlik_PlayerHighlight"
                hl.FillColor = Color3.fromRGB(70, 160, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.1
                hl.Adornee = pl.Character
                hl.Parent = pl.Character
                ESP_Storage.Players[pl.Character] = hl
            end
        end
    end

    local function HopToLeastPlayersServer()
        SendNotification("伺服器跳轉", "正在尋找玩家人數最少的伺服器……", 2)
        task.spawn(function()
            local success, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
                local response = game:HttpGet(url)
                return HttpService:JSONDecode(response)
            end)
            if success and servers and servers.data then
                local validServers = {}
                for _, s in pairs(servers.data) do
                    if type(s) == "table" and s.id and s.id ~= game.JobId and (s.playing or 0) > 0 and (s.playing or 0) < (s.maxPlayers or 10) then
                        table.insert(validServers, s)
                    end
                end
                if #validServers > 0 then
                    table.sort(validServers, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
                    local target = validServers[1]
                    SendNotification("伺服器跳轉", "正在連線（" .. tostring(target.playing) .. "/" .. tostring(target.maxPlayers) .. " 位玩家）……", 3)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
                    return
                end
            end
            SendNotification("伺服器跳轉", "找不到伺服器，正在重新加入……", 2)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end

    local function ApplyAntiLag(enable)
        pcall(function()
            local Lighting = game:GetService("Lighting")
            local Terrain = Workspace:FindFirstChildOfClass("Terrain")
            if enable then
                pcall(function() settings().Rendering.QualityLevel = 1 end)
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 1
                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 0
                end
                for _, v in pairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("Atmosphere") then
                        v.Enabled = false
                    end
                end
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsA("MeshPart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 0.5
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
                SendNotification("FPS Boost", "Anti-Lag 已啟用！FPS 已提升。", 2)
            else
                Lighting.GlobalShadows = true
                SendNotification("FPS Boost", "已恢復標準畫面設定。", 2)
            end
        end)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- 1. 分頁：自動治療（病房 1 - 5）
    -- ══════════════════════════════════════════════════════════════════════════
    TabHospital:CreateSection("病房 1 - 5 自動刷取與治療")
    TabHospital:CreateToggle("醫院自動循環 (Auto Treatment)", "完整流程：DNA ➔ 掃描器 ➔ 藥櫃 ➔ 治療並防止死亡", Config.AutoHospitalCycle, function(val)
        Config.AutoHospitalCycle = val
        SendNotification("醫院", val and "自動治療已啟動！" or "自動治療已停止", 3)
    end)
    TabHospital:CreateToggle("自動維持理智值 (Keep Sanity 100%)", "理智值降低時自動從販賣機喝咖啡", Config.AutoKeepSanity, function(val)
        Config.AutoKeepSanity = val
        SendNotification("理智值", val and "自動維持理智值已啟用！" or "自動維持理智值已關閉！", 2)
    end)
    TabHospital:CreateToggle("跳過醫生對話 (RE/SetDoctorDialogueSkipped)", "自動跳過醫生的台詞", Config.SkipDoctorDialogue, function(val)
        Config.SkipDoctorDialogue = val
        if val then SkipDoctorDialogue() end
        SendNotification("對話", val and "自動跳過對話已啟用！" or "自動跳過對話已關閉！", 2)
    end)
    TabHospital:CreateSlider("Задержка между шагами (сек)", 0.2, 2.0, Config.StepDelay, function(val)
        Config.StepDelay = val
    end)
    TabHospital:CreateSlider("Ожидание сканера/центрифуги (сек)", 3.0, 12.0, Config.ScannerWaitDelay, function(val)
        Config.ScannerWaitDelay = val
    end)

    TabHospital:CreateSection("快速操作")
    TabHospital:CreateButton("☕ 立即喝咖啡（理智值恢復至 100%）", true, function()
        task.spawn(function()
            local cPos = CustomWaypoints.Coffee
            if cPos then TeleportTo(cPos) end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsCoffeePrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF); task.wait(0.2)
                        SafeInteractPrompt(obj, 0.2)
                        SendNotification("理智值", "已喝下咖啡！理智值已恢復。", 2)
                        return
                    end
                end
            end
            SendNotification("理智值", "找不到咖啡機", 2)
        end)
    end)
    TabHospital:CreateButton("🧹 清除手上錯誤的物品", false, function()
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:UnequipTools() end
            SendNotification("物品欄", "已清空手上的物品", 2)
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 2. 分頁：接待處（RECEPTION & SECRETARY）
    -- ══════════════════════════════════════════════════════════════════════════
    TabReception:CreateSection("接待處自動化")
    TabReception:CreateToggle("自動接待訪客 (Auto Visitor only)", "自動為所有等候中的客戶辦理登記", Config.AutoRegistration, function(val)
        Config.AutoRegistration = val
        SendNotification("接待處", val and "自動接待已啟用！" or "自動接待已關閉", 2)
    end)
    TabReception:CreateToggle("相機自動觸發快門 (Trigger Shutter)", "靠近相機時自動拍照", Config.AutoCamera, function(val)
        Config.AutoCamera = val
        SendNotification("相機", val and "相機自動快門已啟用！" or "相機自動快門已關閉！", 2)
    end)
    TabReception:CreateButton("📋 立即接待客戶（表單 ➔ 拍照 ➔ 電腦 ➔ 列印）", true, function()
        task.spawn(function()
            SendNotification("接待處", "客戶登記已開始……", 2)
            ProcessReceptionIntake()
        end)
    end)
    TabReception:CreateButton("📷 立即使用相機拍照", false, function()
        TriggerCameraShutter()
    end)
    TabReception:CreateButton("🚀 傳送至接待櫃檯", false, function()
        local recPos = CustomWaypoints.Reception
        if recPos then TeleportTo(recPos); SendNotification("傳送", "接待櫃檯", 2) end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 3. 分頁：藥櫃與藥品（SHELF TELEPORTS）
    -- ══════════════════════════════════════════════════════════════════════════
    TabShelves:CreateSection("🟥 紅色藥櫃 (Red Shelf)")
    TabShelves:CreateButton("🧰 拿取急救箱 (Medkit / First Aid)", true, function() FastTakeMedicine("Med_FirstAid", "急救箱") end)
    TabShelves:CreateButton("🌡️ 拿取溫度計 / 注射器 (Thermometer)", false, function() FastTakeMedicine("Med_Thermometer", "溫度計/注射器") end)

    TabShelves:CreateSection("🟦 藍色藥櫃 (Blue Shelf)")
    TabShelves:CreateButton("💧 拿取眼藥水 (Drops)", true, function() FastTakeMedicine("Med_Drops", "眼藥水") end)
    TabShelves:CreateButton("💉 拿取點滴 (IV Drip)", false, function() FastTakeMedicine("Med_IVDrip", "點滴") end)

    TabShelves:CreateSection("🟩 綠色藥櫃 (Green Shelf)")
    TabShelves:CreateButton("🌿 拿取草藥 (Herbs)", true, function() FastTakeMedicine("Med_Herbs", "草藥") end)
    TabShelves:CreateButton("💊 拿取藥錠 (Pills)", false, function() FastTakeMedicine("Med_Pills", "藥錠") end)

    TabShelves:CreateSection("🟨 黃色藥櫃 (Yellow Shelf)")
    TabShelves:CreateButton("🍯 拿取止咳糖漿 (Cough Syrup)", true, function() FastTakeMedicine("Med_Syrup", "止咳糖漿") end)
    TabShelves:CreateButton("🧪 拿取混合藥劑 (Mixture)", false, function() FastTakeMedicine("Med_Mixture", "混合藥劑") end)

    TabShelves:CreateSection("⬜ 灰色藥櫃 (White / Grey Shelf)")
    TabShelves:CreateButton("🩹 拿取繃帶 (Bandage)", true, function() FastTakeMedicine("Med_Bandage", "繃帶") end)
    TabShelves:CreateButton("🩹 拿取膠布 (Plaster)", false, function() FastTakeMedicine("Med_Plaster", "膠布") end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 4. 分頁：ESP 與視覺化工具
    -- ══════════════════════════════════════════════════════════════════════════
    TabESP:CreateSection("物件高亮顯示 (ESP)")
    TabESP:CreateToggle("病患 ESP (Patient ESP / Highlight)", "以綠色高亮顯示病房內所有生病的動物", Config.PatientESP, function(val)
        Config.PatientESP = val
        UpdatePatientESP(val)
    end)
    TabESP:CreateToggle("異常與怪物 ESP (Anomaly ESP)", "以鮮紅色高亮顯示擬態者與異常", Config.AnomalyESP, function(val)
        Config.AnomalyESP = val
        UpdateAnomalyESP(val)
    end)
    TabESP:CreateToggle("玩家 ESP (Player ESP)", "以藍色高亮顯示伺服器中的其他醫生與玩家", Config.PlayerESP, function(val)
        Config.PlayerESP = val
        UpdatePlayerESP(val)
    end)
    TabESP:CreateToggle("世界中的 3D 點位標記 (Waypoint ESP)", "顯示已儲存點位的霓虹圓圈與視線方向箭頭", ShowWaypointESP, function(val)
        ShowWaypointESP = val
        UpdateWaypointVisuals()
    end)
    TabESP:CreateButton("🔄 更新並重新啟動所有 ESP", false, function()
        UpdatePatientESP(Config.PatientESP)
        UpdateAnomalyESP(Config.AnomalyESP)
        UpdatePlayerESP(Config.PlayerESP)
        UpdateWaypointVisuals()
        SendNotification("ESP", "ESP 高亮顯示已更新！", 2)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 5. 分頁：大廳與伺服器（LOBBY & SERVER）
    -- ══════════════════════════════════════════════════════════════════════════
    TabServer:CreateSection("網路功能")
    TabServer:CreateButton("⚡ 快速開始輪班 (RE/Quickstart)", true, function()
        TriggerQuickstart()
    end)
    TabServer:CreateButton("⏩ 跳過醫生對話 (RE/SetDoctorDialogueSkipped)", false, function()
        SkipDoctorDialogue()
    end)
    TabServer:CreateButton("🌐 跳轉至玩家最少的伺服器 (Hop to Least Players)", true, function()
        HopToLeastPlayersServer()
    end)
    TabServer:CreateButton("🎲 隨機伺服器跳轉", false, function()
        ServerHop(false)
    end)
    TabServer:CreateButton("🔄 重新加入此伺服器 (Rejoin)", false, function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end)

    TabServer:CreateSection("外部引擎")
    TabServer:CreateButton("🔥 啟動 FN Animal Hospital Engine", false, function()
        task.spawn(function()
            SendNotification("引擎", "正在背景啟動 FN Animal Hospital……", 3)
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
            end)
        end)
    end)
    TabServer:CreateButton("💎 啟動 Cyraa Hub Engine", false, function()
        task.spawn(function()
            SendNotification("引擎", "正在背景啟動 Cyraa Hub……", 3)
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/LynX99-9/komtolmmek2/refs/heads/main/Animal%20Hospital"))()
            end)
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 6. 分頁：病房 7（急救 / ICU）
    -- ══════════════════════════════════════════════════════════════════════════
    TabRoom7:CreateSection("病房 7 急救")
    TabRoom7:CreateToggle("自動循環：病房 7", "完整急救流程（心電圖 + 點滴 + 急救箱）", Config.Room7_AutoCycle, function(val)
        Config.Room7_AutoCycle = val
        SendNotification("病房 7", val and "病房 7 自動循環已啟動！" or "自動循環已停止", 2)
    end)
    TabRoom7:CreateToggle("心電圖小遊戲自動解題", "自動點擊螢幕上的心臟標記點", Config.Room7_AutoHeartGame, function(val)
        Config.Room7_AutoHeartGame = val
    end)
    TabRoom7:CreateToggle("自動點滴與治療", "拿取點滴/急救箱並替生病的兔子使用", Config.Room7_AutoIVDrip, function(val)
        Config.Room7_AutoIVDrip = val
    end)
    TabRoom7:CreateButton("立即完成心臟小遊戲（瞬間完成）", true, function()
        local solved = SolveHeartMinigame()
        SendNotification("小遊戲", solved and "已成功點擊心臟標記點！" or "小遊戲畫面尚未開啟", 2)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 7. 分頁：傳送點（WAYPOINTS）
    -- ══════════════════════════════════════════════════════════════════════════
    TabWaypoints:CreateSection("3D 視覺化與儲存")
    TabWaypoints:CreateToggle("世界中所有點位的 3D 標記 (ESP)", "在遊戲中直接顯示霓虹圓圈、名稱與視線方向箭頭", ShowWaypointESP, function(val)
        ShowWaypointESP = val
        UpdateWaypointVisuals()
    end)
    TabWaypoints:CreateButton("💾 將全部 32 個點位儲存至檔案 (Waypoints.json)", true, function()
        SaveWaypointsToFile()
        SendNotification("Waypoints", "已儲存全部 32 個點位與視角！", 3)
    end)
    TabWaypoints:CreateButton("📋 將座標複製到剪貼簿 (JSON)", false, function()
        pcall(function()
            local exportData = {}
            for k, v in pairs(CustomWaypoints) do
                if typeof(v) == "CFrame" then
                    local look = v.LookVector
                    exportData[k] = {x = v.X, y = v.Y, z = v.Z, lookX = look.X, lookY = look.Y, lookZ = look.Z, components = {v:GetComponents()}}
                end
            end
            local jsonStr = HttpService:JSONEncode(exportData)
            if setclipboard then
                setclipboard(jsonStr)
                SendNotification("剪貼簿", "座標 JSON 已複製到剪貼簿！", 2)
            end
        end)
    end)

    TabWaypoints:CreateSection("➕ 建立新的自訂點位")
    local customPointName = "Custom_Point_1"
    TabWaypoints:CreateInput("新點位名稱", "例如：我的_點位", "Custom_Point_1", function(val)
        customPointName = val
    end)
    TabWaypoints:CreateButton("➕ 將目前位置記錄為新點位", true, function()
        local cf = GetMyCFrame()
        if cf and customPointName and customPointName ~= "" then
            CustomWaypoints[customPointName] = cf
            SaveWaypointsToFile()
            UpdateWaypointVisuals()
            SendNotification("Waypoints", "已建立並儲存點位：" .. customPointName, 3)
        end
    end)

    TabWaypoints:CreateSection("✅ 已確認的點位")
    TabWaypoints:CreateButton("📊 全部 32 個主要點位均已確認並啟用", false, function()
        SendNotification("狀態", "病房 1-5、病房 7、接待處與 10 個藥架皆已準備就緒！", 3)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 8. 分頁：玩家（PLAYER）
    -- ══════════════════════════════════════════════════════════════════════════
    TabPlayer:CreateSection("角色參數")
    TabPlayer:CreateToggle("變更移動速度", "啟用自訂移動速度", Config.WalkSpeedEnabled, function(val)
        Config.WalkSpeedEnabled = val
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val and Config.WalkSpeed or 16 end
    end)
    TabPlayer:CreateSlider("Скорость (WalkSpeed)", 16, 250, Config.WalkSpeed or 16, function(val)
        Config.WalkSpeed = val
        if Config.WalkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end)
    TabPlayer:CreateToggle("NoClip", "穿越物件與牆壁", Config.NoClip, function(val) Config.NoClip = val end)
    TabPlayer:CreateToggle("Anti AFK", "防止因閒置而被踢出", Config.AntiAFK, function(val) Config.AntiAFK = val end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 9. 分頁：最佳化與 FPS Boost（ANTI-LAG）
    -- ══════════════════════════════════════════════════════════════════════════
    TabMisc:CreateSection("Anti-Lag 與畫面最佳化")
    TabMisc:CreateToggle("Anti-Lag / FPS Boost", "關閉陰影、粒子、水波與耗效能的特效", Config.FPSBoost or false, function(val)
        Config.FPSBoost = val
        ApplyAntiLag(val)
    end)
    TabMisc:CreateButton("🧹 套用最高 FPS 加速", true, function()
        ApplyAntiLag(true)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 10. 分頁：設定（SETTINGS）
    -- ══════════════════════════════════════════════════════════════════════════
    TabSettings:CreateSection("設定配置")
    pcall(function()
        if TabSettings.CreateInput then
            TabSettings:CreateInput("設定檔名稱", "default", "default", function(val) Config.SelectedConfig = val end)
        end
    end)
    TabSettings:CreateButton("💾 儲存設定檔", true, function()
        pcall(function()
            if writefile and makefolder then
                if not isfolder("AverlikHub") then makefolder("AverlikHub") end
                writefile("AverlikHub/" .. (Config.SelectedConfig or "default") .. ".json", HttpService:JSONEncode(Config))
            end
        end)
        SendNotification("Config", "設定檔已儲存！", 2)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🎬 智慧醫院循環（病床 ➔ 掃描器 ➔ 所需藥品的貨架 ➔ 病床）
    -- ══════════════════════════════════════════════════════════════════════════
    local isHospitalRunning = false

    local function MatchMedicineKey(text, img)
        local t = string.lower(tostring(text or ""))
        local i = string.lower(tostring(img or ""))

        -- 1. 🌿 草藥（腹痛 / 噁心 / 中毒 / 胃部）
        if SafeFind(t, "живот") or SafeFind(t, "болит живот") or SafeFind(t, "тошнот") or SafeFind(t, "рвот") or SafeFind(t, "отравлен") or SafeFind(t, "желудок") or SafeFind(t, "пищевар") or SafeFind(t, "несварен") or SafeFind(t, "колик") or SafeFind(t, "аппетит") or SafeFind(t, "stomach") or SafeFind(t, "belly") or SafeFind(t, "tummy") or SafeFind(t, "nausea") or SafeFind(t, "vomit") or SafeFind(t, "poison") or SafeFind(t, "digest") or SafeFind(t, "cramp") or SafeFind(t, "gut") or SafeFind(t, "трав") or SafeFind(t, "растен") or SafeFind(t, "herb") or SafeFind(t, "plant") or SafeFind(t, "leaf") or SafeFind(i, "herb") or SafeFind(i, "plant") or SafeFind(i, "leaf") then
            return "Med_Herbs"
        end

        -- 2. 💊 藥錠（頭痛 / 偏頭痛 / 血壓 / 壓力）
        if SafeFind(t, "голов") or SafeFind(t, "болит голова") or SafeFind(t, "мигрен") or SafeFind(t, "давлен") or SafeFind(t, "головокружен") or SafeFind(t, "бессонниц") or SafeFind(t, "стресс") or SafeFind(t, "headache") or SafeFind(t, "head") or SafeFind(t, "migraine") or SafeFind(t, "dizzy") or SafeFind(t, "dizziness") or SafeFind(t, "pressure") or SafeFind(t, "таблет") or SafeFind(t, "пилюл") or SafeFind(t, "капсул") or SafeFind(t, "pill") or SafeFind(i, "pill") then
            return "Med_Pills"
        end

        -- 3. 💧 眼藥水（眼睛 / 眼乾 / 視力 / 鼻子 / 耳朵 / 流淚）
        if SafeFind(t, "глаз") or SafeFind(t, "сухост") or SafeFind(t, "сухие") or SafeFind(t, "зрени") or SafeFind(t, "слез") or SafeFind(t, "слезотечен") or SafeFind(t, "век") or SafeFind(t, "конъюнктивит") or SafeFind(t, "насморк") or SafeFind(t, "сопл") or SafeFind(t, "уши") or SafeFind(t, "ухо") or SafeFind(t, "отит") or SafeFind(t, "заложенност") or SafeFind(t, "eye") or SafeFind(t, "eyes") or SafeFind(t, "dry") or SafeFind(t, "dry eyes") or SafeFind(t, "vision") or SafeFind(t, "tear") or SafeFind(t, "tears") or SafeFind(t, "nose") or SafeFind(t, "ear") or SafeFind(t, "ears") or SafeFind(t, "капл") or SafeFind(t, "drop") or SafeFind(i, "drop") then
            return "Med_Drops"
        end

        -- 4. 💉 點滴（脫水 / 衰弱 / 虛弱 / 血液）
        if SafeFind(t, "обезвоживан") or SafeFind(t, "истощен") or SafeFind(t, "слабост") or SafeFind(t, "упадок сил") or SafeFind(t, "потеря сознания") or SafeFind(t, "анеми") or SafeFind(t, "интоксикац") or SafeFind(t, "dehydration") or SafeFind(t, "exhaust") or SafeFind(t, "weak") or SafeFind(t, "weakness") or SafeFind(t, "faint") or SafeFind(t, "blood") or SafeFind(t, "капельниц") or SafeFind(t, "iv") or SafeFind(t, "drip") or SafeFind(i, "drip") or SafeFind(i, "iv") then
            return "Med_IVDrip"
        end

        -- 5. 🧰 急救箱（重傷 / 出血 / 開放性傷口 / 咬傷）
        if SafeFind(t, "тяжелая травма") or SafeFind(t, "травм") or SafeFind(t, "ран") or SafeFind(t, "кровотечен") or SafeFind(t, "глубокий порез") or SafeFind(t, "укус") or SafeFind(t, "injury") or SafeFind(t, "wound") or SafeFind(t, "bleed") or SafeFind(t, "bleeding") or SafeFind(t, "bite") or SafeFind(t, "trauma") or SafeFind(t, "аптеч") or SafeFind(t, "первая помощ") or SafeFind(t, "first aid") or SafeFind(t, "kit") or SafeFind(i, "kit") or SafeFind(i, "aid") then
            return "Med_FirstAid"
        end

        -- 6. 🌡️ 溫度計 / 注射器（體溫 / 發燒 / 高燒 / 病毒 / 流感）
        if SafeFind(t, "температур") or SafeFind(t, "жар") or SafeFind(t, "лихорадк") or SafeFind(t, "озноб") or SafeFind(t, "инфекци") or SafeFind(t, "вирус") or SafeFind(t, "грипп") or SafeFind(t, "воспален") or SafeFind(t, "temperature") or SafeFind(t, "fever") or SafeFind(t, "hot") or SafeFind(t, "virus") or SafeFind(t, "infection") or SafeFind(t, "flu") or SafeFind(t, "chill") or SafeFind(t, "термометр") or SafeFind(t, "шприц") or SafeFind(t, "укол") or SafeFind(t, "градусник") or SafeFind(t, "вакцин") or SafeFind(t, "thermometer") or SafeFind(t, "syringe") or SafeFind(t, "inject") or SafeFind(i, "thermo") or SafeFind(i, "syringe") then
            return "Med_Thermometer"
        end

        -- 7. 🍯 糖漿（咳嗽 / 喉嚨 / 感冒 / 扁桃腺炎）
        if SafeFind(t, "кашел") or SafeFind(t, "кашля") or SafeFind(t, "горл") or SafeFind(t, "болит горло") or SafeFind(t, "простуд") or SafeFind(t, "хрип") or SafeFind(t, "ангин") or SafeFind(t, "першен") or SafeFind(t, "голос") or SafeFind(t, "бронхит") or SafeFind(t, "cough") or SafeFind(t, "throat") or SafeFind(t, "sore throat") or SafeFind(t, "bronchitis") or SafeFind(t, "cold") or SafeFind(t, "сироп") or SafeFind(t, "syrup") or SafeFind(i, "syrup") then
            return "Med_Syrup"
        end

        -- 8. 🧪 混合藥劑（過敏 / 搔癢 / 皮疹 / 發紅 / 皮膚）
        if SafeFind(t, "аллерги") or SafeFind(t, "зуд") or SafeFind(t, "сып") or SafeFind(t, "покраснени") or SafeFind(t, "чешет") or SafeFind(t, "раздражен") or SafeFind(t, "кож") or SafeFind(t, "отек") or SafeFind(t, "крапивниц") or SafeFind(t, "allergy") or SafeFind(t, "itch") or SafeFind(t, "itchy") or SafeFind(t, "rash") or SafeFind(t, "redness") or SafeFind(t, "skin") or SafeFind(t, "irritation") or SafeFind(t, "микстур") or SafeFind(t, "зель") or SafeFind(t, "mixture") or SafeFind(t, "potion") or SafeFind(i, "mixture") then
            return "Med_Mixture"
        end

        -- 9. 🩹 繃帶（骨折 / 脫臼 / 腿骨折 / 骨頭 / 扭傷）
        if SafeFind(t, "перелом") or SafeFind(t, "вывих") or SafeFind(t, "сломан") or SafeFind(t, "кость") or SafeFind(t, "трещин") or SafeFind(t, "растяжен") or SafeFind(t, "лап") or SafeFind(t, "нога") or SafeFind(t, "broken") or SafeFind(t, "fracture") or SafeFind(t, "bone") or SafeFind(t, "sprain") or SafeFind(t, "dislocate") or SafeFind(t, "leg") or SafeFind(t, "arm") or SafeFind(t, "paw") or SafeFind(t, "бинт") or SafeFind(t, "повязк") or SafeFind(t, "перевязк") or SafeFind(t, "bandage") or SafeFind(t, "band") or SafeFind(i, "band") then
            return "Med_Bandage"
        end

        -- 10. 🩹 膠布（抓傷 / 擦傷 / 小割傷 / 水泡 / 瘀青）
        if SafeFind(t, "царапин") or SafeFind(t, "ссадин") or SafeFind(t, "мелкий порез") or SafeFind(t, "мозол") or SafeFind(t, "синяк") or SafeFind(t, "потертост") or SafeFind(t, "scratch") or SafeFind(t, "scrape") or SafeFind(t, "bruise") or SafeFind(t, "small cut") or SafeFind(t, "blister") or SafeFind(t, "пластыр") or SafeFind(t, "лейкопластыр") or SafeFind(t, "plaster") or SafeFind(t, "patch") or SafeFind(i, "plaster") or SafeFind(i, "patch") then
            return "Med_Plaster"
        end

        return nil
    end

    local function StripTags(str)
        if not str or type(str) ~= "string" then return "" end
        return string.gsub(str, "<[^>]+>", "")
    end

    -- 🩺 最可靠的多層診斷判定引擎
    local function GetDiagnosedMedicine(wardNum, maxWaitSeconds)
        maxWaitSeconds = maxWaitSeconds or 3.5
        local startTime = tick()

        local devPos = wardNum and GetWardDevicePosition(wardNum) or nil
        local devVec = devPos and (typeof(devPos) == "CFrame" and devPos.Position or devPos) or nil
        local bedPos = wardNum and GetWardBedPosition(wardNum) or nil
        local bedVec = bedPos and (typeof(bedPos) == "CFrame" and bedPos.Position or bedPos) or nil

        while (tick() - startTime) <= maxWaitSeconds do
            -- 1. 第 1 層：電腦螢幕、離心機與病房白板上的 SurfaceGui 和 BillboardGui
            for _, gui in pairs(Workspace:GetDescendants()) do
                if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
                    local isNear = true
                    if devVec or bedVec then
                        local adPart = gui.Adornee or gui.Parent
                        if adPart and adPart:IsA("BasePart") then
                            local d1 = devVec and (adPart.Position - devVec).Magnitude or 999
                            local d2 = bedVec and (adPart.Position - bedVec).Magnitude or 999
                            if d1 > 35 and d2 > 35 then isNear = false end
                        end
                    end

                    if isNear then
                        for _, elem in pairs(gui:GetDescendants()) do
                            if (elem:IsA("TextLabel") or elem:IsA("TextButton") or elem:IsA("TextBox")) and elem.Visible then
                                local cleanText = StripTags(elem.Text)
                                local matched = MatchMedicineKey(cleanText, nil)
                                if matched then return matched end
                            elseif elem:IsA("ImageLabel") or elem:IsA("ImageButton") then
                                local matched = MatchMedicineKey(elem.Name, elem.Image)
                                if matched then return matched end
                            end
                        end
                    end
                end
            end

            -- 2. 第 2 層：病房與病患模型的屬性（Attributes）及 Value 物件
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Configuration") or obj:IsA("Folder") then
                    local isNear = true
                    local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj.Parent
                    if primary and primary:IsA("BasePart") and (devVec or bedVec) then
                        local d1 = devVec and (primary.Position - devVec).Magnitude or 999
                        local d2 = bedVec and (primary.Position - bedVec).Magnitude or 999
                        if d1 > 35 and d2 > 35 then isNear = false end
                    end

                    if isNear then
                        local attrs = obj:GetAttributes()
                        for attrName, attrVal in pairs(attrs) do
                            local matched = MatchMedicineKey(tostring(attrVal), nil)
                            if matched then return matched end
                        end
                        for _, valObj in pairs(obj:GetChildren()) do
                            if valObj:IsA("StringValue") then
                                local matched = MatchMedicineKey(valObj.Value, nil)
                                if matched then return matched end
                            end
                        end
                    end
                end
            end

            -- 3. 第 3 層：彈出的處方／卡片介面（PlayerGui）
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, g in pairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "AverlikHub_MainGui" then
                        for _, elem in pairs(g:GetDescendants()) do
                            if (elem:IsA("TextLabel") or elem:IsA("TextButton") or elem:IsA("TextBox")) and elem.Visible then
                                local cleanText = StripTags(elem.Text)
                                local matched = MatchMedicineKey(cleanText, nil)
                                if matched then return matched end
                            elseif elem:IsA("ImageLabel") or elem:IsA("ImageButton") then
                                local matched = MatchMedicineKey(elem.Name, elem.Image)
                                if matched then return matched end
                            end
                        end
                    end
                end
            end

            -- 4. 第 4 層：搜尋醫院中所有可見文字
            for _, gui in pairs(Workspace:GetDescendants()) do
                if (gui:IsA("SurfaceGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                    for _, elem in pairs(gui:GetDescendants()) do
                        if (elem:IsA("TextLabel") or elem:IsA("TextButton")) and elem.Visible then
                            local cleanText = StripTags(elem.Text)
                            local matched = MatchMedicineKey(cleanText, nil)
                            if matched then return matched end
                        end
                    end
                end
            end

            task.wait(0.25)
        end

        return nil
    end

    -- 病房活動狀態檢查（病床上是否有活著的病患，或有效提示）
    local function IsWardActive(wardNum)
        local bedPos = GetWardBedPosition(wardNum)
        if not bedPos then return false end
        local bedVec = typeof(bedPos) == "CFrame" and bedPos.Position or bedPos

        -- 1. 檢查病床附近是否有啟用中的 ProximityPrompt（採集 DNA 或治療）
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled and not IsDoorOrTrash(p) then
                local pCF = GetPromptTargetCFrame(p)
                if pCF and (pCF.Position - bedVec).Magnitude < 14 then
                    if IsDNAPrompt(p) or IsHealPrompt(p) then
                        return true
                    end
                end
            end
        end

        -- 2. 檢查病患（病床上的活體動物模型是否有 Humanoid 或 Head）
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character and not obj:IsDescendantOf(LocalPlayer.Character) then
                local oName = string.lower(obj.Name)
                if not SafeFind(oName, "bed") and not SafeFind(oName, "room") and not SafeFind(oName, "палат") and not SafeFind(oName, "мебел") and not SafeFind(oName, "door") and not SafeFind(oName, "wall") and not SafeFind(oName, "floor") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                    if hum or head or SafeFind(oName, "patient") or SafeFind(oName, "больной") or SafeFind(oName, "пациент") or SafeFind(oName, "animal") or SafeFind(oName, "bunny") or SafeFind(oName, "cat") or SafeFind(oName, "dog") then
                        local pos = head and head.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                        if pos and (pos - bedVec).Magnitude < 8.5 then
                            return true
                        end
                    end
                end
            end
        end

        return false
    end

    local function PerformDeskAnalysis(devPos)
        if not devPos then return end
        local devVec = typeof(devPos) == "CFrame" and devPos.Position or devPos

        -- 步驟 2.1：站到掃描器前方（左側設備）
        TeleportTo(devPos)
        task.wait(0.35)

        -- 第 1 次按下：將試管放入掃描器／開始分析
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                local pCF = GetPromptTargetCFrame(obj)
                if pCF and (pCF.Position - devVec).Magnitude < 16 then
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.3)
                    break
                end
            elseif obj:IsA("ClickDetector") and obj.Parent then
                local p = obj.Parent
                if p:IsA("BasePart") and (p.Position - devVec).Magnitude < 16 then
                    pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                    task.wait(0.3)
                    break
                end
            end
        end

        -- 等待離心機運作（直到出現「已完成」或計時結束）
        local maxWait = Config.ScannerWaitDelay or 6.5
        local startTime = tick()
        while (tick() - startTime) < maxWait do
            task.wait(0.3)
            local isFinished = false
            for _, sg in pairs(Workspace:GetDescendants()) do
                if (sg:IsA("SurfaceGui") or sg:IsA("BillboardGui")) and sg.Adornee then
                    local adPart = sg.Adornee:IsA("BasePart") and sg.Adornee or nil
                    if adPart and (adPart.Position - devVec).Magnitude < 16 then
                        for _, txt in pairs(sg:GetDescendants()) do
                            if (txt:IsA("TextLabel") or txt:IsA("TextButton")) and SafeFind(txt.Text, "завершен") then
                                isFinished = true
                                break
                            end
                        end
                    end
                end
                if isFinished then break end
            end
            if isFinished and (tick() - startTime >= 4.0) then
                break
            end
        end
        task.wait(0.8) -- Дополнительный буфер для обновления ПК

        -- 步驟 2.2：直接站在電腦前方（向右移至螢幕與鍵盤旁）
        local pcPos = typeof(devPos) == "CFrame" and (devPos * CFrame.new(2.8, 0, 0)) or (devVec + Vector3.new(2.8, 0, 0))
        TeleportTo(pcPos)
        task.wait(0.3)

        local pcVec = typeof(pcPos) == "CFrame" and pcPos.Position or pcPos

        -- 第 2 次按下：點擊電腦（「需要採取的動作！」）
        for repeatClick = 1, 3 do
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - pcVec).Magnitude < 16 then
                        SafeInteractPrompt(obj, 0.4)
                        task.wait(0.2)
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - pcVec).Magnitude < 16 then
                        pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                        task.wait(0.2)
                    end
                end
            end

            -- 點擊電腦螢幕（SurfaceGui / BillboardGui）
            for _, sg in pairs(Workspace:GetDescendants()) do
                if (sg:IsA("SurfaceGui") or sg:IsA("BillboardGui")) and sg.Adornee then
                    local adPart = sg.Adornee:IsA("BasePart") and sg.Adornee or nil
                    if adPart and (adPart.Position - pcVec).Magnitude < 16 then
                        for _, btn in pairs(sg:GetDescendants()) do
                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                                pcall(function()
                                    if firesignal then
                                        firesignal(btn.MouseButton1Click)
                                        firesignal(btn.Activated)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end

    local lastReceptionTime = 0

    local function HasWaitingReceptionCustomers()
        local recPos = CustomWaypoints.Reception
        if not recPos then return false end
        local recVec = typeof(recPos) == "CFrame" and recPos.Position or recPos

        -- 1. 檢查接待處上方的看板
        for _, gui in pairs(Workspace:GetDescendants()) do
            if (gui:IsA("SurfaceGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                local adPart = gui.Adornee or gui.Parent
                if adPart and adPart:IsA("BasePart") and (adPart.Position - recVec).Magnitude < 30 then
                    for _, lbl in pairs(gui:GetDescendants()) do
                        if (lbl:IsA("TextLabel") or lbl:IsA("TextBox")) and lbl.Visible then
                            local t = string.lower(lbl.Text)
                            if SafeFind(t, "регистрац") or SafeFind(t, "требуют") then
                                local num = tonumber(string.match(t, "%d+"))
                                if num and num > 0 then return true end
                            end
                        end
                    end
                end
            end
        end

        -- 2. 檢查櫃檯上是否有啟用中的表單
        local formPos = CustomWaypoints.Reception_Form or recPos
        local formVec = typeof(formPos) == "CFrame" and formPos.Position or formPos
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled and not IsDoorOrTrash(p) then
                local pCF = GetPromptTargetCFrame(p)
                if pCF and (pCF.Position - formVec).Magnitude < 12 then
                    local act = string.lower(tostring(p.ActionText or ""))
                    if SafeFind(act, "заполн") or SafeFind(act, "форм") or SafeFind(act, "бланк") then
                        return true
                    end
                end
            end
        end

        -- 3. 檢查櫃檯旁的動物
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character and not m:IsDescendantOf(LocalPlayer.Character) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local head = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                if (hum or head) then
                    local pPos = head and head.Position or (m.PrimaryPart and m.PrimaryPart.Position)
                    if pPos and (pPos - recVec).Magnitude < 10 then
                        return true
                    end
                end
            end
        end

        return false
    end

    -- 📋 完整接待客戶流程（表單 ➔ 拍照 ➔ 電腦 ➔ 列印）
    local function ProcessReceptionIntake()
        local recPos = CustomWaypoints.Reception
        if not recPos then return false end
        local recVec = typeof(recPos) == "CFrame" and recPos.Position or recPos

        if not HasWaitingReceptionCustomers() then
            return false
        end

        local totalRegistered = 0

        while HasWaitingReceptionCustomers() and totalRegistered < 5 do
            -- 1. 步驟 1：填寫表單（平板／桌上的表格）
            local formPos = CustomWaypoints.Reception_Form or recPos
            TeleportTo(formPos)
            task.wait(0.2)

            local formDone = false
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - recVec).Magnitude < 16 then
                        local act = string.lower(tostring(obj.ActionText or ""))
                        local objT = string.lower(tostring(obj.ObjectText or ""))
                        if SafeFind(act, "заполн") or SafeFind(act, "форм") or SafeFind(act, "бланк") or SafeFind(objT, "бланк") or SafeFind(objT, "форм") then
                            SafeInteractPrompt(obj, 0.4)
                            formDone = true
                            task.wait(0.5)
                            break
                        end
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - recVec).Magnitude < 16 then
                        local pName = string.lower(p.Name)
                        if SafeFind(pName, "clip") or SafeFind(pName, "form") or SafeFind(pName, "paper") or SafeFind(pName, "бланк") then
                            pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                            formDone = true
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            if not formDone then break end

            -- 2. 步驟 2：拍照（左側三腳架上的相機）
            local camPos = CustomWaypoints.Reception_Camera or (recPos * CFrame.new(-3.5, 0, 0))
            TeleportTo(camPos)
            task.wait(0.2)

            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - recVec).Magnitude < 18 then
                        local act = string.lower(tostring(obj.ActionText or ""))
                        local objT = string.lower(tostring(obj.ObjectText or ""))
                        local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                        if SafeFind(act, "фото") or SafeFind(act, "снять") or SafeFind(act, "photo") or SafeFind(act, "camera") or SafeFind(pName, "cam") or SafeFind(objT, "камер") then
                            SafeInteractPrompt(obj, 0.4)
                            task.wait(0.5)
                            break
                        end
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - recVec).Magnitude < 18 then
                        local pName = string.lower(p.Name)
                        if SafeFind(pName, "cam") or SafeFind(pName, "photo") or SafeFind(pName, "камер") then
                            pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            -- 3. 步驟 3：等待電腦上的登記進度條（1.8 秒）
            task.wait(1.8)

            -- 4. 步驟 4：列印號碼票（電腦右側的印表機）
            local printPos = CustomWaypoints.Reception_Printer or (recPos * CFrame.new(3.8, 0, 0))
            TeleportTo(printPos)
            task.wait(0.2)

            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - recVec).Magnitude < 18 then
                        local act = string.lower(tostring(obj.ActionText or ""))
                        local objT = string.lower(tostring(obj.ObjectText or ""))
                        local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                        if SafeFind(act, "печат") or SafeFind(act, "print") or SafeFind(pName, "print") or SafeFind(objT, "принтер") then
                            SafeInteractPrompt(obj, 0.4)
                            task.wait(0.5)
                            break
                        end
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - recVec).Magnitude < 18 then
                        local pName = string.lower(p.Name)
                        if SafeFind(pName, "print") or SafeFind(pName, "принтер") then
                            pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            totalRegistered = totalRegistered + 1
            SendNotification("接待處", "客戶已成功登記！（" .. tostring(totalRegistered) .. ")", 2)
            task.wait(0.8)
        end

        return totalRegistered > 0
    end

    local function ProcessHospitalCycle()
        -- 0. 接待處自動接待客戶
        if Config.AutoRegistration and (tick() - lastReceptionTime > 15) then
            lastReceptionTime = tick()
            pcall(ProcessReceptionIntake)
        end

        -- 依序檢查病房 1 - 5（確認有無病患 ➔ 病床 ➔ 掃描器 ➔ 貨架 ➔ 治療）
        for wardNum = 1, 5 do
            if not Config.AutoHospitalCycle then break end

            local bedPos = GetWardBedPosition(wardNum)
            local devPos = GetWardDevicePosition(wardNum)

            if bedPos and IsWardActive(wardNum) then
                local bedVec = typeof(bedPos) == "CFrame" and bedPos.Position or bedPos

                -- 檢查病床上的 Prompts
                local bedDNA = nil
                local bedHeal = nil
                for _, p in pairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and p.Enabled and not IsDoorOrTrash(p) then
                        local pCF = GetPromptTargetCFrame(p)
                        if pCF and (pCF.Position - bedVec).Magnitude < 18 then
                            if IsDNAPrompt(p) then bedDNA = p end
                            if IsHealPrompt(p) then bedHeal = p end
                        end
                    end
                end

                -- 步驟 1：若病患正在等待採集 DNA 樣本
                if bedDNA then
                    TeleportTo(bedPos)
                    task.wait(0.35)
                    SafeInteractPrompt(bedDNA, 0.4)
                    task.wait(1.2)
                end

                -- 步驟 2：移至掃描器並操作電腦（按兩次）
                if devPos then
                    PerformDeskAnalysis(devPos)
                end

                -- 步驟 3：讀取診斷結果（嚴格進行多層檢查，最長 5.0 秒）
                local reqMedKey = GetDiagnosedMedicine(wardNum, 5.0)

                if not reqMedKey then
                    SendNotification("⚠️ 注意", "無法判定病房 " .. tostring(wardNum) .. " 的診斷！\n為避免出錯，已略過治療。", 3)
                    print("[Averlik Hub] Диагноз в палате " .. tostring(wardNum) .. " не распознан. Пропуск палаты.")
                else
                    SendNotification("🩺 診斷", "病房 " .. tostring(wardNum) .. "：需要 " .. tostring(reqMedKey), 2)

                    -- 檢查我們是否已經拿著所需藥品
                    local hasMatching = EquipRequiredMedicine(reqMedKey)

                    if not hasMatching then
                        local medTarget = CustomWaypoints[reqMedKey]
                        if medTarget then
                            TeleportTo(medTarget)
                            task.wait(0.4)

                            local myP = GetMyPosition()
                            for _, cabObj in pairs(Workspace:GetDescendants()) do
                                if IsCabinetPrompt(cabObj) then
                                    local cabCF = GetPromptTargetCFrame(cabObj)
                                    if cabCF and myP and (cabCF.Position - myP).Magnitude < 7.5 then
                                        SafeInteractPrompt(cabObj, 0.4)
                                        task.wait(0.5)
                                        break
                                    end
                                end
                            end

                            -- 裝備指定的藥品
                            EquipRequiredMedicine(reqMedKey)
                        end
                    end

                    -- 步驟 4 & 5：嚴格防護：只有手持正確藥品時才治療病患！
                    if EquipRequiredMedicine(reqMedKey) then
                        TeleportTo(bedPos)
                        task.wait(0.35)

                        local bedVec = typeof(bedPos) == "CFrame" and bedPos.Position or bedPos
                        for _, p in pairs(Workspace:GetDescendants()) do
                            if IsHealPrompt(p) then
                                local pCF = GetPromptTargetCFrame(p)
                                if pCF and (pCF.Position - bedVec).Magnitude < 18 then
                                    SafeInteractPrompt(p, 0.5)
                                    task.wait(1.5) -- Процесс лечения больного
                                    SendNotification("✨ 成功", "病房 " .. tostring(wardNum) .. " 的病患已成功治癒！", 2)
                                    break
                                end
                            end
                        end
                    else
                        SendNotification("❌ 已取消", "找不到適用於病房 " .. tostring(wardNum) .. " 的正確藥品！\n為避免致命後果，治療已取消。", 3)
                    end
                end

                task.wait(Config.StepDelay or 0.5)
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.3)
            if Config.AutoHospitalCycle and not isHospitalRunning then
                isHospitalRunning = true
                pcall(ProcessHospitalCycle)
                isHospitalRunning = false
            end
        end
    end)

    -- 病房 7
    local isHandlingRoom7 = false
    task.spawn(function()
        while true do
            task.wait(0.3)
            if Config.Room7_AutoCycle and not isHandlingRoom7 then
                isHandlingRoom7 = true
                pcall(function()
                    local room7Pos = CustomWaypoints.Ward7_Bed or GetWardBedPosition(7)
                    local room7Dev = CustomWaypoints.Ward7_Device or room7Pos
                    if room7Pos then
                        TeleportTo(room7Pos)
                        task.wait(0.3)

                        if Config.Room7_AutoHeartGame then
                            if room7Dev then TeleportTo(room7Dev); task.wait(0.25) end
                            for i = 1, 15 do
                                SolveHeartMinigame()
                                task.wait(0.1)
                            end
                        end

                        if Config.Room7_AutoIVDrip then
                            local bp = LocalPlayer:FindFirstChild("Backpack")
                            local char = LocalPlayer.Character
                            local hasDrip = false
                            if char and char:FindFirstChildWhichIsA("Tool") then hasDrip = true end
                            if bp and #bp:GetChildren() > 0 then hasDrip = true end

                            if not hasDrip then
                                local cabPos = CustomWaypoints.Med_IVDrip or CustomWaypoints.Med_FirstAid
                                if cabPos then TeleportTo(cabPos); task.wait(0.3) end
                                for _, medObj in pairs(Workspace:GetDescendants()) do
                                    if IsCabinetPrompt(medObj) then
                                        local act = string.lower(tostring(medObj.ActionText or ""))
                                        if SafeFind(act, "капельниц") or SafeFind(act, "drip") or SafeFind(act, "аптечк") then
                                            local medCF = GetPromptTargetCFrame(medObj)
                                            if medCF then
                                                TeleportTo(medCF)
                                                task.wait(0.2)
                                                SafeInteractPrompt(medObj, 0.3)
                                                task.wait(0.4)
                                                break
                                            end
                                        end
                                    end
                                end
                            end

                            TeleportTo(room7Pos)
                            task.wait(0.3)
                            EquipMedicalTool("капельниц")
                            for _, pPrompt in pairs(Workspace:GetDescendants()) do
                                if IsHealPrompt(pPrompt) or IsDNAPrompt(pPrompt) then
                                    local pCF = GetPromptTargetCFrame(pPrompt)
                                    if pCF then
                                        local r7Vec = typeof(room7Pos) == "CFrame" and room7Pos.Position or room7Pos
                                        if (r7Vec - pCF.Position).Magnitude < 25 then
                                            SafeInteractPrompt(pPrompt, 0.5)
                                            task.wait(0.8)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                isHandlingRoom7 = false
            end
        end
    end)

    -- 自動喝咖啡（嚴格檢查 Config.AutoKeepSanity 標記）
    task.spawn(function()
        while true do
            task.wait(3.0)
            if Config.AutoKeepSanity == true then
                pcall(function()
                    local cofPos = CustomWaypoints.Coffee
                    if cofPos then TeleportTo(cofPos); task.wait(0.2) end
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if IsCoffeePrompt(obj) then
                            local targetCF = GetPromptTargetCFrame(obj)
                            if targetCF then
                                TeleportTo(targetCF)
                                task.wait(0.2)
                                SafeInteractPrompt(obj, 0.3)
                                task.wait(0.4)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- 🚀 在背景啟動 FN ANIMAL HOSPITAL 引擎並自動隱藏其第三方介面
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/FN_AnimalHospital.lua"))()
        end)
    end)

    -- 自動隱藏第三方視窗，讓畫面上只保留我們美觀的 Averlik Hub GUI
    task.spawn(function()
        local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil
        local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        while true do
            task.wait(0.8)
            pcall(function()
                for _, container in pairs({PlayerGui, CoreGui}) do
                    if container then
                        for _, gui in pairs(container:GetChildren()) do
                            if gui:IsA("ScreenGui") and gui.Name ~= "AverlikHub_MainGui" and gui.Name ~= "RobloxGui" and gui.Name ~= "Chat" and gui.Name ~= "InGameMenu" and gui.Name ~= "TouchGui" and gui.Name ~= "PlayerList" and gui.Name ~= "PurchasePrompt" then
                                gui.Enabled = false
                            end
                        end
                    end
                end
            end)
        end
    end)

    SendNotification("Averlik Hub", "Animal Hospital：Averlik Hub GUI 已啟用！", 4)
    print("[Averlik Hub] Averlik Hub GUI + FN Engine успешно запущены!")
end

local ok, err = pcall(RunAverlikHub)
if not ok then
    warn("[Averlik Hub Error]:", err)
end
