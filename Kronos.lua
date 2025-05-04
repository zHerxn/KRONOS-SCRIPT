--[[
$$\      $$\ $$$$$$$\    $$$$$$\  $$\   $$\  $$$$$$\    $$$$$$\
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/

]]--

-- KRONOS SCRIPT: NINJA LEGENDS
-- Version 1.4 (Basic UI - Sin librerías externas)

local function printBanner()
    print([[
$$\      $$\ $$$$$$$\    $$$$$$\  $$\   $$\  $$$$$$\    $$$$$$\
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/

KRONOS SCRIPT: NINJA LEGENDS - LA ROMPE TODA (Basic UI v1.4)
    ]])
end

-- Ejecutamos el banner al inicio
printBanner()

-- === Servicios y Jugador Local ===
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui") -- Usaremos CoreGui para la UI
local LocalPlayer = Players.LocalPlayer

-- === Variables de Estado Global ===
local autoSwing = false
local autoSell = false
local autoSwingThread = nil
local autoSellThread = nil

-- === Funciones de Lógica del Juego (sin cambios) ===
function UnlockAllSwords()
    local swords = ReplicatedStorage.Weapon.AllWeapons:GetChildren()
    for _, sword in pairs(swords) do
        pcall(function()
            ReplicatedStorage.rEvents.BuyItemRemote:FireServer("Weapon", sword.Name)
        end)
        task.wait(0.1)
    end
    print("Kronos Hub: Intento de desbloqueo de espadas completado.")
end

function UnlockAllBelts()
    local belts = ReplicatedStorage.Belt.AllBelts:GetChildren()
    for _, belt in pairs(belts) do
        pcall(function()
            ReplicatedStorage.rEvents.BuyItemRemote:FireServer("Belt", belt.Name)
        end)
        task.wait(0.1)
    end
    print("Kronos Hub: Intento de desbloqueo de cinturones completado.")
end

function UnlockAllSkills()
    local skills = ReplicatedStorage.Skill.AllSkills:GetChildren()
    for _, skill in pairs(skills) do
        pcall(function()
            ReplicatedStorage.rEvents.BuyItemRemote:FireServer("Skill", skill.Name)
        end)
        task.wait(0.1)
    end
    print("Kronos Hub: Intento de desbloqueo de habilidades completado.")
end

function startAutoSwing()
    if autoSwingThread then return end -- Evitar múltiples hilos

    local swingEvent = ReplicatedStorage.rEvents:FindFirstChild("swingKatanaEvent")
    if not swingEvent then
        print("Kronos Hub Error: No se encontró swingKatanaEvent")
        autoSwing = false
        return
    end

    autoSwingThread = task.spawn(function()
        print("Kronos Hub: Hilo Auto Swing iniciado.")
        while autoSwing and task.wait(0.05) do
            pcall(function() swingEvent:FireServer() end)
        end
        autoSwingThread = nil -- Limpiar referencia al terminar
        print("Kronos Hub: Hilo Auto Swing detenido.")
    end)
end

function stopAutoSwing()
    autoSwing = false -- La condición del bucle while lo detendrá
end

function startAutoSell()
    if autoSellThread then return end -- Evitar múltiples hilos

    local sellCircleInner = Workspace:FindFirstChild("sellAreaCircles", true) and Workspace.sellAreaCircles:FindFirstChild("sellAreaCircle", true) and Workspace.sellAreaCircles.sellAreaCircle:FindFirstChild("circleInner")

    if not sellCircleInner then
        print("Kronos Hub Error: No se encontró el área de venta (sellAreaCircle.circleInner)")
        autoSell = false
        return
    end

    autoSellThread = task.spawn(function()
        print("Kronos Hub: Hilo Auto Sell iniciado.")
        while autoSell and task.wait() do -- Usar task.wait() simple para el bucle principal
            local character = LocalPlayer and LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")

            if hrp and sellCircleInner then
                local success, err = pcall(function()
                    firetouchinterest(hrp, sellCircleInner, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, sellCircleInner, 1)
                end)
                if not success then
                    warn("Kronos Hub AutoSell Error:", err)
                    -- Considerar detener si hay error repetido
                end
                task.wait(5) -- Esperar 5 segundos entre intentos de venta
            else
                 if not hrp then print("Kronos AutoSell: Esperando HumanoidRootPart...") end
                 task.wait(1) -- Esperar si no se encuentra el HRP
            end
        end
        autoSellThread = nil -- Limpiar referencia al terminar
        print("Kronos Hub: Hilo Auto Sell detenido.")
    end)
