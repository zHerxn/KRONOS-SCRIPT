--[[
$$\      $$\ $$$$$$$\    $$$$$$\  $$\    $$\  $$$$$$\    $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/  
                                                            
]]--

-- KRONOS SCRIPT: NINJA LEGENDS
-- Adaptado para Kavo UI Library
-- Version 1.3 (Kavo Adapt - Corrigiendo llamadas según fuente)

local function printBanner()
    print([[
$$\      $$\ $$$$$$$\    $$$$$$\  $$\    $$\  $$$$$$\    $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/  
                                                            
KRONOS SCRIPT: NINJA LEGENDS - LA ROMPE TODA (Kavo Edition v1.3)
    ]])
end

-- Ejecutamos el banner al inicio
printBanner()

-- Cargar la biblioteca Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Crear la ventana principal con Kavo UI
-- CreateLib devuelve el objeto principal de la librería (llamado 'Kavo' en el fuente)
local Window = Library.CreateLib("Kronos Hub", "Ocean") 

-- Variables globales de estado
local autoSwing = false
local autoSell = false

-- Referencias a servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Crear las Tabs usando NewTab en el objeto Window (devuelto por CreateLib)
-- NewTab devuelve un objeto 'Tab' para añadir elementos
local FarmingTab = Window:NewTab("Farming") 
local TeleportTab = Window:NewTab("Teleports")
local UnlockTab = Window:NewTab("Desbloqueos")
local MiscTab = Window:NewTab("Misceláneos")

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
        return
    end

    task.spawn(function()
        while autoSell do
            local player = Players.LocalPlayer
            local character = player and player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            
            if hrp and sellCircle then
                pcall(function() 
                    firetouchinterest(hrp, sellCircle, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, sellCircle, 1)
                end)
                task.wait(5) 
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
        for i = 1, 50 do 
            pcall(function()
                 chestEvent:InvokeServer("Volcano Chest") 
            end)
            task.wait(0.1)
        end
        print("Kronos Hub: Intento de obtener Chi completado.")
    end)
end
-- ====================================================

-- --- Creación de los elementos de la UI con Kavo ---
-- Llamando a NewToggle, NewButton, etc., en el objeto Tab devuelto por NewTab

-- Añadir toggles a la Tab de Farming
FarmingTab:NewToggle("Auto Swing (Golpear)", "Activa/desactiva el golpeo automático con la katana", function(Value) -- Usando NewToggle en FarmingTab
    autoSwing = Value
    if autoSwing then
        startAutoSwing()
        print("Kronos Hub: Auto Swing Activado")
    else
        print("Kronos Hub: Auto Swing Desactivado")
    end
end)

FarmingTab:NewToggle("Auto Sell (Vender)", "Activa/desactiva la venta automática al acercarse al área", function(Value) -- Usando NewToggle en FarmingTab
    autoSell = Value
    if autoSell then
        startAutoSell()
        print("Kronos Hub: Auto Sell Activado")
    else
        print("Kronos Hub: Auto Sell Desactivado")
    end
end)

-- Añadir botones a la Tab de Desbloqueos
UnlockTab:NewButton("Desbloquear Todas las Espadas", "Intenta comprar todas las espadas (necesitas monedas)", function() -- Usando NewButton en UnlockTab
    UnlockAllSwords()
end)

UnlockTab:NewButton("Desbloquear Todos los Cinturones", "Intenta comprar todos los cinturones (necesitas monedas)", function() -- Usando NewButton en UnlockTab
    UnlockAllBelts()
end)

UnlockTab:NewButton("Desbloquear Todas las Habilidades", "Intenta comprar todas las skills (necesitas monedas)", function() -- Usando NewButton en UnlockTab
    UnlockAllSkills()
end)

UnlockTab:NewButton("Obtener Chi (Cofre Volcán)", "Intenta abrir cofres del volcán repetidamente para obtener Chi", function() -- Usando NewButton en UnlockTab
    InfiniteChi()
end)

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
}

-- Asumiendo que existe NewSection en el objeto Tab
-- Si esto falla, podríamos necesitar usar NewLabel para los títulos de sección
for islandType, islandList in pairs(islands) do
    TeleportTab:NewSection(islandType) -- Usando NewSection en TeleportTab (ASUNCIÓN)
    
    for islandName, islandCFrame in pairs(islandList) do
        TeleportTab:NewButton(islandName, "Teletransportarse a " .. islandName, function() -- Usando NewButton en TeleportTab
            local player = Players.LocalPlayer
            local character = player and player.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = islandCFrame
                print("Kronos Hub: Teletransportado a " .. islandName)
            else
                print("Kronos Hub Error: No se pudo encontrar HumanoidRootPart para teletransportar.")
            end
        end)
    end
end

-- Añadir sliders a la Tab de Misceláneos
MiscTab:NewSlider("Velocidad", "Ajusta la velocidad de caminata del personaje", 16, 500, 16, function(Value) -- Usando NewSlider en MiscTab
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Value
    else
         print("Kronos Hub Error: No se pudo encontrar Humanoide para ajustar velocidad.")
    end
end)

MiscTab:NewSlider("Salto", "Ajusta la potencia de salto del personaje", 50, 500, 50, function(Value) -- Usando NewSlider en MiscTab
    local player = Players.LocalPlayer
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = Value
    else
        print("Kronos Hub Error: No se pudo encontrar Humanoide para ajustar salto.")
    end
end)

-- Mensaje final en la consola
print("Kronos Hub: Script cargado y UI inicializada con Kavo (v1.3).")
