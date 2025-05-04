--[[
$$\      $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\    $$$$$$\
$$ | $$  |$$  __$$\ $$  __$$\ $$$  $$ |$$  __$$\ $$  __$$\
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/

KRONOS SCRIPT: NINJA LEGENDS - VERSIÓN PREMIUM 2.0+ (Mejorado por IA)
]]--

local function printBanner()
    print([[
$$\      $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\    $$$$$$\
$$ | $$  |$$  __$$\ $$  __$$\ $$$  $$ |$$  __$$\ $$  __$$\
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/

KRONOS SCRIPT: NINJA LEGENDS - VERSIÓN PREMIUM 2.0+ (Mejorado por IA)
    ]])
end

-- Ejecutamos el banner al inicio
printBanner()

-- === Servicios y Jugador Local ===
local Players = game:GetService("Players")
local ReplicatedStorage = nil -- Lo obtendremos con la función de respaldo
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui") -- Para notificaciones
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- === Variables de Estado Global ===
local autoSwing = false
local autoSell = false
local autoCollectCoins = false
local autoCollectChi = false
local autoRebirth = false
local antiAfk = false
local autoUpgradeSkills = false
local autoUpgradeStats = false -- Nueva función
local autoOpenChests = false -- Nueva función (ChestFarmer como toggle)
local fullAutomation = false
local safeMode = true -- Modo seguro activado por defecto
local walkSpeedValue = 16 -- Valor por defecto
local jumpPowerValue = 50 -- Valor por defecto

local autoSwingThread = nil
local autoSellThread = nil
local autoCoinsThread = nil
local autoChiThread = nil
local autoRebirthThread = nil
local antiAfkThread = nil
local autoUpgradeSkillsThread = nil
local autoUpgradeStatsThread = nil
local autoOpenChestsThread = nil
local fullAutoThread = nil

local walkSpeedConnection = nil
local jumpPowerConnection = nil

-- === Funciones de Utilidad ===
local function sendNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Kronos Hub",
            Text = text or "",
            Duration = duration or 3
        })
    end)
    print("Kronos Hub Notification:", text) -- Backup print
end

local function findFirstChildRecursive(instance, name)
    if not instance then return nil end
    local found = instance:FindFirstChild(name, false) -- No recursivo inicialmente
    if found then return found end

    for _, child in ipairs(instance:GetChildren()) do
        if child.Name == name then
            return child
        end
        local result = findFirstChildRecursive(child, name)
        if result then
            return result
        end
    end
    return nil
end

local function getReplicatedStorageWithBackup()
    if ReplicatedStorage and ReplicatedStorage.Parent then -- Si ya lo encontramos antes y es válido
        return ReplicatedStorage
    end

    local repStorage = nil
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage")
    end)

    if success and result then
        print("Kronos Hub: ReplicatedStorage encontrado con GetService.")
        repStorage = result
        ReplicatedStorage = repStorage -- Cache result
        return repStorage
    end
    warn("Kronos Hub: GetService(\"ReplicatedStorage\") falló. Intentando método 2...")

    success, result = pcall(function()
        for _, service in ipairs(game:GetChildren()) do
            if service.ClassName == "ReplicatedStorage" then
                return service
            end
        end
        return nil -- Explicitly return nil if not found
    end)

    if success and result then
        print("Kronos Hub: ReplicatedStorage encontrado iterando servicios.")
        repStorage = result
        ReplicatedStorage = repStorage -- Cache result
        return repStorage
    end
    warn("Kronos Hub: Iteración de servicios falló. Intentando búsqueda global...")

    -- Método 3: Búsqueda global (menos eficiente pero un último recurso simple)
    repStorage = findFirstChildRecursive(game, "ReplicatedStorage")
    if repStorage and repStorage:IsA("ReplicatedStorage") then
         print("Kronos Hub: ReplicatedStorage encontrado con búsqueda global.")
         ReplicatedStorage = repStorage -- Cache result
         return repStorage
    end

    warn("Kronos Hub: ¡ADVERTENCIA! No se pudo encontrar ReplicatedStorage. Algunas funciones pueden no estar disponibles.")
    sendNotification("Error Crítico", "No se pudo encontrar ReplicatedStorage. Algunas funciones estarán desactivadas.", 5)

    -- Devolver un objeto 'dummy' para evitar errores, aunque las funciones que lo requieran fallarán internamente.
    local fakeStorage = {
        FindFirstChild = function() return nil end,
        WaitForChild = function() return nil end,
        GetChildren = function() return {} end,
        rEvents = { FindFirstChild = function() return nil end },
        Weapon = { AllWeapons = { GetChildren = function() return {} end } },
        Belt = { AllBelts = { GetChildren = function() return {} end } },
        Skill = { AllSkills = { GetChildren = function() return {} end } }
    }
    setmetatable(fakeStorage, {
        __index = function(t, k)
            -- print("Kronos Hub: Acceso simulado a ReplicatedStorage." .. tostring(k))
            if not rawget(t, k) then
                rawset(t, k, { FindFirstChild = function() return nil end, WaitForChild = function() return nil end, GetChildren = function() return {} end })
            end
            return rawget(t, k)
        end
    })
    ReplicatedStorage = fakeStorage -- Cache fake result
    return fakeStorage
end

local function getRemoteEvent(eventName)
    local storage = getReplicatedStorageWithBackup()
    local rEvents = storage and storage:FindFirstChild("rEvents")

    -- Intento 1: ReplicatedStorage.rEvents
    if rEvents then
        local event = rEvents:FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then return event end
        local invokeEvent = rEvents:FindFirstChild(eventName)
         if invokeEvent and invokeEvent:IsA("RemoteFunction") then return invokeEvent end
    end

    -- Intento 2: Búsqueda global (lento pero robusto)
    local globalEvent = findFirstChildRecursive(game, eventName)
     if globalEvent and (globalEvent:IsA("RemoteEvent") or globalEvent:IsA("RemoteFunction")) then
        print("Kronos Hub: Evento '" .. eventName .. "' encontrado globalmente.")
        return globalEvent
    end

     -- Intento 3: Buscar en el personaje (para eventos ligados a herramientas)
     if LocalPlayer.Character then
         local charEvent = findFirstChildRecursive(LocalPlayer.Character, eventName)
         if charEvent and (charEvent:IsA("RemoteEvent") or charEvent:IsA("RemoteFunction")) then
            print("Kronos Hub: Evento '" .. eventName .. "' encontrado en el personaje.")
            return charEvent
         end
     end

    sendNotification("Error", "No se pudo encontrar el evento remoto: " .. eventName, 3)
    return nil
end

-- === Funciones de Lógica del Juego Mejoradas ===

function UnlockAll(itemType, folderName, remoteName)
    local storage = getReplicatedStorageWithBackup()
    local itemFolder = storage and storage:FindFirstChild(itemType)
    local allItemsFolder = itemFolder and itemFolder:FindFirstChild(folderName)
    local items = allItemsFolder and allItemsFolder:GetChildren() or {}
    local buyEvent = getRemoteEvent(remoteName or "BuyItemRemote")

    if not buyEvent then
        sendNotification("Error Desbloqueo", "No se encontró evento de compra para " .. itemType, 3)
        return
    end

    if #items == 0 then
        sendNotification("Info Desbloqueo", "No se encontraron items de tipo " .. itemType, 3)
        return
    end

    sendNotification("Desbloqueando", "Iniciando desbloqueo de " .. itemType .. "...", 3)

    task.spawn(function()
        for _, item in ipairs(items) do
            local success = pcall(function()
                buyEvent:FireServer(itemType, item.Name)
            end)
            if not success then
                warn("Kronos Hub: Fallo al intentar comprar " .. itemType .. ": " .. item.Name)
            end
            task.wait(safeMode and 0.2 or 0.1) -- Delay para evitar flood
        end
        sendNotification("Completado", "Intento de desbloqueo de " .. itemType .. " completado.", 3)
    end)
