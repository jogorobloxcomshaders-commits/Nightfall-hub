-- Interface-Config.lua

local Config = {}

-- [[ 1. PALETA DE CORES ]]

-- Baseado na imagem roxa escura
Config.PALETTE = {
    -- Cores Principais
    NIGHT_PLUM = Color3.fromRGB(47, 0, 88),      -- #2F0058 (Aba Ativa / Destaque)
    MIDNIGHT_BLOOM = Color3.fromRGB(42, 33, 59), -- #2A213B (Abas Inativas / Switch Fundo)
    INDIGO_DUSK = Color3.fromRGB(72, 51, 86),    -- #483356 (Abas Hover / Scrollbar)
    EBONY_GLOW = Color3.fromRGB(26, 19, 33),     -- #1A1321 (ContentFrame / Seções)
    BLACK_SATIN = Color3.fromRGB(11, 9, 14),     -- #0B090E (MainFrame - Fundo)
    
    -- Cores de Texto
    TEXT_PRIMARY = Color3.fromRGB(200, 200, 210), 
    TEXT_SECONDARY = Color3.fromRGB(150, 150, 160),
    
    -- Cores de Estado
    GREEN_BASE = Color3.fromRGB(60, 200, 120),   -- Toggle ativo (verde)
}

-- [[ 2. CONFIGURAÇÃO DE UI ]]

Config.UI = {
    -- Transparências
    INACTIVE_TAB_TRANSPARENCY = 0.35, 
    CONTENT_FRAME_TRANSPARENCY = 0.15, 
    TOP_BUTTON_TRANSPARENCY = 0.35, 
    
    -- Mapeamento de Cores da Paleta para a UI
    TAB_INACTIVE_COLOR = Config.PALETTE.MIDNIGHT_BLOOM,
    TAB_HOVER_COLOR = Config.PALETTE.INDIGO_DUSK,
    TAB_ACTIVE_COLOR = Config.PALETTE.NIGHT_PLUM,
}

-- [[ 3. ESTRUTURA DAS ABAS E SEÇÕES ]]

Config.TABS_CONFIG = {
    -- HOME
    {
        Name = "Home",
        Icon = "🏠",
        Sections = {
            {Name = "Casas"},
            {Name = "Player"}
        }
    },
    -- VISUALS
    {
        Name = "Visuals",
        Icon = "👁",
        Sections = {
            {
                Name = "ESP",
                Items = {
                    {Type = "Toggle", Name = "Neon Aura (RGB)", GlobalFunc = "toggleNeonESPAura"},
                    {Type = "Toggle", Name = "Line ESP", GlobalFunc = "toggleLineESP"},
                }
            },
            {Name = "Chams"},
            {Name = "FX"}
        }
    },
    -- SETTINGS
    {
        Name = "Settings",
        Icon = "⚙️",
        Sections = {
            {Name = "Geral"},
            {Name = "Temas"}
        }
    },
    -- COMBAT
    {
        Name = "Combat",
        Icon = "⚔",
        Sections = {
            {Name = "Aimbot"},
            {Name = "Meele"}
        }
    },
    -- INFO
    {
        Name = "Info",
        Icon = "ℹ️",
        Sections = {
            {Name = "Créditos"},
            {Name = "Versão"}
        }
    },
}


return Config
