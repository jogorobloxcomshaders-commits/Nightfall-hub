-- main.lua (Este é o script que você injeta no executor)

-- === CONFIGURAÇÃO DO CARREGADOR ===
-- NOTA: Substitua 'loadfile' ou 'readfile' pela função real do seu executor 
-- que lê o conteúdo de um arquivo como uma string (ex: readfile, getfenv().loadfile, etc.)
local function loadFileContent(fileName)
    -- Exemplo Padrão de Executor:
    -- return readfile(fileName) 
    
    -- Exemplo Simples (Ajuste conforme o seu exploit):
    return "print('ERRO: Função de leitura não implementada para: "..fileName.."')"
end

-- Tabela para armazenar os módulos carregados
local M = {}

-- === CARREGAMENTO E EXECUÇÃO DOS MÓDULOS ===

-- 1. Carrega o Módulo de Configuração (Interface-Config.lua)
local configContent = loadFileContent("Interface-Config.lua") 
local configChunk = loadstring(configContent)
M.Config = configChunk()
_G.CONFIG = M.Config -- Expor ao global, se necessário

print("Configurações carregadas.")

-- 2. Carrega o Módulo Builder (Interface-Builder.lua)
-- O Builder precisa do Config, então passamos o M.Config para o init()
local builderContent = loadFileContent("Interface-Builder.lua") 
local builderChunk = loadstring(builderContent)
M.Builder = builderChunk()
M.Builder:init(M.Config)

print("Builder carregado.")

-- 3. Carrega o Módulo de Lógica (scripts.lua)
local scriptsContent = loadFileContent("scripts.lua") 
local scriptsChunk = loadstring(scriptsContent)
M.Scripts = scriptsChunk()
-- O scripts.lua define as funções globais (_G) para a interface.

print("Lógica (scripts.lua) carregada e funções globais definidas.")

-- 4. Carrega o Módulo Principal da Interface (Interface-Main.lua)
-- O Main agora usa as variáveis globais CONFIG e BUILDER em vez de require
local mainContent = loadFileContent("Interface-Main.lua")
local mainChunk = loadstring(mainContent)
mainChunk() 

print("Interface carregada e executada com sucesso!")