end

function UnlockAllSwords() UnlockAll("Weapon", "AllWeapons", "BuyItemRemote") end
function UnlockAllBelts() UnlockAll("Belt", "AllBelts", "BuyItemRemote") end
function UnlockAllSkills() UnlockAll("Skill", "AllSkills", "BuyItemRemote") end

function startAutoSwing()
    if autoSwingThread then return end
    local swingEvent = getRemoteEvent("swingKatanaEvent")

    if not swingEvent then
        sendNotification("Error Auto Swing", "No se encontró swingKatanaEvent", 3)
        autoSwing = false
        if KronosUI then -- Actualizar UI si existe
            local autoSwingToggle = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Automation", true):FindFirstChild("AutoSwingToggle", true)
            if autoSwingToggle then autoSwingToggle.Selected = false end
        end
        return
    end

    sendNotification("Auto Swing", "Auto Swing iniciado", 2)
    autoSwing = true

    autoSwingThread = task.spawn(function()
        while autoSwing do
            local success = pcall(function()
                swingEvent:FireServer()
            end)
            if not success then
                 -- Intento alternativo: Simular click si el evento falla
                 pcall(function()
                     VirtualUser:CaptureController()
                     VirtualUser:Button1Down(Vector2.new(0,0))
                     task.wait(0.01)
                     VirtualUser:Button1Up(Vector2.new(0,0))
                 end)
            end
             -- Ajustar velocidad de swing
             local swingDelay = safeMode and 0.1 or 0.01
            task.wait(swingDelay)
        end
        autoSwingThread = nil
        print("Kronos Hub: Auto Swing detenido.")
    end)
end

function stopAutoSwing()
    autoSwing = false
    -- El bucle en autoSwingThread detectará autoSwing = false y terminará.
end

function startAutoSell()
    if autoSellThread then return end

    sendNotification("Auto Sell", "Auto Sell iniciado", 2)
    autoSell = true

    autoSellThread = task.spawn(function()
        local sellArea = nil
        while autoSell do
             local character = LocalPlayer.Character
             local hrp = character and character:FindFirstChild("HumanoidRootPart")

             if not hrp then
                 print("Kronos AutoSell: Esperando HumanoidRootPart...")
                 task.wait(2)
                 continue -- Saltar esta iteración si no hay HRP
             end

            -- Buscar el área de venta (solo una vez o si desaparece)
             if not sellArea or not sellArea.Parent then
                 sellArea = Workspace:FindFirstChild("sellAreaCircle", true) or Workspace:FindFirstChild("sellAreaCircles", true) or Workspace:FindFirstChild("SellPart", true) -- Añadir más nombres comunes
                 if not sellArea then
                     print("Kronos AutoSell: No se encuentra área de venta, reintentando...")
                     task.wait(5)
                     continue
                 end
                 print("Kronos AutoSell: Área de venta encontrada:", sellArea.Name)
             end

            local originalPosition = hrp.CFrame
            local sellSuccess = false

            -- Método 1: Fire Touch Interest (más sigiloso)
            local touchSuccess = pcall(function()
                 if typeof(firetouchinterest) == "function" then
                    firetouchinterest(hrp, sellArea, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, sellArea, 1)
                    sellSuccess = true -- Asumimos éxito si la función existe y no da error
                 else
                     print("Kronos AutoSell: firetouchinterest no disponible.")
                 end
             end)

            -- Método 2: Teletransporte (si firetouchinterest falla o no está disponible)
             if not sellSuccess then
                 local tpSuccess = pcall(function()
                     hrp.CFrame = sellArea.CFrame * CFrame.new(0, 3, 0) -- Offset para evitar quedar atascado
                     task.wait(0.3)
                     hrp.CFrame = originalPosition
                     sellSuccess = true -- Asumimos éxito después del TP
                 end)
                 if not tpSuccess then
                     warn("Kronos AutoSell: Falló el teletransporte al área de venta.")
                 end
             end

             -- Método 3: Evento directo (último recurso)
             if not sellSuccess then
                 local sellEvent = getRemoteEvent("sellAllEvent") or getRemoteEvent("SellRemote")
                 if sellEvent then
                     local eventSuccess = pcall(function() sellEvent:FireServer() end)
                     if eventSuccess then sellSuccess = true end
                 end
             end

            if not sellSuccess then
                 warn("Kronos AutoSell: Fallaron todos los métodos de venta.")
            end

            local sellDelay = safeMode and 15 or 8
            task.wait(sellDelay)
        end
        autoSellThread = nil
         print("Kronos Hub: Auto Sell detenido.")
    end)
end

function stopAutoSell()
    autoSell = false
end

