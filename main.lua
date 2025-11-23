--[[
    ======================================
    ||       NIGHTFALL HUB - Loader       ||
    ||           Arquivo: main.lua        ||
    ======================================
    
    Este script carrega a Interface e a Lógica (Scripts) do GitHub
    na ordem correta para garantir que as funções globais se conectem.
]]

local INTERFACE_URL = "https://raw.githubusercontent.com/jogorobloxcomshaders-commits/Nightfall-hub/refs/heads/main/Interface-Main.lua"
local SCRIPTS_URL = "https://raw.githubusercontent.com/jogorobloxcomshaders-commits/Nightfall-hub/refs/heads/main/scripts.lua"

local HttpService = game:GetService("HttpService")

local function loadAndExecuteScript(url, scriptName)
    local success, content = pcall(function()
        -- Tenta obter o conteúdo do script
        return game:HttpGet(url, true) 
    end)
    
    if not success or not content or content:sub(1, 10) == "404: Not Found" then
        warn("❌ Falha ao carregar " .. scriptName .. " do link: " .. url)
        return false
    end
    
    -- Compila a string de código em uma função
    local executeFunction, compileError = loadstring(content)
    
    if not executeFunction then
        warn("❌ Erro de compilação em " .. scriptName .. ": " .. (compileError or "Desconhecido"))
        return false
    end
    
    -- Executa a função compilada
    local execSuccess, execError = pcall(executeFunction)
    
    if execSuccess then
        print("✅ " .. scriptName .. " carregado e executado com sucesso.")
        return true
    else
        warn("❌ Erro de execução em " .. scriptName .. ": " .. (execError or "Desconhecido"))
        return false
    end
end

-- =========================================
-- Sequência de carregamento
-- 1. Carrega a Interface primeiro (cria a GUI e a função placeholder)
print("Iniciando o carregamento do Nightfall Hub...")
local interfaceLoaded = loadAndExecuteScript(INTERFACE_URL, "Interface-Main.lua")

if interfaceLoaded then
    -- 2. Carrega os Scripts em seguida (define a lógica e a função de toggle)
    loadAndExecuteScript(SCRIPTS_URL, "scripts.lua")
end

print("Processo de carregamento concluído.")
