--[[
$$\      $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\    $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/  
                                                             
]]--

-- KRONOS SCRIPT: NINJA LEGENDS
-- Adaptado para Orion UI Library
-- Version 2.0 (Orion Adapt)

local function printBanner()
    print([[
$$\      $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\    $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/  
                                                             
KRONOS SCRIPT: NINJA LEGENDS - LA ROMPE TODA (Orion Edition v2.0)
    ]])
end

-- Ejecutamos el banner al inicio
printBanner()

-- Cargar la biblioteca Orion UI
-- Asegúrate de que esta URL sea la correcta y esté activa para Orion
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Crear la ventana principal con Orion UI
local Window = OrionLib:MakeWindow({
    Name = "Kronos Hub (Orion)", 
    HidePremium = true, -- Oculta opciones premium si no las usas
    SaveConfig = true, -- Guarda la configuración de los toggles/sliders
    ConfigFolder = "KronosOrionConfig" -- Nombre de la carpeta para guardar la configuración
})

-- Variables globales de estado
local autoSwing = false
local autoSell = false

-- Referencias a servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Crear las Tabs usando MakeTab en el objeto Window
-- Puedes añadir iconos si quieres (opcional)
local FarmingTab = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483345998", PremiumOnly = false}) 
local TeleportTab = Window:MakeTab({Name = "Teleports", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local UnlockTab = Window:MakeTab({Name = "Desbloqueos", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscTab = Window:MakeTab({Name = "Misceláneos", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- === Funciones de lógica del juego (sin cambios) ===
function UnlockAllSwords()
    local swords = ReplicatedStorage.Weapon.AllWeapons:GetChildren()
    for _, sword in pairs(swords) do
        ReplicatedStorage.rEvents.BuyItemRemote:FireServer("Weapon", sword.Name)
        task.wait(0.1) 
    end
    print("Kronos Hub: Todas las espadas desbloqueadas.")
end

function UnlockAllBelts()
    local belts = ReplicatedStorage.Belt.AllBelts:GetChildren()
    for _, belt in pairs(belts) do
        ReplicatedStorage.rEvents.BuyItemRemote:FireServer("Belt", belt.Name)
        task.wait(0.1)
    end
    print("Kronos Hub: Todos los cinturones desbloqueados.")
end

function UnlockAllSkills()
    local skills = ReplicatedStorage.Skill.AllSkills:GetChildren()
    for _, skill in pairs(skills) do
        ReplicatedStorage.rEvents.BuyItemRemote:FireServer("Skill", skill.Name)
        task.wait(0.1)
    end
    print("Kronos Hub: Todas las habilidades desbloqueadas.")
end

function startAutoSwing()
    local swingEvent = ReplicatedStorage.rEvents:FindFirstChild("swingKatanaEvent")
    if not swingEvent then
        print("Kronos Hub Error: No se encontró swingKatanaEvent")
        autoSwing = false 
        -- Podrías añadir aquí una forma de desactivar el toggle en la UI si falla
        return
    end
    
    task.spawn(function()
        while autoSwing do
            swingEvent:FireServer()
            task.wait(0.05) 
        end
    end)
end

function startAutoSell()
    local sellCircle = Workspace:FindFirstChild("sellAreaCircles", true) and Workspace.sellAreaCircles:FindFirstChild("sellAreaCircle", true) and Workspace.sellAreaCircles.sellAreaCircle:FindFirstChild("circleInner")
    
    if not sellCircle then
        print("Kronos Hub Error: No se encontró el área de venta (sellAreaCircle.circleInner)")
        autoSell = false 
        -- Podrías añadir aquí una forma de desactivar el toggle en la UI si falla
        return
    end

    task.spawn(function()
        while autoSell do
            local player = Players.LocalPlayer
            local character = player and player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp and sellCircle then
                pcall(function() 
                    firetouchinterest(hrp, sellCircle, 0) -- Simula tocar
                    task.wait(0.1)
                    firetouchinterest(hrp, sellCircle, 1) -- Simula dejar de tocar
                end)
                task.wait(5) -- Espera antes de intentar vender de nuevo
            else
                 if not hrp then print("Kronos AutoSell: Esperando HumanoidRootPart...") end
                 task.wait(1) 
            end
        end
    end)
end

function InfiniteChi()
    local chestEvent = ReplicatedStorage.rEvents:FindFirstChild("openChestRemote")
    if not chestEvent then
         print("Kronos Hub Error: No se encontró openChestRemote")
         return
    end
    task.spawn(function()
        -- Orion puede tener notificaciones, podrías usar OrionLib:MakeNotification(...)
        OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Intentando obtener Chi del Cofre del Volcán...", Time = 5})
        for i = 1, 50 do 
            pcall(function()
                 chestEvent:InvokeServer("Volcano Chest") 
            end)
            task.wait(0.1)
        end
        OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Intento de obtener Chi completado.", Time = 5})
        print("Kronos Hub: Intento de obtener Chi completado.")
    end)
end
-- ====================================================

-- --- Creación de los elementos de la UI con Orion ---
-- Llamando a AddToggle, AddButton, etc., en el objeto Tab devuelto por MakeTab

-- Añadir toggles a la Tab de Farming
FarmingTab:AddToggle({
    Name = "Auto Swing (Golpear)",
    Default = false, -- Estado inicial del toggle
    Callback = function(Value) -- La función se ejecuta cuando cambia el estado
        autoSwing = Value
        if autoSwing then
            startAutoSwing()
            print("Kronos Hub: Auto Swing Activado")
            OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Auto Swing Activado", Time = 3})
        else
            print("Kronos Hub: Auto Swing Desactivado")
            OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Auto Swing Desactivado", Time = 3})
        end
    end
})

FarmingTab:AddToggle({
    Name = "Auto Sell (Vender)",
    Default = false,
    Callback = function(Value)
        autoSell = Value
        if autoSell then
            startAutoSell()
            print("Kronos Hub: Auto Sell Activado")
            OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Auto Sell Activado", Time = 3})
        else
            print("Kronos Hub: Auto Sell Desactivado")
            OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Auto Sell Desactivado", Time = 3})
        end
    end
})

-- Añadir botones a la Tab de Desbloqueos
UnlockTab:AddButton({
    Name = "Desbloquear Todas las Espadas",
    Callback = function() 
        UnlockAllSwords()
        OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Intentando desbloquear todas las espadas...", Time = 4})
    end    
})

UnlockTab:AddButton({
    Name = "Desbloquear Todos los Cinturones",
    Callback = function() 
        UnlockAllBelts()
        OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Intentando desbloquear todos los cinturones...", Time = 4})
    end    
})

UnlockTab:AddButton({
    Name = "Desbloquear Todas las Habilidades",
    Callback = function() 
        UnlockAllSkills()
        OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Intentando desbloquear todas las habilidades...", Time = 4})
    end    
})

UnlockTab:AddButton({
    Name = "Obtener Chi (Cofre Volcán)",
    Callback = function() 
        InfiniteChi() 
        -- La notificación se maneja dentro de la función InfiniteChi
    end    
})

-- Añadir botones a la Tab de Teleports
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
    }
    -- Puedes añadir más categorías si existen (p.ej., "Boss Islands")
}

-- Usaremos AddLabel para simular las secciones que tenías
for islandType, islandList in pairs(islands) do
    TeleportTab:AddLabel(islandType) -- Añade un título de sección
    -- TeleportTab:AddDivider() -- Opcional: añade una línea divisoria

    for islandName, islandCFrame in pairs(islandList) do
        TeleportTab:AddButton({
            Name = islandName, 
            Callback = function() 
                local player = Players.LocalPlayer
                local character = player and player.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = islandCFrame
                    print("Kronos Hub: Teletransportado a " .. islandName)
                    OrionLib:MakeNotification({Title = "Teleport", Content = "Teletransportado a " .. islandName, Time = 3})
                else
                    print("Kronos Hub Error: No se pudo encontrar HumanoidRootPart para teletransportar.")
                    OrionLib:MakeNotification({Title = "Teleport Error", Content = "No se pudo encontrar HumanoidRootPart", Time = 5})
                end
            end
        })
    end
end

-- Añadir sliders a la Tab de Misceláneos
MiscTab:AddSlider({
    Name = "Velocidad",
    Min = 16, -- Velocidad mínima (normal)
    Max = 500, -- Velocidad máxima deseada
    Default = 16, -- Valor inicial
    Increment = 1, -- Cuánto cambia el slider cada vez
    ValueName = "WalkSpeed", -- Nombre opcional que se muestra junto al valor
    Callback = function(Value)
        local player = Players.LocalPlayer
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value
        else
            print("Kronos Hub Error: No se pudo encontrar Humanoide para ajustar velocidad.")
        end
    end    
})

MiscTab:AddSlider({
    Name = "Salto",
    Min = 50, -- Potencia de salto mínima (normal)
    Max = 500, -- Potencia de salto máxima deseada
    Default = 50, -- Valor inicial
    Increment = 1, 
    ValueName = "JumpPower",
    Callback = function(Value)
        local player = Players.LocalPlayer
        local character = player and player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- En versiones más nuevas de Roblox, JumpPower está deprecado, se usa JumpHeight
            -- Intenta ambos por compatibilidad
            pcall(function() humanoid.JumpPower = Value end)
            pcall(function() humanoid.JumpHeight = Value end) -- Podrías necesitar ajustar la escala para JumpHeight
        else
            print("Kronos Hub Error: No se pudo encontrar Humanoide para ajustar salto.")
        end
    end    
})

-- Mensaje final en la consola
print("Kronos Hub: Script cargado y UI inicializada con Orion Library.")
OrionLib:MakeNotification({Title = "Kronos Hub", Content = "Script Cargado Correctamente!", Time = 5})