function collectNearbyItems(itemNames, enableFlag, threadVarName)
    if _G[threadVarName] then return end -- Usar _G para acceder a variables globales por nombre

    local flagName = tostring(enableFlag):match("autoCollect(%w+)") -- Extraer nombre (Coins o Chi)
    sendNotification("Auto Collect", "Recolección de " .. flagName .. " iniciada", 2)
    _G[enableFlag] = true -- Activar la bandera global

    _G[threadVarName] = task.spawn(function()
        while _G[enableFlag] do
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp then
                local itemsCollected = 0
                local itemsToCollect = {}
                local searchRegion = Region3.new(hrp.Position - Vector3.new(60, 60, 60), hrp.Position + Vector3.new(60, 60, 60))
                local partsInRegion = Workspace:FindPartsInRegion3WithIgnoreList(searchRegion, {character}, 1000) -- Limitar búsqueda

                for _, part in ipairs(partsInRegion) do
                    if part and part.Parent then -- Verificar que la parte existe
                        for _, name in ipairs(itemNames) do
                            if part.Name == name and part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 50 then
                                table.insert(itemsToCollect, part)
                                break -- Pasar al siguiente 'part' una vez encontrado el nombre
                            end
                        end
                    end
                end

                if #itemsToCollect > 0 then
                    --print("Kronos AutoCollect: Encontrados", #itemsToCollect, flagName)
                    for _, item in ipairs(itemsToCollect) do
                        if item and item.Parent then -- Doble check por si desaparece
                            local success = pcall(function()
                                if typeof(firetouchinterest) == "function" then
                                    firetouchinterest(hrp, item, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, item, 1)
                                else
                                    -- Fallback muy simple: intentar teleport corto si firetouchinterest no existe
                                    local originalCFrame = hrp.CFrame
                                    hrp.CFrame = item.CFrame
                                    task.wait(0.05)
                                    hrp.CFrame = originalCFrame
                                end
                            end)
                            if success then itemsCollected = itemsCollected + 1 end
                            task.wait(0.02) -- Pequeña pausa entre recolecciones
                        end
                        if not _G[enableFlag] then break end -- Detener si se desactiva mientras recolecta
                    end
                    --if itemsCollected > 0 then print("Kronos AutoCollect: Recolectados", itemsCollected, flagName) end
                end
            else
                print("Kronos AutoCollect " .. flagName .. ": Esperando HumanoidRootPart...")
            end
            task.wait(safeMode and 1.0 or 0.5) -- Esperar antes de la siguiente búsqueda
        end
        _G[threadVarName] = nil -- Limpiar referencia al terminar
        print("Kronos Hub: Auto Collect " .. flagName .. " detenido.")
    end)
end

function startAutoCollectCoins() collectNearbyItems({"Coin", "CoinContainer", "NinjitsuShard"}, "autoCollectCoins", "autoCoinsThread") end
function stopAutoCollectCoins() autoCollectCoins = false end

function startAutoCollectChi() collectNearbyItems({"Chi", "ChiContainer", "TrainingCrystal"}, "autoCollectChi", "autoChiThread") end
function stopAutoCollectChi() autoCollectChi = false end


function startAutoOpenChests()
     if autoOpenChestsThread then return end
     local chestEvent = getRemoteEvent("openChestRemote") or getRemoteEvent("OpenChest")

     if not chestEvent then
         sendNotification("Error Auto Chests", "No se encontró el evento para abrir cofres.", 3)
         autoOpenChests = false
         -- Actualizar UI si existe
         if KronosUI then
             local chestToggle = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Automation", true):FindFirstChild("AutoOpenChestsToggle", true)
             if chestToggle then chestToggle.Selected = false end
         end
         return
     end

     sendNotification("Auto Chests", "Apertura automática de cofres iniciada.", 2)
     autoOpenChests = true

     local chestTypes = { -- Lista más común, puede necesitar ajustes
         "Basic Chest", "Golden Chest", "Crystal Chest", "Enchanted Chest",
         "Mythical Chest", "Eternal Chest", "Volcano Chest", "Sahara Chest",
         "Thunder Chest", "Ancient Chest"
     }

     autoOpenChestsThread = task.spawn(function()
         while autoOpenChests do
             print("Kronos AutoChests: Intentando abrir cofres...")
             for _, chestType in ipairs(chestTypes) do
                 if not autoOpenChests then break end -- Salir si se desactiva

                 local success, result = pcall(function()
                     if chestEvent:IsA("RemoteFunction") then
                         return chestEvent:InvokeServer(chestType)
                     elseif chestEvent:IsA("RemoteEvent") then
                          chestEvent:FireServer(chestType)
                         return true -- Asumir éxito si es RemoteEvent
                     end
                     return false
                 end)

                 if not success then
                     warn("Kronos AutoChests: Falló el intento de abrir '" .. chestType .. "' (Puede ser normal si no está disponible)")
                     -- Podríamos intentar FireServer si InvokeServer falló y viceversa, pero puede ser redundante
                 -- else
                     -- print("Kronos AutoChests: Intento de abrir '" .. chestType .. "' enviado.")
                 end
                 task.wait(safeMode and 0.5 or 0.2) -- Pausa entre intentos de cofres
             end
             if autoOpenChests then
                 print("Kronos AutoChests: Ciclo completado, esperando...")
                 task.wait(safeMode and 60 or 30) -- Esperar antes de volver a intentar todos los cofres
             end
         end
         autoOpenChestsThread = nil
         print("Kronos Hub: Auto Open Chests detenido.")
     end)
end

function stopAutoOpenChests()
     autoOpenChests = false
end


function startAutoRebirth()
    if autoRebirthThread then return end
    local rebirthEvent = getRemoteEvent("rebirthEvent") or getRemoteEvent("Rebirth")

    if not rebirthEvent then
        sendNotification("Error Auto Rebirth", "No se encontró el evento de Rebirth.", 3)
        autoRebirth = false
         if KronosUI then
             local rebirthToggle = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Automation", true):FindFirstChild("AutoRebirthToggle", true)
             if rebirthToggle then rebirthToggle.Selected = false end
         end
        return
    end

    sendNotification("Auto Rebirth", "Auto Rebirth iniciado", 2)
    autoRebirth = true

    autoRebirthThread = task.spawn(function()
        while autoRebirth do
            print("Kronos AutoRebirth: Intentando Rebirth...")
            local success = pcall(function() rebirthEvent:FireServer() end)
            if not success then
                warn("Kronos AutoRebirth: Fallo al intentar Rebirth.")
            end
            local rebirthDelay = safeMode and 120 or 60 -- Intentar cada 1-2 minutos
            task.wait(rebirthDelay)
        end
        autoRebirthThread = nil
        print("Kronos Hub: Auto Rebirth detenido.")
    end)
end

function stopAutoRebirth()
    autoRebirth = false
end

function startAntiAfk()
    if antiAfkThread then return end

    sendNotification("Anti AFK", "Sistema Anti-AFK activado", 2)
    antiAfk = true

    antiAfkThread = task.spawn(function()
        local lastInteraction = tick()
        local idleThreshold = 15 * 60 -- 15 minutos (Roblox suele desconectar a los 20)

        while antiAfk do
            if tick() - lastInteraction > (idleThreshold - 30) then -- Actuar 30s antes del umbral
                print("Kronos Anti-AFK: Simulating activity...")
                pcall(function()
                    VirtualUser:CaptureController()
                    -- Simular un pequeño movimiento o salto
                    VirtualUser:SetKeyDown('0x20') -- Espacio (Saltar)
                    task.wait(0.1)
                    VirtualUser:SetKeyUp('0x20')
                    task.wait(0.2)
                    -- Simular un click derecho para rotar cámara
                    VirtualUser:ClickButton2(Vector2.new())
                    lastInteraction = tick()
                end)
            end
            task.wait(10) -- Revisar cada 10 segundos
        end

        -- Detectar interacción del usuario real para resetear el timer interno
        local inputConn = UserInputService.InputBegan:Connect(function()
            lastInteraction = tick()
        end)

        -- Esperar hasta que antiAfk sea false
        while antiAfk do task.wait(1) end

        inputConn:Disconnect() -- Limpiar conexión
        antiAfkThread = nil
        print("Kronos Hub: Anti AFK detenido.")
    end)
end


function stopAntiAfk()
    antiAfk = false
end

function startAutoUpgrade(upgradeType, threadVarName, eventName, itemFolder, allItemsFolder)
     if _G[threadVarName] then return end
     local buyEvent = getRemoteEvent(eventName or "BuyItemRemote") or getRemoteEvent("UpgradeStatRemote") -- Buscar ambos nombres

     if not buyEvent then
         sendNotification("Error Auto Upgrade", "No se encontró evento de compra/mejora para " .. upgradeType, 3)
         _G[upgradeType] = false -- Actualizar bandera global
         -- Actualizar UI si existe
         if KronosUI then
             local toggle = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Automation", true):FindFirstChild("AutoUpgrade".. upgradeType .."Toggle", true)
             if toggle then toggle.Selected = false end
         end
         return
     end

     sendNotification("Auto Upgrade", "Mejora automática de " .. upgradeType .. " iniciada", 2)
     _G["autoUpgrade" .. upgradeType] = true -- Establecer bandera global

     _G[threadVarName] = task.spawn(function()
         while _G["autoUpgrade" .. upgradeType] do
             print("Kronos AutoUpgrade: Intentando mejorar " .. upgradeType .. "...")
             local itemsToUpgrade = {}

             if itemFolder and allItemsFolder then -- Para Skills
                 local storage = getReplicatedStorageWithBackup()
                 local folder = storage and storage:FindFirstChild(itemFolder)
                 local allItems = folder and folder:FindFirstChild(allItemsFolder)
                 itemsToUpgrade = allItems and allItems:GetChildren() or {}
             else -- Para Stats
                 -- Asumir nombres comunes, esto puede necesitar ajuste específico del juego
                 itemsToUpgrade = {"Damage", "Speed", "Jump", "Ninjitsu", "ChiMultiplier"}
             end

             if #itemsToUpgrade == 0 then
                 warn("Kronos AutoUpgrade: No se encontraron " .. upgradeType .. " para mejorar.")
             else
                 for _, item in ipairs(itemsToUpgrade) do
                     if not _G["autoUpgrade" .. upgradeType] then break end

                     local itemName = (type(item) == "Instance") and item.Name or item
                     local success = pcall(function()
                         if itemFolder then -- Si es Skill/Belt/Weapon
                             buyEvent:FireServer(itemFolder, itemName)
                         else -- Si es Stat
                             buyEvent:FireServer(itemName) -- Asume que el evento solo necesita el nombre del stat
                         end
                     end)
                     -- No mostrar warning en fallo, es normal no poder comprar todo el tiempo
                     -- if not success then warn("Kronos AutoUpgrade: Fallo al intentar mejorar "..itemName) end
                     task.wait(safeMode and 0.3 or 0.15)
                 end
             end

             local upgradeDelay = safeMode and 20 or 10
             task.wait(upgradeDelay) -- Esperar antes del siguiente ciclo de mejoras
         end
         _G[threadVarName] = nil
         print("Kronos Hub: Auto Upgrade " .. upgradeType .. " detenido.")
     end)
end

function startAutoUpgradeSkills() startAutoUpgrade("Skills", "autoUpgradeSkillsThread", "BuyItemRemote", "Skill", "AllSkills") end
function stopAutoUpgradeSkills() autoUpgradeSkills = false end

function startAutoUpgradeStats() startAutoUpgrade("Stats", "autoUpgradeStatsThread", "UpgradeStatRemote") end -- No necesita carpetas
function stopAutoUpgradeStats() autoUpgradeStats = false end


function startFullAutomation()
    if fullAutoThread then return end

    fullAutomation = true
    sendNotification("Full Auto", "Automatización completa ACTIVADA", 3)

    -- Activar y Iniciar todas las funciones deseadas
    autoSwing = true; startAutoSwing()
    autoSell = true; startAutoSell()
    autoCollectCoins = true; startAutoCollectCoins()
    autoCollectChi = true; startAutoCollectChi()
    autoRebirth = true; startAutoRebirth()
    antiAfk = true; startAntiAfk()
    autoUpgradeSkills = true; startAutoUpgradeSkills()
    autoUpgradeStats = true; startAutoUpgradeStats()
    autoOpenChests = true; startAutoOpenChests()

     -- Actualizar UI (si existe)
     if KronosUI then
         local automationFrame = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Automation", true)
         if automationFrame then
             for _, child in ipairs(automationFrame:GetChildren()) do
                 if child:IsA("ToggleButton") then -- Asumiendo que usas un tipo ToggleButton
                     child.Selected = true
                 elseif child:IsA("Frame") and child:FindFirstChildWhichIsA("ToggleButton") then
                      child:FindFirstChildWhichIsA("ToggleButton").Selected = true
                 end
             end
              local fullAutoToggle = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Main", true):FindFirstChild("FullAutomationToggle", true)
              if fullAutoToggle then fullAutoToggle.Selected = true end
         end
     end


    -- Bucle de control simple para reiniciar si algo falla (opcional, las funciones ya tienen sus propios bucles)
    fullAutoThread = task.spawn(function()
        while fullAutomation do
            task.wait(60) -- Revisar cada minuto
            -- Opcionalmente, verificar si los threads (_G[threadVarName]) son nil y reiniciar
            -- if autoSwing and not autoSwingThread then print("FullAuto: Reiniciando AutoSwing"); startAutoSwing() end
            -- ... (hacer lo mismo para otros) ...
            -- Esto puede ser excesivo si las funciones son estables.
        end
        fullAutoThread = nil
        print("Kronos Hub: Control de Full Automation detenido.")
    end)
end

function stopFullAutomation()
    fullAutomation = false
    sendNotification("Full Auto", "Automatización completa DESACTIVADA", 3)

    -- Desactivar y detener todas las funciones
    stopAutoSwing()
    stopAutoSell()
    stopAutoCollectCoins()
    stopAutoCollectChi()
    stopAutoRebirth()
    stopAntiAfk()
    stopAutoUpgradeSkills()
    stopAutoUpgradeStats()
    stopAutoOpenChests()

    -- Actualizar UI (si existe)
     if KronosUI then
         local automationFrame = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Automation", true)
         if automationFrame then
             for _, child in ipairs(automationFrame:GetChildren()) do
                  if child:IsA("ToggleButton") then
                     child.Selected = false
                 elseif child:IsA("Frame") and child:FindFirstChildWhichIsA("ToggleButton") then
                      child:FindFirstChildWhichIsA("ToggleButton").Selected = false
                 end
             end
              local fullAutoToggle = KronosUI:FindFirstChild("MainFrame", true):FindFirstChild("TabFrame_Main", true):FindFirstChild("FullAutomationToggle", true)
              if fullAutoToggle then fullAutoToggle.Selected = false end
         end
     end
end

function TeleportPlayer(targetCframe)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        -- Añadir offset vertical y un pequeño offset aleatorio horizontal para variar
        local targetPosition = targetCframe.Position + Vector3.new(math.random(-1, 1)*0.5, 5, math.random(-1, 1)*0.5) -- Offset más alto y aleatorio
        local finalCFrame = CFrame.new(targetPosition) * (targetCframe - targetCframe.Position) -- Mantener orientación

        sendNotification("Teleport", "Iniciando teletransporte...", 1)

        -- Método 1: Tweening (más suave, potencialmente menos detectable)
        local tweenInfo = TweenInfo.new(
            safeMode and 0.8 or 0.4, -- Tiempo (un poco más lento)
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = finalCFrame})

        local success = pcall(function()
            tween:Play()
            tween.Completed:Wait() -- Esperar a que termine
        end)

        if success then
             -- Verificar si llegamos cerca del destino
             task.wait(0.1)
             if (hrp.Position - targetPosition).Magnitude < 15 then
                 sendNotification("Teleport", "Teletransporte completado.", 1)
                 return true
             else
                 warn("Kronos Teleport: Tween completado pero la posición final es incorrecta. Intentando TP directo.")
             end
        else
             warn("Kronos Teleport: Tween falló. Intentando TP directo.")
        end

        -- Método 2: Teletransporte directo (si Tween falla o no llega)
        local directSuccess = pcall(function()
            hrp.CFrame = finalCFrame
        end)

        if directSuccess then
            task.wait(0.1)
            if (hrp.Position - targetPosition).Magnitude < 15 then
                 sendNotification("Teleport", "Teletransporte directo completado.", 1)
                 return true
             else
                  sendNotification("Error Teleport", "Teletransporte directo falló o posición incorrecta.", 2)
                  return false
            end
        else
             sendNotification("Error Teleport", "Fallaron ambos métodos de teletransporte.", 2)
             return false
        end

    else
        sendNotification("Error Teleport", "No se encontró HumanoidRootPart.", 2)
        return false
    end