end

function stopAutoSell()
    autoSell = false -- La condición del bucle while lo detendrá
end


function InfiniteChi()
    local chestEvent = ReplicatedStorage.rEvents:FindFirstChild("openChestRemote")
    if not chestEvent then
         print("Kronos Hub Error: No se encontró openChestRemote")
         return
    end
    task.spawn(function()
        print("Kronos Hub: Intentando obtener Chi del Cofre Volcán...")
        for i = 1, 50 do
            local success, result = pcall(function()
                return chestEvent:InvokeServer("Volcano Chest")
            end)
            if success then
                -- print("Resultado InvokeServer:", result) -- Opcional: ver qué devuelve
            else
                warn("Kronos Hub Error al invocar openChestRemote:", result)
            end
            task.wait(0.1)
        end
        print("Kronos Hub: Intento de obtener Chi completado (50 veces).")
    end)
end

function TeleportPlayer(cframe)
    local character = LocalPlayer and LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframe
        return true
    else
        print("Kronos Hub Error: No se pudo encontrar HumanoidRootPart para teletransportar.")
        return false
    end
end

-- === Definición de Islas para Teleport ===
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

-- === Creación de la UI Básica ===
local KronosUI = Instance.new("ScreenGui")
KronosUI.Name = "KronosHubUI"
KronosUI.ResetOnSpawn = false
KronosUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KronosUI.Parent = CoreGui -- O Players.LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350) -- Tamaño inicial
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175) -- Centrado
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true -- Para habilitar Draggable
MainFrame.Draggable = true
MainFrame.Parent = KronosUI

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TitleLabel.BorderColor3 = Color3.fromRGB(80, 80, 100)
TitleLabel.BorderSizePixel = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Kronos Hub - Ninja Legends"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
TitleLabel.TextSize = 18
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -28, 0, 3) -- Esquina superior derecha
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderColor3 = Color3.fromRGB(150, 30, 30)
CloseButton.BorderSizePixel = 1
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Parent = TitleLabel -- Dentro del título para mejor manejo
CloseButton.MouseButton1Click:Connect(function()
    KronosUI:Destroy() -- Cierra la UI
    -- Asegurarse de detener los bucles al cerrar
    autoSwing = false
    autoSell = false
end)


local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 30) -- Debajo del título
TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabContentContainer = Instance.new("Frame")
TabContentContainer.Name = "TabContentContainer"
TabContentContainer.Size = UDim2.new(1, -10, 1, -45) -- Ajustar tamaño y posición
TabContentContainer.Position = UDim2.new(0, 5, 0, 40) -- Debajo de la barra de tabs
TabContentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40) -- Mismo fondo que el principal
TabContentContainer.BorderSizePixel = 0
TabContentContainer.ClipsDescendants = true -- Ocultar contenido que se salga
TabContentContainer.Parent = MainFrame

-- Crear Frames para cada Tab (inicialmente invisibles excepto el primero)
local FarmingFrame = Instance.new("Frame")
FarmingFrame.Name = "FarmingFrame"
FarmingFrame.Size = UDim2.new(1, 0, 1, 0)
FarmingFrame.Position = UDim2.new(0, 0, 0, 0)
FarmingFrame.BackgroundTransparency = 1
FarmingFrame.Visible = true -- Visible por defecto
FarmingFrame.Parent = TabContentContainer

