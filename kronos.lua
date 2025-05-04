--[[
$$\   $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\   $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/ 
                                                            
]]--

-- KRONOS SCRIPT: NINJA LEGENDS
-- Creado por el más pijudo de Argentina
-- Version 1.0

local function printBanner()
    print([[
$$\   $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\   $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/ 
                                                            
KRONOS SCRIPT: NINJA LEGENDS - LA ROMPE TODA
    ]])
end

-- Ejecutamos el banner al inicio
printBanner()

-- Cargar la biblioteca Orion para la UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variables globales
local player = game.Players.LocalPlayer
local hrp = player.Character:WaitForChild("HumanoidRootPart")

-- Crear la ventana principal
local Window = OrionLib:MakeWindow({
    Name = "KRONOS - Ninja Legends", 
    HidePremium = false,
    SaveConfig = true, 
    ConfigFolder = "KronosConfig",
    IntroEnabled = true,
    IntroText = "KRONOS SCRIPT",
    IntroIcon = "rbxassetid://10618644218",
    Icon = "rbxassetid://10618644218"
})

-- Tab de Farming
local FarmingTab = Window:MakeTab({
    Name = "Farming",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tab de Teleports
local TeleportTab = Window:MakeTab({
    Name = "Teleports",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tab de Desbloqueos
local UnlockTab = Window:MakeTab({
    Name = "Desbloqueos",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Tab de Misceláneos
local MiscTab = Window:MakeTab({
    Name = "Misceláneos",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Función para auto-farm
local autoSwing = false
local autoSell = false

-- Función para obtener todas las espadas
function UnlockAllSwords()
    local swords = game:GetService("ReplicatedStorage").Weapon.AllWeapons:GetChildren()
    for _, sword in pairs(swords) do
        game:GetService("ReplicatedStorage").rEvents.BuyItemRemote:FireServer("Weapon", sword.Name)
    end
    OrionLib:MakeNotification({
        Name = "¡ALTA FACHA!",
        Content = "Todas las espadas desbloqueadas, papá",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

-- Función para obtener todos los cinturones
function UnlockAllBelts()
    local belts = game:GetService("ReplicatedStorage").Belt.AllBelts:GetChildren()
    for _, belt in pairs(belts) do
        game:GetService("ReplicatedStorage").rEvents.BuyItemRemote:FireServer("Belt", belt.Name)
    end
    OrionLib:MakeNotification({
        Name = "¡ALTA FACHA!",
        Content = "Todos los cinturones desbloqueados, papá",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

-- Función para obtener todos los skills
function UnlockAllSkills()
    local skills = game:GetService("ReplicatedStorage").Skill.AllSkills:GetChildren()
    for _, skill in pairs(skills) do
        game:GetService("ReplicatedStorage").rEvents.BuyItemRemote:FireServer("Skill", skill.Name)
    end
    OrionLib:MakeNotification({
        Name = "¡ALTA FACHA!",
        Content = "Todas las habilidades desbloqueadas, papá",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

-- Función para auto-swing (golpear automáticamente)
function startAutoSwing()
    spawn(function()
        while autoSwing do
            game:GetService("ReplicatedStorage").rEvents.swingKatanaEvent:FireServer()
            wait(0.01)
        end
    end)
end

-- Función para auto-sell (vender automáticamente)
function startAutoSell()
    spawn(function()
        while autoSell do
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").sellAreaCircles.sellAreaCircle.circleInner, 0)
            wait(0.1)
            firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, game:GetService("Workspace").sellAreaCircles.sellAreaCircle.circleInner, 1)
            wait(5)
        end
    end)
end

-- Función para dar chi infinito
function InfiniteChi()
    for i = 1, 100 do
        game:GetService("ReplicatedStorage").rEvents.openChestRemote:InvokeServer("Volcano Chest")
    end
    OrionLib:MakeNotification({
        Name = "¡GUITA INFINITA!",
        Content = "Chi a full, wacho",
        Image = "rbxassetid://4483345998",
        Time = 5
    })
end

-- Añadir botones a la Tab de Farming
FarmingTab:AddToggle({
    Name = "Auto Swing (Golpear)",
    Default = false,
    Callback = function(Value)
        autoSwing = Value
        if autoSwing then
            startAutoSwing()
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
        end
    end    
})

-- Añadir botones a la Tab de Desbloqueos
UnlockTab:AddButton({
    Name = "Desbloquear Todas las Espadas",
    Callback = function()
        UnlockAllSwords()
    end    
})

UnlockTab:AddButton({
    Name = "Desbloquear Todos los Cinturones",
    Callback = function()
        UnlockAllBelts()
    end    
})

UnlockTab:AddButton({
    Name = "Desbloquear Todas las Habilidades",
    Callback = function()
        UnlockAllSkills()
    end    
})

UnlockTab:AddButton({
    Name = "Chi Infinito",
    Callback = function()
        InfiniteChi()
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
}

for islandType, islandList in pairs(islands) do
    local Section = TeleportTab:AddSection({
        Name = islandType
    })
    
    for islandName, islandCFrame in pairs(islandList) do
        TeleportTab:AddButton({
            Name = islandName,
            Callback = function()
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = islandCFrame
            end    
        })
    end
end

-- Añadir botones a la Tab de Misceláneos
MiscTab:AddSlider({
    Name = "Velocidad",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Velocidad",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

MiscTab:AddSlider({
    Name = "Salto",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Altura",
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end    
})

-- Iniciar la librería
OrionLib:Init()

-- Mensaje final
OrionLib:MakeNotification({
    Name = "¡SCRIPT ACTIVADO!",
    Content = "El script Kronos para Ninja Legends está re activado, papá",
    Image = "rbxassetid://10618644218",
    Time = 10
})