end

function setCharacterProperty(property, value)
     local character = LocalPlayer.Character
     local humanoid = character and character:FindFirstChildOfClass("Humanoid")
     if humanoid then
         local success = pcall(function()
             humanoid[property] = tonumber(value) or humanoid[property] -- Asegurarse que es número
         end)
         if success then
             sendNotification("Ajuste", property .. " ajustado a " .. tostring(value), 1)
         else
             sendNotification("Error Ajuste", "No se pudo ajustar " .. property, 2)
         end
     else
         -- sendNotification("Error Ajuste", "No se encontró Humanoide.", 2)
     end
end

function applyWalkSpeed()
    setCharacterProperty("WalkSpeed", walkSpeedValue)
end

function applyJumpPower()
     setCharacterProperty("JumpPower", jumpPowerValue)
end

-- === Definición de Islas para Teleport (Revisar si CFrames son correctos para la versión actual del juego) ===
local islands = {
    ["Training Islands"] = {
        ["Starter Island"] = CFrame.new(25, 3, 75),
        ["Astral Island"] = CFrame.new(237, 2013, 335),
        ["Space Island"] = CFrame.new(237, 4013, 335),
        ["Tundra Island"] = CFrame.new(237, 8013, 335),
        ["Eternal Island"] = CFrame.new(237, 13013, 335),
        ["Sandstorm Island"] = CFrame.new(237, 17013, 335),
        ["Thunderstorm Island"] = CFrame.new(237, 24013, 335),
        ["Ancient Inferno Island"] = CFrame.new(237, 31013, 335),
        ["Midnight Shadow Island"] = CFrame.new(237, 39013, 335),
        ["Mythical Souls Island"] = CFrame.new(237, 46013, 335),
        ["Winter Wonder Island"] = CFrame.new(237, 55013, 335),
        ["Golden Master Island"] = CFrame.new(237, 62013, 335),
        ["Dragon Legend Island"] = CFrame.new(237, 70013, 335),
        ["Cybernetic Legends Island"] = CFrame.new(237, 74013, 335),
        ["Skystorm Ultraus Island"] = CFrame.new(237, 80013, 335),
        ["Chaos Legends Island"] = CFrame.new(237, 87013, 335),
        ["Soul Fusion Island"] = CFrame.new(237, 92013, 335),
        ["Dark Elements Island"] = CFrame.new(237, 98013, 335),
        ["Inner Peace Island"] = CFrame.new(237, 104013, 335)
    },
    ["Special Areas"] = {
        ["Sell Area"] = function() -- Usar función para encontrar dinámicamente
            local sellArea = Workspace:FindFirstChild("sellAreaCircle", true) or Workspace:FindFirstChild("sellAreaCircles", true) or Workspace:FindFirstChild("SellPart", true)
            return sellArea and sellArea.CFrame or CFrame.new(70, 3, 40) -- Fallback CFrame
        end,
        -- ["Boss Arena"] = CFrame.new(200, 3, -50), -- Ajustar si es necesario
        -- ["PVP Arena"] = CFrame.new(-50, 3, 100) -- Ajustar si es necesario
    }
}