local TeleportFrame = Instance.new("ScrollingFrame") -- Usar ScrollingFrame para teleports
TeleportFrame.Name = "TeleportFrame"
TeleportFrame.Size = UDim2.new(1, 0, 1, 0)
TeleportFrame.Position = UDim2.new(0, 0, 0, 0)
TeleportFrame.BackgroundTransparency = 1
TeleportFrame.Visible = false
TeleportFrame.Parent = TabContentContainer
TeleportFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Se ajustará dinámicamente
TeleportFrame.ScrollBarThickness = 6
TeleportFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local UnlockFrame = Instance.new("Frame")
UnlockFrame.Name = "UnlockFrame"
UnlockFrame.Size = UDim2.new(1, 0, 1, 0)
UnlockFrame.Position = UDim2.new(0, 0, 0, 0)
UnlockFrame.BackgroundTransparency = 1
UnlockFrame.Visible = false
UnlockFrame.Parent = TabContentContainer

local MiscFrame = Instance.new("Frame")
MiscFrame.Name = "MiscFrame"
MiscFrame.Size = UDim2.new(1, 0, 1, 0)
MiscFrame.Position = UDim2.new(0, 0, 0, 0)
MiscFrame.BackgroundTransparency = 1
MiscFrame.Visible = false
MiscFrame.Parent = TabContentContainer

-- Lista de Tabs y sus Frames asociados
local Tabs = {
    {Name = "Farming", Frame = FarmingFrame},
    {Name = "Teleports", Frame = TeleportFrame},
    {Name = "Desbloqueos", Frame = UnlockFrame},
    {Name = "Misceláneos", Frame = MiscFrame}
}

local function SwitchTab(targetFrame)
    for _, tabInfo in ipairs(Tabs) do
        tabInfo.Frame.Visible = (tabInfo.Frame == targetFrame)
    end
end

-- Crear Botones de Tab
local tabButtonWidth = 1 / #Tabs
for i, tabInfo in ipairs(Tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabInfo.Name .. "TabButton"
    TabButton.Size = UDim2.new(tabButtonWidth, -2, 1, -2) -- Ancho distribuido, pequeño margen
    TabButton.Position = UDim2.new(tabButtonWidth * (i - 1), 1, 0, 1)
    TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    TabButton.BorderColor3 = Color3.fromRGB(80, 80, 100)
    TabButton.BorderSizePixel = 1
    TabButton.Font = Enum.Font.SourceSans
    TabButton.Text = tabInfo.Name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabButton.TextSize = 14
    TabButton.Parent = TabBar

    TabButton.MouseButton1Click:Connect(function()
        SwitchTab(tabInfo.Frame)
        -- Cambiar apariencia del botón activo (opcional)
        for _, btn in pairs(TabBar:GetChildren()) do
             if btn:IsA("TextButton") then
                 btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65) -- Color inactivo
             end
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90) -- Color activo
    end)

    -- Activar el primer botón visualmente
    if i == 1 then
        TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end
end

-- === Contenido de las Tabs ===

-- --- Farming Tab ---
local UILayoutFarming = Instance.new("UIListLayout")
UILayoutFarming.Padding = UDim.new(0, 5)
UILayoutFarming.SortOrder = Enum.SortOrder.LayoutOrder
UILayoutFarming.Parent = FarmingFrame

local AutoSwingButton = Instance.new("TextButton")
AutoSwingButton.Name = "AutoSwingButton"
AutoSwingButton.Size = UDim2.new(1, -10, 0, 30) -- Ancho completo menos padding
AutoSwingButton.Position = UDim2.new(0, 5, 0, 5)
AutoSwingButton.BackgroundColor3 = Color3.fromRGB(60, 90, 60)
AutoSwingButton.BorderColor3 = Color3.fromRGB(40, 60, 40)
AutoSwingButton.BorderSizePixel = 1
AutoSwingButton.Font = Enum.Font.SourceSans
AutoSwingButton.Text = "Auto Swing [OFF]"
AutoSwingButton.TextColor3 = Color3.fromRGB(220, 255, 220)
AutoSwingButton.TextSize = 14
AutoSwingButton.LayoutOrder = 1
AutoSwingButton.Parent = FarmingFrame
AutoSwingButton.MouseButton1Click:Connect(function()
    autoSwing = not autoSwing
    if autoSwing then
        AutoSwingButton.Text = "Auto Swing [ON]"
        AutoSwingButton.BackgroundColor3 = Color3.fromRGB(90, 140, 90)
        startAutoSwing()
        print("Kronos Hub: Auto Swing Activado")
    else
        AutoSwingButton.Text = "Auto Swing [OFF]"
        AutoSwingButton.BackgroundColor3 = Color3.fromRGB(60, 90, 60)
        stopAutoSwing()
        print("Kronos Hub: Auto Swing Desactivado")
    end
end)

