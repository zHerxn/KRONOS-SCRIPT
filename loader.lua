--[[
$$\   $$\ $$$$$$$\   $$$$$$\  $$\   $$\  $$$$$$\   $$$$$$\  
$$ | $$  |$$  __$$\ $$  __$$\ $$$\  $$ |$$  __$$\ $$  __$$\ 
$$ |$$  / $$ |  $$ |$$ /  $$ |$$$$\ $$ |$$ /  \__|$$ /  \__|
$$$$$  /  $$$$$$$  |$$ |  $$ |$$ $$\$$ |\$$$$$$\  \$$$$$$\  
$$  $$<   $$  __$$< $$ |  $$ |$$ \$$$$ | \____$$\  \____$$\ 
$$ |\$$\  $$ |  $$ |$$ |  $$ |$$ |\$$$ |$$\   $$ |$$\   $$ |
$$ | \$$\ $$ |  $$ | $$$$$$  |$$ | \$$ |\$$$$$$  |\$$$$$$  |
\__|  \__|\__|  \__| \______/ \__|  \__| \______/  \______/ 
                                                    
KRONOS SCRIPT LOADER - NINJA LEGENDS
Creado por el más capo de Argentina
]]--

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

-- Ejecutamos el banner en la consola
printBanner()

-- Notificación de carga
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "✅ KRONOS SCRIPT",
    Text = "Cargando... ¡Aguantá unos segundos!",
    Duration = 5
})

-- Lista de servidores desde donde cargar (por si alguno falla)
local sources = {
    -- GitHub Raw
    "https://raw.githubusercontent.com/zHerxn/Kronos-Script/main/kronos.lua",
    
    -- Pastebin Raw
    "https://pastebin.com/raw/TuCodigoPastebin",
    
    -- GitLab Raw
    "https://gitlab.com/tuusuario/Kronos-Script/-/raw/main/kronos.lua",
    
    -- BitBucket Raw
    "https://bitbucket.org/tuusuario/kronos-script/raw/main/kronos.lua",
    
    -- Sitio personal
    "https://tusitio.com/kronos/kronos.lua"
}

-- Función para verificar la compatibilidad del ejecutor
local function checkExecutor()
    local executors = {
        ["Solara"] = true,
        ["Swift"] = true,
        ["Visual"] = true,
        ["Fluxus"] = true,
        ["AWP"] = true,
        ["Seliware"] = true,
        ["Xeno"] = "warning", -- Xeno es medio pelo, viste
        ["Potassium"] = true,
        ["Delta"] = "mobile" -- Para los del celu
    }
    
    local executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
    
    if executors[executor] == "warning" then
        StarterGui:SetCore("SendNotification", {
            Title = "⚠️ ADVERTENCIA",
            Text = "Estás usando " .. executor .. ", puede andar medio choto",
            Duration = 7
        })
        return true
    elseif executors[executor] == "mobile" then
        StarterGui:SetCore("SendNotification", {
            Title = "📱 MÓVIL DETECTADO",
            Text = "Configurando para ejecutor móvil...",
            Duration = 7
        })
        return true
    elseif executors[executor] or executor == "Unknown" then
        return true
    else
        StarterGui:SetCore("SendNotification", {
            Title = "❌ ERROR",
            Text = "Tu executor no es compatible, conseguite uno mejor",
            Duration = 7
        })
        return false
    end
end

-- Función para cargar el script desde cualquiera de los sources
local function loadScript()
    if not checkExecutor() then return end
    
    local success = false
    local errorMessages = {}
    
    for i, source in ipairs(sources) do
        local status, result = pcall(function()
            return game:HttpGet(source)
        end)
        
        if status then
            local loadStatus, loadResult = pcall(function()
                return loadstring(result)()
            end)
            
            if loadStatus then
                success = true
                StarterGui:SetCore("SendNotification", {
                    Title = "✅ KRONOS CARGADO",
                    Text = "¡Listo para romper todo en Ninja Legends!",
                    Duration = 5
                })
                break
            else
                table.insert(errorMessages, "Error al ejecutar desde " .. i .. ": " .. tostring(loadResult))
            end
        else
            table.insert(errorMessages, "Error al obtener de " .. i .. ": " .. tostring(result))
        end
    end
    
    if not success then
        warn("KRONOS ERROR: No se pudo cargar desde ningún servidor.")
        for _, msg in ipairs(errorMessages) do
            warn(msg)
        end
        
        StarterGui:SetCore("SendNotification", {
            Title = "❌ ERROR DE CARGA",
            Text = "Fijate la consola para más detalles",
            Duration = 10
        })
    end
end

-- Verifiquemos que estamos en el juego correcto
if game.PlaceId == 3956818381 then
    -- Ninja Legends
    loadScript()
elseif game.PlaceId == 4616652839 or game.PlaceId == 6986372023 then
    -- Variaciones del juego (servidores diferentes)
    loadScript()
else
    StarterGui:SetCore("SendNotification", {
        Title = "❌ JUEGO INCORRECTO",
        Text = "Este script es solo para Ninja Legends, capo.",
        Duration = 7
    })
end

-- Easter egg secreto (1 en 50 probabilidad)
if math.random(1, 50) == 1 then
    StarterGui:SetCore("SendNotification", {
        Title = "🧉 MOMENTO MATE",
        Text = "Un matecito y seguimos viciando...",
        Duration = 5
    })
end

-- Versión del loader
local version = "1.3"
print("KRONOS LOADER v" .. version .. " - Carga completa.")