-- === Creación de la UI Mejorada ===
if KronosUI then KronosUI:Destroy() end -- Destruir UI anterior si existe

KronosUI = Instance.new("ScreenGui")
KronosUI.Name = "KronosHubUI_"..math.random(1000,9999) -- Nombre aleatorio para dificultar detección
KronosUI.ResetOnSpawn = false
KronosUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KronosUI.Parent = CoreGui -- Usar CoreGui

-- Estilo visual
local colors = {
    background = Color3.fromRGB(28, 28, 38),
    backgroundSecondary = Color3.fromRGB(35, 35, 48),
    backgroundLight = Color3.fromRGB(45, 45, 60),
    accent = Color3.fromRGB(110, 90, 255),
    accentDark = Color3.fromRGB(80, 60, 210),
    text = Color3.fromRGB(230, 230, 245),
    textDim = Color3.fromRGB(180, 180, 200),
    positive = Color3.fromRGB(80, 220, 130),
    negative = Color3.fromRGB(220, 80, 80),
    warning = Color3.fromRGB(220, 170, 80),
    highlight = Color3.fromRGB(120, 120, 255)
}

-- Función para crear elementos UI comunes
local function CreateElement(elementType, properties)
    local element = Instance.new(elementType)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

-- Función para crear un botón de alternancia (toggle)
local function CreateToggleButton(parent, text, position, size, callback)
     local Frame = CreateElement("Frame", {
         Name = text:gsub("%s+", "") .. "ToggleFrame", -- Remover espacios para nombre
         Parent = parent,
         BackgroundColor3 = colors.backgroundLight,
         BorderColor3 = colors.accentDark,
         BorderSizePixel = 1,
         Position = position,
         Size = size,
         ClipsDescendants = true,
     })
     local Corner = CreateElement("UICorner", { CornerRadius = UDim.new(0, 5), Parent = Frame })

     local ToggleButton = CreateElement("TextButton", {
         Name = text:gsub("%s+", "") .. "Toggle", -- Nombre del botón interno
         Parent = Frame,
         Size = UDim2.new(1, 0, 1, 0),
         BackgroundColor3 = colors.negative, -- Rojo por defecto (apagado)
         BorderColor3 = colors.accent,
         BorderSizePixel = 0,
         Font = Enum.Font.GothamSemibold,
         Text = text,
         TextColor3 = colors.text,
         TextSize = 14,
         TextWrapped = true,
         AutoButtonColor = false,
         SelectionImageObject = nil, -- Evitar highlight amarillo por defecto
         Modal = false,
         [RandomString(8)] = RandomString(16) -- Propiedad basura
     })
     local ToggleCorner = CreateElement("UICorner", { CornerRadius = UDim.new(0, 5), Parent = ToggleButton })

    ToggleButton.Selected = false -- Estado inicial

    ToggleButton.MouseButton1Click:Connect(function()
         ToggleButton.Selected = not ToggleButton.Selected
         ToggleButton.BackgroundColor3 = ToggleButton.Selected and colors.positive or colors.negative
         if callback then
             callback(ToggleButton.Selected)
         end
     end)

    -- Hover effect
     ToggleButton.MouseEnter:Connect(function() ToggleButton.BackgroundTransparency = 0.2 end)
     ToggleButton.MouseLeave:Connect(function() ToggleButton.BackgroundTransparency = 0 end)

     return ToggleButton -- Devolver el botón interno para posible control externo
end

-- Crear la ventana principal
local MainFrame = CreateElement("Frame", {
    Name = "MainFrame",
    Parent = KronosUI,
    Size = UDim2.new(0, 500, 0, 350), -- Tamaño inicial
    Position = UDim2.new(0.5, -250, 0.5, -175), -- Centrado
    BackgroundColor3 = colors.background,
    BorderColor3 = colors.accent,
    BorderSizePixel = 2,
    Active = true, -- Para Draggable
    Draggable = true,
    ClipsDescendants = true,
})
local Corner = CreateElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })

-- Título y botón de cierre
local TitleBar = CreateElement("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
})
local TitleLabel = CreateElement("TextLabel", {
    Name = "TitleLabel",
    Parent = TitleBar,
    Size = UDim2.new(1, -30, 1, 0), -- Dejar espacio para botón de cierre
    BackgroundColor3 = colors.accent,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBlack,
    Text = "Kronos Hub | Ninja Legends",
    TextColor3 = colors.text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    Position = UDim2.fromOffset(10, 0),
})
local CloseButton = CreateElement("TextButton", {
    Name = "CloseButton",
    Parent = TitleBar,
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -28, 0.5, -12.5),
    BackgroundColor3 = colors.negative,
    BorderSizePixel = 1,
    BorderColor3 = colors.text,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextColor3 = colors.text,
    TextSize = 14,
})
local CloseCorner = CreateElement("UICorner", { CornerRadius = UDim.new(0, 4), Parent = CloseButton })
CloseButton.MouseButton1Click:Connect(function() KronosUI:Destroy() end)