local AutoSellButton = Instance.new("TextButton")
AutoSellButton.Name = "AutoSellButton"
AutoSellButton.Size = UDim2.new(1, -10, 0, 30)
AutoSellButton.Position = UDim2.new(0, 5, 0, 40) -- Posición relativa manual si no se usa Layout
AutoSellButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
AutoSellButton.BorderColor3 = Color3.fromRGB(40, 40, 60)
AutoSellButton.BorderSizePixel = 1
AutoSellButton.Font = Enum.Font.SourceSans
AutoSellButton.Text = "Auto Sell [OFF]"
AutoSellButton.TextColor3 = Color3.fromRGB(220, 220, 255)
AutoSellButton.TextSize = 14
AutoSellButton.LayoutOrder = 2
AutoSellButton.Parent = FarmingFrame
AutoSellButton.MouseButton1Click:Connect(function()
    autoSell = not autoSell
    if autoSell then
        AutoSellButton.Text = "Auto Sell [ON]"
        AutoSellButton.BackgroundColor3 = Color3.fromRGB(90, 90, 140)
        startAutoSell()
        print("Kronos Hub: Auto Sell Activado")
    else
        AutoSellButton.Text = "Auto Sell [OFF]"
        AutoSellButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        stopAutoSell()
        print("Kronos Hub: Auto Sell Desactivado")
    end
end)

-- --- Desbloqueos Tab ---
local UILayoutUnlock = Instance.new("UIListLayout")
UILayoutUnlock.Padding = UDim.new(0, 5)
UILayoutUnlock.SortOrder = Enum.SortOrder.LayoutOrder
UILayoutUnlock.Parent = UnlockFrame

local UnlockSwordsButton = Instance.new("TextButton")
UnlockSwordsButton.Name = "UnlockSwords"
UnlockSwordsButton.Size = UDim2.new(1, -10, 0, 30)
UnlockSwordsButton.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
UnlockSwordsButton.Text = "Desbloquear Todas las Espadas"
UnlockSwordsButton.TextColor3 = Color3.fromRGB(255, 220, 220)
UnlockSwordsButton.TextSize = 14
UnlockSwordsButton.LayoutOrder = 1
UnlockSwordsButton.Parent = UnlockFrame
UnlockSwordsButton.MouseButton1Click:Connect(UnlockAllSwords)

local UnlockBeltsButton = Instance.new("TextButton")
UnlockBeltsButton.Name = "UnlockBelts"
UnlockBeltsButton.Size = UDim2.new(1, -10, 0, 30)
UnlockBeltsButton.BackgroundColor3 = Color3.fromRGB(100, 80, 60)
UnlockBeltsButton.Text = "Desbloquear Todos los Cinturones"
UnlockBeltsButton.TextColor3 = Color3.fromRGB(255, 230, 210)
UnlockBeltsButton.TextSize = 14
UnlockBeltsButton.LayoutOrder = 2
UnlockBeltsButton.Parent = UnlockFrame
UnlockBeltsButton.MouseButton1Click:Connect(UnlockAllBelts)

local UnlockSkillsButton = Instance.new("TextButton")
UnlockSkillsButton.Name = "UnlockSkills"
UnlockSkillsButton.Size = UDim2.new(1, -10, 0, 30)
UnlockSkillsButton.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
UnlockSkillsButton.Text = "Desbloquear Todas las Habilidades"
UnlockSkillsButton.TextColor3 = Color3.fromRGB(220, 255, 220)
UnlockSkillsButton.TextSize = 14
UnlockSkillsButton.LayoutOrder = 3
UnlockSkillsButton.Parent = UnlockFrame
UnlockSkillsButton.MouseButton1Click:Connect(UnlockAllSkills)

