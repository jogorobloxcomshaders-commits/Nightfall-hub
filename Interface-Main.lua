-- LocalScript para criar interface com gradiente e blur
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomInterface"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

-- Criar Blur Effect
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 12
blurEffect.Parent = game.Lighting

-- Criar Frame principal (centralizado)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Adicionar bordas arredondadas
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 20)
uiCorner.Parent = mainFrame

-- Adicionar gradiente diagonal (roxo claro → roxo escuro)
local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    -- Roxo Médio (8300C4 - 131, 0, 196)
    ColorSequenceKeypoint.new(0, Color3.fromRGB(131, 0, 196)), 
    -- Roxo Escuro (4C00A4 - 76, 0, 164)
    ColorSequenceKeypoint.new(1, Color3.fromRGB(76, 0, 164))   
}
uiGradient.Rotation = 45 -- Diagonal
uiGradient.Parent = mainFrame

-- Animar o gradiente em movimento contínuo
spawn(function()
	local rotation = 45
	while mainFrame and mainFrame.Parent do
		wait(0.05)
		rotation = rotation + 0.2
		if rotation >= 405 then
			rotation = 45
		end
		uiGradient.Rotation = rotation
	end
end)

-- Criar sombras nas bordas da tela
-- Roxo Escuro (33007B - 51, 0, 123)
local DARK_PURPLE = Color3.fromRGB(51, 0, 123)
-- Roxo Médio (4C00A4 - 76, 0, 164)
local MEDIUM_PURPLE = Color3.fromRGB(76, 0, 164)

-- Sombra superior
local topShadow = Instance.new("Frame")
topShadow.Name = "TopShadow"
topShadow.Size = UDim2.new(1, 0, 0, 60)
topShadow.Position = UDim2.new(0, 0, 0, 0)
topShadow.BackgroundColor3 = DARK_PURPLE -- Cor de base para a sombra
topShadow.BorderSizePixel = 0
topShadow.Parent = screenGui

local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, DARK_PURPLE),
    ColorSequenceKeypoint.new(1, DARK_PURPLE)
}
topGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1)
}
topGradient.Rotation = 90
topGradient.Parent = topShadow

-- Sombra inferior
local bottomShadow = Instance.new("Frame")
bottomShadow.Name = "BottomShadow"
bottomShadow.Size = UDim2.new(1, 0, 0, 60)
bottomShadow.Position = UDim2.new(0, 0, 1, -60)
bottomShadow.BackgroundColor3 = DARK_PURPLE -- Cor de base para a sombra
bottomShadow.BorderSizePixel = 0
bottomShadow.Parent = screenGui

local bottomGradient = Instance.new("UIGradient")
bottomGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, DARK_PURPLE),
    ColorSequenceKeypoint.new(1, DARK_PURPLE)
}
bottomGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(1, 0.3)
}
bottomGradient.Rotation = 90
bottomGradient.Parent = bottomShadow

-- Sombra esquerda
local leftShadow = Instance.new("Frame")
leftShadow.Name = "LeftShadow"
leftShadow.Size = UDim2.new(0, 60, 1, 0)
leftShadow.Position = UDim2.new(0, 0, 0, 0)
leftShadow.BackgroundColor3 = MEDIUM_PURPLE -- Cor de base para a sombra
leftShadow.BorderSizePixel = 0
leftShadow.Parent = screenGui

local leftGradient = Instance.new("UIGradient")
leftGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, MEDIUM_PURPLE),
    ColorSequenceKeypoint.new(1, MEDIUM_PURPLE)
}
leftGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1)
}
leftGradient.Rotation = 0
leftGradient.Parent = leftShadow

-- Sombra direita
local rightShadow = Instance.new("Frame")
rightShadow.Name = "RightShadow"
rightShadow.Size = UDim2.new(0, 60, 1, 0)
rightShadow.Position = UDim2.new(1, -60, 0, 0)
rightShadow.BackgroundColor3 = DARK_PURPLE -- Cor de base para a sombra
rightShadow.BorderSizePixel = 0
rightShadow.Parent = screenGui

local rightGradient = Instance.new("UIGradient")
rightGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, DARK_PURPLE),
    ColorSequenceKeypoint.new(1, DARK_PURPLE)
}
rightGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(1, 0.3)
}
rightGradient.Rotation = 0
rightGradient.Parent = rightShadow

-- Garantir que as sombras fiquem atrás da interface principal
topShadow.ZIndex = 100
bottomShadow.ZIndex = 100
leftShadow.ZIndex = 100
rightShadow.ZIndex = 100
mainFrame.ZIndex = 200

-- Criar Sidebar no lado esquerdo
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 70, 1, -40)
sidebar.Position = UDim2.new(0, 20, 0, 20)
-- Roxo Vivo (AB00FF - 171, 0, 255)
sidebar.BackgroundColor3 = Color3.fromRGB(171, 0, 255) 
sidebar.BackgroundTransparency = 0.5
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Adicionar bordas arredondadas apenas nos cantos esquerdos
local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 20)
sidebarCorner.Parent = sidebar

print("Interface pronta")

task.wait(2)
screenGui.Destroy()