-- Marco para las pestañas
local TabFrameContainer = CreateElement("Frame", {
    Name = "TabFrameContainer",
    Parent = MainFrame,
    Size = UDim2.new(1, -10, 1, -40), -- Ajustar tamaño y posición
    Position = UDim2.new(0.5, 0, 1, -5),
    AnchorPoint = Vector2.new(0.5, 1),
    BackgroundColor3 = colors.backgroundSecondary,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
local TabCorner = CreateElement("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabFrameContainer })


-- Botones de Pestaña
local TabButtonsFrame = CreateElement("Frame", {
    Name = "TabButtonsFrame",
    Parent = MainFrame,
    Size = UDim2.new(1, -10, 0, 30),
    Position = UDim2.new(0.5, 0, 0, 35), -- Debajo del título
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

local tabData = {"Main", "Automation", "Teleports", "Player", "Settings"}
local tabButtons = {}
local tabFrames = {}
local activeTab = nil

-- Crear marcos para cada pestaña dentro del contenedor
for i, tabName in ipairs(tabData) do
    local tabFrame = CreateElement("ScrollingFrame", { -- Usar ScrollingFrame por si el contenido es mucho
        Name = "TabFrame_" .. tabName,
        Parent = TabFrameContainer,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false, -- Ocultar por defecto
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0), -- Se ajustará con UIListLayout
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = colors.accent,
    })
     local listLayout = CreateElement("UIListLayout", {
        Parent = tabFrame,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        FillDirection = Enum.FillDirection.Vertical,
    })
     local padding = CreateElement("UIPadding", {
        Parent = tabFrame,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })
    tabFrames[tabName] = tabFrame
end

-- Crear botones de pestaña
local tabButtonLayout = CreateElement("UIListLayout", {
    Parent = TabButtonsFrame,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5),
})

for i, tabName in ipairs(tabData) do
    local tabButton = CreateElement("TextButton", {
        Name = "TabButton_" .. tabName,
        Parent = TabButtonsFrame,
        Size = UDim2.new(0, 80, 1, 0),
        BackgroundColor3 = colors.backgroundLight,
        BorderColor3 = colors.accent,
        BorderSizePixel = 1,
        Font = Enum.Font.GothamSemibold,
        Text = tabName,
        TextColor3 = colors.textDim,
        TextSize = 14,
        LayoutOrder = i,
        AutoButtonColor = false,
    })
    local buttonCorner = CreateElement("UICorner", { CornerRadius = UDim.new(0, 4), Parent = tabButton })

    tabButton.MouseButton1Click:Connect(function()
        if activeTab == tabName then return end -- No hacer nada si ya está activa

        -- Desactivar botón y frame anterior
        if activeTab then
            tabButtons[activeTab].BackgroundColor3 = colors.backgroundLight
            tabButtons[activeTab].TextColor3 = colors.textDim
            tabFrames[activeTab].Visible = false
        end

        -- Activar nuevo botón y frame
        tabButton.BackgroundColor3 = colors.accent
        tabButton.TextColor3 = colors.text
        tabFrames[tabName].Visible = true
        activeTab = tabName
    end)
    tabButtons[tabName] = tabButton

-- === Poblar Pestañas ===

-- Pestaña Main
local mainTab = tabFrames["Main"]
local fullAutoToggle = CreateToggleButton(mainTab, "Full Automation", UDim2.fromScale(0.5, 0.1), UDim2.new(0.8, 0, 0, 35), function(enabled)
    if enabled then startFullAutomation() else stopFullAutomation() end
end)
fullAutoToggle.LayoutOrder = 1
fullAutoToggle.Parent.Position = UDim2.new(0.5, 0, 0, 0) -- Ajustar posición inicial
fullAutoToggle.Parent.AnchorPoint = Vector2.new(0.5, 0)

local statusLabel = CreateElement("TextLabel", {
    Name = "StatusLabel", Parent = mainTab, LayoutOrder = 2,
    Size = UDim2.new(0.9, 0, 0, 60), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, TextColor3 = colors.textDim, TextSize = 13,
    Text = "Welcome to Kronos Hub!\nActivate Full Automation or choose specific features in the Automation tab.\nUse responsibly.",
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top,
})

local unlockFrame = CreateElement("Frame", {
    Name = "UnlockFrame", Parent = mainTab, LayoutOrder = 3,
    Size = UDim2.new(0.9, 0, 0, 80), BackgroundTransparency = 1,
})
local unlockLayout = CreateElement("UIGridLayout", {
    Parent = unlockFrame, CellPadding = UDim2.fromOffset(5, 5), CellSize = UDim2.new(0, 130, 0, 30),
    HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center,
    StartCorner = Enum.StartCorner.TopLeft,
})
local unlockTitle = CreateElement("TextLabel", {
    Name = "UnlockTitle", Parent = unlockFrame, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, ZIndex=2,
    Font = Enum.Font.GothamBold, Text = "Unlockers", TextColor3 = colors.text, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Center,
})
local unlockSwordsBtn = CreateElement("TextButton", { Name = "UnlockSwords", Parent = unlockFrame, Text = "Unlock Swords", BackgroundColor3 = colors.accentDark, TextColor3 = colors.text, Font = Enum.Font.Gotham, TextSize = 13,})
local unlockBeltsBtn = CreateElement("TextButton", { Name = "UnlockBelts", Parent = unlockFrame, Text = "Unlock Belts", BackgroundColor3 = colors.accentDark, TextColor3 = colors.text, Font = Enum.Font.Gotham, TextSize = 13,})
local unlockSkillsBtn = CreateElement("TextButton", { Name = "UnlockSkills", Parent = unlockFrame, Text = "Unlock Skills", BackgroundColor3 = colors.accentDark, TextColor3 = colors.text, Font = Enum.Font.Gotham, TextSize = 13,})
local unlockChestBtn = CreateElement("TextButton", { Name = "UnlockChests", Parent = unlockFrame, Text = "Farm Chest Chi", BackgroundColor3 = colors.warning, TextColor3 = colors.text, Font = Enum.Font.Gotham, TextSize = 13,})

CreateElement("UICorner", {Parent=unlockSwordsBtn, CornerRadius=UDim.new(0,4)})
CreateElement("UICorner", {Parent=unlockBeltsBtn, CornerRadius=UDim.new(0,4)})
CreateElement("UICorner", {Parent=unlockSkillsBtn, CornerRadius=UDim.new(0,4)})
CreateElement("UICorner", {Parent=unlockChestBtn, CornerRadius=UDim.new(0,4)})

unlockSwordsBtn.MouseButton1Click:Connect(UnlockAllSwords)
unlockBeltsBtn.MouseButton1Click:Connect(UnlockAllBelts)
unlockSkillsBtn.MouseButton1Click:Connect(UnlockAllSkills)
-- unlockChestBtn.MouseButton1Click:Connect(ChestFarmer) -- ChestFarmer ahora es un toggle en Automation

-- Pestaña Automation
local automationTab = tabFrames["Automation"]
local autoGrid = CreateElement("UIGridLayout", { -- Usar Grid para organizar toggles
    Parent = automationTab,
    CellPadding = UDim2.fromOffset(8, 8),
    CellSize = UDim2.new(0, 140, 0, 35), -- Tamaño de cada toggle
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder,
    StartCorner = Enum.StartCorner.TopLeft,
})

CreateToggleButton(automationTab, "Auto Swing", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoSwing() else stopAutoSwing() end end).Parent.LayoutOrder = 1
CreateToggleButton(automationTab, "Auto Sell", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoSell() else stopAutoSell() end end).Parent.LayoutOrder = 2
CreateToggleButton(automationTab, "Auto Coins", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoCollectCoins() else stopAutoCollectCoins() end end).Parent.LayoutOrder = 3
CreateToggleButton(automationTab, "Auto Chi", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoCollectChi() else stopAutoCollectChi() end end).Parent.LayoutOrder = 4
CreateToggleButton(automationTab, "Auto Rebirth", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoRebirth() else stopAutoRebirth() end end).Parent.LayoutOrder = 5
CreateToggleButton(automationTab, "Auto Open Chests", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoOpenChests() else stopAutoOpenChests() end end).Parent.LayoutOrder = 6
CreateToggleButton(automationTab, "Auto Upgrade Skills", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoUpgradeSkills() else stopAutoUpgradeSkills() end end).Parent.LayoutOrder = 7
CreateToggleButton(automationTab, "Auto Upgrade Stats", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAutoUpgradeStats() else stopAutoUpgradeStats() end end).Parent.LayoutOrder = 8
CreateToggleButton(automationTab, "Anti AFK", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(e) if e then startAntiAfk() else stopAntiAfk() end end).Parent.LayoutOrder = 9


-- Pestaña Teleports
local teleportsTab = tabFrames["Teleports"]
local islandCategoryDropdown = CreateElement("DropDown", { -- Dropdown para categorías
    Name = "IslandCategoryDropdown", Parent = teleportsTab, LayoutOrder = 1,
    Size = UDim2.new(0.8, 0, 0, 30), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = colors.backgroundLight, BorderColor3 = colors.accentDark, TextColor3 = colors.text, Font = Enum.Font.GothamSemibold,
})
local islandDropdown = CreateElement("DropDown", { -- Dropdown para islas específicas
    Name = "IslandDropdown", Parent = teleportsTab, LayoutOrder = 2,
    Size = UDim2.new(0.8, 0, 0, 30), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = colors.backgroundLight, BorderColor3 = colors.accentDark, TextColor3 = colors.text, Font = Enum.Font.GothamSemibold,
})
local teleportButton = CreateElement("TextButton", {
    Name = "TeleportButton", Parent = teleportsTab, LayoutOrder = 3,
    Size = UDim2.new(0.5, 0, 0, 35), Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = colors.accent, Text = "Teleport", TextColor3 = colors.text, Font = Enum.Font.GothamBold, TextSize = 16,
})
CreateElement("UICorner", {Parent=teleportButton, CornerRadius=UDim.new(0,5)})

local categoryList = {}
for category, _ in pairs(islands) do table.insert(categoryList, category) end
islandCategoryDropdown:SetOptions(categoryList)

local function updateIslandDropdown()
    local selectedCategory = islandCategoryDropdown:GetSelectedOption()
    if selectedCategory and islands[selectedCategory] then
        local islandList = {}
        for islandName, _ in pairs(islands[selectedCategory]) do table.insert(islandList, islandName) end
        islandDropdown:SetOptions(islandList)
         if #islandList > 0 then islandDropdown:SetSelectedOption(islandList[1]) end -- Seleccionar la primera por defecto
    else
        islandDropdown:ClearOptions()
    end
end

islandCategoryDropdown.SelectionChanged:Connect(updateIslandDropdown)
updateIslandDropdown() -- Llamar una vez para poblar inicialmente

teleportButton.MouseButton1Click:Connect(function()
    local category = islandCategoryDropdown:GetSelectedOption()
    local islandName = islandDropdown:GetSelectedOption()
    if category and islandName and islands[category] and islands[category][islandName] then
        local target = islands[category][islandName]
        if type(target) == "function" then
            target = target() -- Ejecutar función si es necesario (ej. Sell Area)
        end
        if typeof(target) == "CFrame" then
            TeleportPlayer(target)
        else
             sendNotification("Error Teleport", "Ubicación inválida para: " .. islandName, 3)
        end
    else
        sendNotification("Error Teleport", "Selecciona una categoría e isla válidas.", 3)
    end
end)

-- Pestaña Player
local playerTab = tabFrames["Player"]
-- Asegurarse de que el Layout esté primero y los elementos después
local playerGrid = CreateElement("UIGridLayout", {
    Parent = playerTab, -- El Layout es hijo del ScrollingFrame (playerTab)
    Name = "PlayerGridLayout", -- Darle un nombre por claridad
    CellPadding = UDim2.fromOffset(10, 10),
    CellSize = UDim2.new(0.4, 0, 0, 55), -- Aumentar un poco el alto para el label
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder, -- El Grid usa LayoutOrder para sus hijos
    StartCorner = Enum.StartCorner.TopLeft,
})

local function CreateSlider(parent, layoutOrder, label, minVal, maxVal, initialVal, callback)
    -- El Frame del slider será hijo del 'parent' (playerTab) y será ordenado por 'playerGrid'
    local sliderFrame = CreateElement("Frame", {
        Name = label.."Frame",
        Parent = parent, -- Padre es playerTab
        Size = UDim2.fromScale(1,1), -- El Grid definirá el tamaño real via CellSize
        BackgroundTransparency=1,
        LayoutOrder = layoutOrder -- <-- Establecer LayoutOrder aquí
    })
    local sliderLabel = CreateElement("TextLabel", {
        Name = label.."Label",
        Parent = sliderFrame,
        Size = UDim2.new(1,0,0,20),
        BackgroundTransparency=1,
        Text=label..": "..initialVal,
        TextColor3=colors.text,
        Font=Enum.Font.Gotham, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top -- Alinear arriba
    })
    local slider = CreateElement("Slider", {
        Name = label.."Slider",
        Parent = sliderFrame,
        Size = UDim2.new(1,0,0,20),
        Position=UDim2.fromOffset(0, 25), -- Posición relativa dentro del frame
        MinValue=minVal, MaxValue=maxVal, Value=initialVal,
        BackgroundColor3=colors.backgroundLight, BarColor3=colors.accent,
    })

    local currentValue = initialVal -- Guardar valor actual para evitar spam en callback

    slider.ValueChanged:Connect(function(value)
        local roundedValue = math.floor(value + 0.5)
        sliderLabel.Text = label..": "..roundedValue
        currentValue = roundedValue -- Actualizar valor guardado
    end)

    -- Aplicar el cambio solo cuando se deja de mover el slider
    slider.MouseButton1Up:Connect(function()
        if callback then
            callback(currentValue) -- Usar el último valor redondeado
        end
    end)
    slider.FocusLost:Connect(function(enterPressed) -- También aplicar si se presiona Enter
        if enterPressed and callback then
             callback(currentValue)
        end
    end)

    return sliderFrame -- Devolver el Frame contenedor
end

-- Crear los sliders y asignarles LayoutOrder
local wsSliderFrame = CreateSlider(playerTab, 1, "WalkSpeed", 16, 200, walkSpeedValue, function(val) walkSpeedValue = val; applyWalkSpeed() end)
local jpSliderFrame = CreateSlider(playerTab, 2, "JumpPower", 50, 300, jumpPowerValue, function(val) jumpPowerValue = val; applyJumpPower() end)

-- Aplicar valores iniciales al cargar
applyWalkSpeed()
applyJumpPower()

-- Conectar a cambios en el humanoide para actualizar sliders si algo externo los cambia
local walkSpeedConnection = nil
local jumpPowerConnection = nil

local function onHumanoidChanged(property)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if property == "WalkSpeed" and wsSliderFrame then
            local slider = wsSliderFrame:FindFirstChild("WalkSpeedSlider")
            local label = wsSliderFrame:FindFirstChild("WalkSpeedLabel")
            if slider and slider.Value ~= hum.WalkSpeed then
                slider.Value = hum.WalkSpeed
                if label then label.Text = "WalkSpeed: "..math.floor(hum.WalkSpeed + 0.5) end
                walkSpeedValue = hum.WalkSpeed -- Actualizar variable global también
            end
        elseif property == "JumpPower" and jpSliderFrame then
            local slider = jpSliderFrame:FindFirstChild("JumpPowerSlider")
            local label = jpSliderFrame:FindFirstChild("JumpPowerLabel")
            if slider and slider.Value ~= hum.JumpPower then
                slider.Value = hum.JumpPower
                 if label then label.Text = "JumpPower: "..math.floor(hum.JumpPower + 0.5) end
                jumpPowerValue = hum.JumpPower -- Actualizar variable global también
            end
        end
    end
end

local function setupHumanoidConnections()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
        if jumpPowerConnection then jumpPowerConnection:Disconnect(); jumpPowerConnection = nil end
        walkSpeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function() onHumanoidChanged("WalkSpeed") end)
        jumpPowerConnection = hum:GetPropertyChangedSignal("JumpPower"):Connect(function() onHumanoidChanged("JumpPower") end)
        onHumanoidChanged("WalkSpeed") -- Actualizar al inicio
        onHumanoidChanged("JumpPower") -- Actualizar al inicio
    else
         -- Si no hay humanoide, desconectar listeners previos para evitar errores si se reconectan luego
         if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
         if jumpPowerConnection then jumpPowerConnection:Disconnect(); jumpPowerConnection = nil end
    end
end
LocalPlayer.CharacterAdded:Connect(setupHumanoidConnections)
LocalPlayer.CharacterRemoving:Connect(function() -- Desconectar cuando el personaje se va
    if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
    if jumpPowerConnection then jumpPowerConnection:Disconnect(); jumpPowerConnection = nil end
end)
setupHumanoidConnections() -- Llamar una vez por si el personaje ya existe
-- Aplicar valores iniciales al cargar
applyWalkSpeed()
applyJumpPower()

-- Conectar a cambios en el humanoide para actualizar sliders si algo externo los cambia
local function onHumanoidChanged(property)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if property == "WalkSpeed" and wsSlider then
            local slider = wsSlider:FindFirstChild("WalkSpeedSlider")
            if slider and slider.Value ~= hum.WalkSpeed then
                slider.Value = hum.WalkSpeed
                walkSpeedValue = hum.WalkSpeed -- Actualizar variable global también
            end
        elseif property == "JumpPower" and jpSlider then
             local slider = jpSlider:FindFirstChild("JumpPowerSlider")
            if slider and slider.Value ~= hum.JumpPower then
                slider.Value = hum.JumpPower
                jumpPowerValue = hum.JumpPower -- Actualizar variable global también
            end
        end
    end
end

if walkSpeedConnection then walkSpeedConnection:Disconnect() end
if jumpPowerConnection then jumpPowerConnection:Disconnect() end

local function setupHumanoidConnections()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if walkSpeedConnection then walkSpeedConnection:Disconnect() end
        if jumpPowerConnection then jumpPowerConnection:Disconnect() end
        walkSpeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function() onHumanoidChanged("WalkSpeed") end)
        jumpPowerConnection = hum:GetPropertyChangedSignal("JumpPower"):Connect(function() onHumanoidChanged("JumpPower") end)
        onHumanoidChanged("WalkSpeed") -- Actualizar al inicio
        onHumanoidChanged("JumpPower") -- Actualizar al inicio
    end
end
LocalPlayer.CharacterAdded:Connect(setupHumanoidConnections)
setupHumanoidConnections() -- Llamar una vez por si el personaje ya existe


-- Pestaña Settings
local settingsTab = tabFrames["Settings"]
local settingsGrid = CreateElement("UIGridLayout", {
    Parent = settingsTab, CellPadding = UDim2.fromOffset(8, 8), CellSize = UDim2.new(0.8, 0, 0, 35),
    HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top,
})

local safeModeToggle = CreateToggleButton(settingsTab, "Safe Mode (Slower, Safer)", UDim2.fromScale(0,0), UDim2.fromScale(0,0), function(enabled)
    safeMode = enabled
    sendNotification("Settings", "Safe Mode " .. (enabled and "Enabled" or "Disabled"), 2)
end)
safeModeToggle.Parent.LayoutOrder = 1
safeModeToggle.Selected = safeMode -- Establecer estado inicial
safeModeToggle.BackgroundColor3 = safeMode and colors.positive or colors.negative -- Actualizar color inicial

local creditsLabel = CreateElement("TextLabel", {
    Name = "CreditsLabel", Parent = settingsTab, LayoutOrder = 2,
    Size = UDim2.new(0.9, 0, 0, 80), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, TextColor3 = colors.textDim, TextSize = 13,
    Text = "Kronos Hub Script\nOriginal by Kronos, Enhanced by IA.\nUse responsibly. No guarantees against bans.",
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center,
})


-- === (Código anterior a esto) ===

-- Ajustar CanvasSize de los ScrollingFrames basado en el tamaño del contenido del Layout
local function updateCanvasSize(tabFrame)
    if not tabFrame or not tabFrame:IsA("ScrollingFrame") then
        -- warn("Kronos Hub: updateCanvasSize llamado con un tabFrame inválido:", tabFrame)
        return
    end

    -- Busca cualquier tipo de layout relevante dentro del tabFrame
    local layout = tabFrame:FindFirstChildOfClass("UIListLayout")
                 or tabFrame:FindFirstChildOfClass("UIGridLayout")
                 or tabFrame:FindFirstChildOfClass("UITableLayout") -- Añadir por si acaso

    if layout then
        -- Usar pcall por si AbsoluteContentSize es inválido temporalmente o da error
        local success, result = pcall(function()
            -- Esperar un frame puede ayudar a que el tamaño se calcule correctamente
            -- task.wait() -- Descomentar esto si sigues teniendo problemas de tamaño incorrecto
            local newY = layout.AbsoluteContentSize.Y
            if typeof(newY) == "number" then
                 tabFrame.CanvasSize = UDim2.new(0, 0, 0, newY + 25) -- Añadir padding extra (25)
                 -- print("Updated CanvasSize for", tabFrame.Name, "to", newY + 25) -- Debug print
            else
                 warn("Kronos Hub: AbsoluteContentSize.Y no es un número para layout en", tabFrame.Name)
            end
        end)
        if not success then
            warn("Kronos Hub: Error al actualizar CanvasSize para", tabFrame.Name, "-", result)
        end
    else
        -- Si no hay layout, quizás el tamaño debería ser basado en hijos directos (más complejo, omitido por ahora)
        -- warn("Kronos Hub: No layout found in", tabFrame.Name, "to update CanvasSize.")
        -- Podríamos establecer un tamaño por defecto o basado en UILayoutUtil si estuviera disponible
         -- pcall(function() tabFrame.CanvasSize = UDim2.new(0,0,0, 300) end) -- Tamaño fallback muy simple
    end
end

-- Conectar la actualización a los cambios en los layouts y ejecutar una vez al inicio
for tabName, frame in pairs(tabFrames) do
    -- Verificar que 'frame' sea un ScrollingFrame válido antes de continuar
    if not frame or not frame:IsA("ScrollingFrame") then
         warn("Kronos Hub: Elemento inválido encontrado en tabFrames para la clave:", tabName)
         continue -- Saltar esta iteración si frame no es válido
    end

    local layout = frame:FindFirstChildOfClass("UIListLayout")
                 or frame:FindFirstChildOfClass("UIGridLayout")
                 or frame:FindFirstChildOfClass("UITableLayout")

    if layout then
        -- Conectar al evento Changed del layout encontrado
        local connection = layout.Changed:Connect(function()
            -- Llamar a updateCanvasSize para el frame específico de esta iteración ('frame' es capturado por la clausura)
            updateCanvasSize(frame)
        end)
        -- Podrías guardar 'connection' en un atributo del frame si necesitas desconectarlo después
        -- frame:SetAttribute("LayoutUpdateConnection", connection)

        -- Llamar una vez inicialmente después de un pequeño delay para dar tiempo a que la UI se renderice
        task.delay(0.2, function()
            if frame and frame.Parent then -- Re-verificar que el frame aún exista
                updateCanvasSize(frame)
            end
        end)
    else
        warn("Kronos Hub: No se encontró layout en", frame.Name, "para conectar el evento Changed o para la actualización inicial de CanvasSize.")
        -- Aún así, intentar una actualización inicial por si acaso, aunque sin layout no hará mucho
         task.delay(0.2, function()
            if frame and frame.Parent then
                updateCanvasSize(frame)
            end
        end)
    end
end

-- === Limpieza al quitar el script ===
-- (El resto del código sigue aquí...)
-- === Limpieza al quitar el script ===
KronosUI.Destroying:Connect(function()
    print("Kronos Hub: Cleaning up...")
    -- Detener todos los bucles
    stopFullAutomation() -- Esto detiene la mayoría
    -- Asegurarse de que los hilos específicos se detengan si FullAuto no estaba activo
    autoSwing = false; autoSell = false; autoCollectCoins = false; autoCollectChi = false;
    autoRebirth = false; antiAfk = false; autoUpgradeSkills = false; autoUpgradeStats = false; autoOpenChests = false;

     -- Desconectar señales
     if walkSpeedConnection then walkSpeedConnection:Disconnect() end
     if jumpPowerConnection then jumpPowerConnection:Disconnect() end

    -- Restaurar velocidad/salto a valores por defecto del juego (opcional)
    -- setCharacterProperty("WalkSpeed", 16)
    -- setCharacterProperty("JumpPower", 50)

    print("Kronos Hub: Cleanup complete.")
end)

sendNotification("Kronos Hub", "Script cargado y UI inicializada.", 4)