local InfiniteChiButton = Instance.new("TextButton")
InfiniteChiButton.Name = "InfiniteChi"
InfiniteChiButton.Size = UDim2.new(1, -10, 0, 30)
InfiniteChiButton.BackgroundColor3 = Color3.fromRGB(60, 100, 100)
InfiniteChiButton.Text = "Obtener Chi (Cofre Volcán x50)"
InfiniteChiButton.TextColor3 = Color3.fromRGB(220, 255, 255)
InfiniteChiButton.TextSize = 14
InfiniteChiButton.LayoutOrder = 4
InfiniteChiButton.Parent = UnlockFrame
InfiniteChiButton.MouseButton1Click:Connect(InfiniteChi)

-- --- Teleports Tab ---
local UILayoutTeleport = Instance.new("UIListLayout")
UILayoutTeleport.Padding = UDim.new(0, 5)
UILayoutTeleport.SortOrder = Enum.SortOrder.LayoutOrder
UILayoutTeleport.HorizontalAlignment = Enum.HorizontalAlignment.Left
UILayoutTeleport.Parent = TeleportFrame

local currentYPos = 5 -- Para calcular CanvasSize

for islandType, islandList in pairs(islands) do
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = islandType:gsub(" ", "") .. "Label"
    SectionLabel.Size = UDim2.new(1, -10, 0, 25)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Font = Enum.Font.SourceSansBold
    SectionLabel.Text = islandType
    SectionLabel.TextColor3 = Color3.fromRGB(210, 210, 230)
    SectionLabel.TextSize = 16
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.LayoutOrder = currentYPos
    SectionLabel.Parent = TeleportFrame
    currentYPos = currentYPos + 25 + 5 -- Altura + Padding

    for islandName, islandCFrame in pairs(islandList) do
        local TeleportButton = Instance.new("TextButton")
        TeleportButton.Name = islandName:gsub(" ", "") .. "Button"
        TeleportButton.Size = UDim2.new(1, -10, 0, 25)
        TeleportButton.BackgroundColor3 = Color3.fromRGB(55, 70, 90)
        TeleportButton.BorderColor3 = Color3.fromRGB(40, 50, 70)
        TeleportButton.BorderSizePixel = 1
        TeleportButton.Font = Enum.Font.SourceSans
        TeleportButton.Text = islandName
        TeleportButton.TextColor3 = Color3.fromRGB(190, 210, 240)
        TeleportButton.TextSize = 14
        TeleportButton.LayoutOrder = currentYPos
        TeleportButton.Parent = TeleportFrame

        TeleportButton.MouseButton1Click:Connect(function()
            if TeleportPlayer(islandCFrame) then
                print("Kronos Hub: Teletransportado a " .. islandName)
            end
        end)
        currentYPos = currentYPos + 25 + 5 -- Altura + Padding
    end
    currentYPos = currentYPos + 10 -- Espacio extra entre secciones
end
TeleportFrame.CanvasSize = UDim2.new(0, 0, 0, currentYPos) -- Ajustar tamaño del canvas


-- --- Misceláneos Tab ---
local UILayoutMisc = Instance.new("UIListLayout")
UILayoutMisc.Padding = UDim.new(0, 10) -- Más padding vertical
UILayoutMisc.SortOrder = Enum.SortOrder.LayoutOrder
UILayoutMisc.Parent = MiscFrame

-- WalkSpeed Control
local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Name = "WalkSpeedLabel"
WalkSpeedLabel.Size = UDim2.new(1, -10, 0, 20)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Font = Enum.Font.SourceSans
WalkSpeedLabel.Text = "Velocidad (Actual: 16)"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
WalkSpeedLabel.TextSize = 14
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkSpeedLabel.LayoutOrder = 1
WalkSpeedLabel.Parent = MiscFrame

local WalkSpeedInput = Instance.new("TextBox")
WalkSpeedInput.Name = "WalkSpeedInput"
WalkSpeedInput.Size = UDim2.new(1, -10, 0, 30)
WalkSpeedInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
WalkSpeedInput.BorderColor3 = Color3.fromRGB(80, 80, 100)
WalkSpeedInput.BorderSizePixel = 1
WalkSpeedInput.Font = Enum.Font.SourceSans
WalkSpeedInput.Text = "16" -- Valor por defecto
WalkSpeedInput.TextColor3 = Color3.fromRGB(220, 220, 220)
WalkSpeedInput.TextSize = 14
WalkSpeedInput.ClearTextOnFocus = false
WalkSpeedInput.LayoutOrder = 2
WalkSpeedInput.Parent = MiscFrame
WalkSpeedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then -- Solo aplicar si se presionó Enter
        local value = tonumber(WalkSpeedInput.Text)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if value and humanoid then
             value = math.clamp(value, 1, 500) -- Limitar valor
             humanoid.WalkSpeed = value
             WalkSpeedLabel.Text = "Velocidad (Actual: " .. tostring(value) .. ")"
             WalkSpeedInput.Text = tostring(value) -- Actualizar textbox por si se clampó
             print("Kronos Hub: Velocidad ajustada a " .. value)
        else
             -- Resetear al valor actual si la entrada es inválida
             if humanoid then WalkSpeedInput.Text = tostring(humanoid.WalkSpeed) end
             warn("Kronos Hub: Entrada de velocidad inválida.")
        end
    end
end)

-- JumpPower Control
local JumpPowerLabel = Instance.new("TextLabel")
JumpPowerLabel.Name = "JumpPowerLabel"
JumpPowerLabel.Size = UDim2.new(1, -10, 0, 20)
JumpPowerLabel.BackgroundTransparency = 1
JumpPowerLabel.Font = Enum.Font.SourceSans
JumpPowerLabel.Text = "Salto (Actual: 50)"
JumpPowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpPowerLabel.TextSize = 14
JumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpPowerLabel.LayoutOrder = 3
JumpPowerLabel.Parent = MiscFrame

local JumpPowerInput = Instance.new("TextBox")
JumpPowerInput.Name = "JumpPowerInput"
JumpPowerInput.Size = UDim2.new(1, -10, 0, 30)
JumpPowerInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
JumpPowerInput.BorderColor3 = Color3.fromRGB(80, 80, 100)
JumpPowerInput.BorderSizePixel = 1
JumpPowerInput.Font = Enum.Font.SourceSans
JumpPowerInput.Text = "50" -- Valor por defecto
JumpPowerInput.TextColor3 = Color3.fromRGB(220, 220, 220)
JumpPowerInput.TextSize = 14
JumpPowerInput.ClearTextOnFocus = false
JumpPowerInput.LayoutOrder = 4
JumpPowerInput.Parent = MiscFrame
JumpPowerInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then -- Solo aplicar si se presionó Enter
        local value = tonumber(JumpPowerInput.Text)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if value and humanoid then
             value = math.clamp(value, 1, 500) -- Limitar valor
             humanoid.JumpPower = value
             JumpPowerLabel.Text = "Salto (Actual: " .. tostring(value) .. ")"
             JumpPowerInput.Text = tostring(value) -- Actualizar textbox por si se clampó
             print("Kronos Hub: Potencia de salto ajustada a " .. value)
        else
             -- Resetear al valor actual si la entrada es inválida
             if humanoid then JumpPowerInput.Text = tostring(humanoid.JumpPower) end
             warn("Kronos Hub: Entrada de salto inválida.")
        end
    end
end)

-- Inicializar texto de labels de Misc con valores actuales si el personaje existe
task.wait(1) -- Esperar un poco a que cargue el personaje
local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if humanoid then
    WalkSpeedLabel.Text = "Velocidad (Actual: " .. tostring(humanoid.WalkSpeed) .. ")"
    WalkSpeedInput.Text = tostring(humanoid.WalkSpeed)
    JumpPowerLabel.Text = "Salto (Actual: " .. tostring(humanoid.JumpPower) .. ")"
    JumpPowerInput.Text = tostring(humanoid.JumpPower)
end

-- Mensaje final en la consola
print("Kronos Hub: Script cargado y UI básica inicializada (v1.4).")
