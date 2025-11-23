-- =================================================================
-- INTERFACE-MAIN.LUA (ARQUIVO ÚNICO PARA INJEÇÃO/EXPLOIT)
-- Inclui Config e Builder inline para evitar erros de 'require'
-- =================================================================

-- 1. SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")


-- =================================================================
-- MÓDULO INLINE: INTERFACE-CONFIG
-- =================================================================
local CONFIG = {}

CONFIG.PALETTE = {
    NIGHT_PLUM = Color3.fromRGB(47, 0, 88),
    MIDNIGHT_BLOOM = Color3.fromRGB(42, 33, 59),
    INDIGO_DUSK = Color3.fromRGB(72, 51, 86),
    EBONY_GLOW = Color3.fromRGB(26, 19, 33),
    BLACK_SATIN = Color3.fromRGB(11, 9, 14),
    
    TEXT_PRIMARY = Color3.fromRGB(200, 200, 210), 
    TEXT_SECONDARY = Color3.fromRGB(150, 150, 160),
    
    GREEN_BASE = Color3.fromRGB(60, 200, 120),
}

CONFIG.UI = {
    INACTIVE_TAB_TRANSPARENCY = 0.35, 
    CONTENT_FRAME_TRANSPARENCY = 0.15, 
    TOP_BUTTON_TRANSPARENCY = 0.35, 
    
    TAB_INACTIVE_COLOR = CONFIG.PALETTE.MIDNIGHT_BLOOM,
    TAB_HOVER_COLOR = CONFIG.PALETTE.INDIGO_DUSK,
    TAB_ACTIVE_COLOR = CONFIG.PALETTE.NIGHT_PLUM,
}

CONFIG.TABS_CONFIG = {
    {Name = "Home", Icon = "🏠", Sections = {{Name = "Casas"}, {Name = "Player"}}},
    {Name = "Visuals", Icon = "👁", Sections = {
        {
            Name = "ESP",
            Items = {
                {Type = "Toggle", Name = "Neon Aura (RGB)", GlobalFunc = "toggleNeonESPAura"},
                {Type = "Toggle", Name = "Line ESP", GlobalFunc = "toggleLineESP"},
            }
        },
        {Name = "Chams"},
        {Name = "FX"}
    }},
    {Name = "Settings", Icon = "⚙️", Sections = {{Name = "Geral"}, {Name = "Temas"}}},
    {Name = "Combat", Icon = "⚔", Sections = {{Name = "Aimbot"}, {Name = "Meele"}}},
    {Name = "Info", Icon = "ℹ️", Sections = {{Name = "Créditos"}, {Name = "Versão"}}},
}


-- =================================================================
-- MÓDULO INLINE: INTERFACE-BUILDER (Funções de Criação)
-- =================================================================
local Builder = {}

local function animateTabShadow(tabButton, active)
    local stroke = tabButton:FindFirstChild("NeonStroke")
    if not stroke then return end

    if active then
        TweenService:Create(stroke, TweenInfo.new(0.3), {Color = CONFIG.PALETTE.NIGHT_PLUM, Transparency = 0.3}):Play()
    else
        TweenService:Create(stroke, TweenInfo.new(0.3), {Color = CONFIG.PALETTE.NIGHT_PLUM, Transparency = 1}):Play()
    end
end

local function animateTabExpand(tabButton, targetSize, targetTransparency, targetColor, bgTransparency)
    TweenService:Create(tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = targetSize, BackgroundColor3 = targetColor, BackgroundTransparency = bgTransparency 
    }):Play()
    
    local nameLabel = tabButton:FindFirstChild("NameLabel")
    if nameLabel then
        TweenService:Create(nameLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = targetTransparency}):Play()
    end
end

Builder.resetTabButton = function(button)
    if button then
        animateTabExpand(button, UDim2.new(0, 45, 0, 45), 1, CONFIG.UI.TAB_INACTIVE_COLOR, CONFIG.UI.INACTIVE_TAB_TRANSPARENCY) 
        animateTabShadow(button, false) 
    end
end

Builder.createTopButton = function(name, icon, parent)
	local button = Instance.new("TextButton")
	button.Name = name .. "Button"
	button.Size = UDim2.new(0, 40, 0, 30)
	button.BackgroundColor3 = CONFIG.PALETTE.EBONY_GLOW
	button.BackgroundTransparency = CONFIG.UI.TOP_BUTTON_TRANSPARENCY 
	button.Text = icon
	button.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.PALETTE.INDIGO_DUSK
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	return button
end

Builder.createTabButton = function(tabConfig, order, tabsContainer, getCurrentActiveTabButton, switchTabFunc)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabConfig.Name .. "Tab"
	tabButton.Size = UDim2.new(0, 45, 0, 45)
	tabButton.BackgroundColor3 = CONFIG.UI.TAB_INACTIVE_COLOR
	tabButton.BackgroundTransparency = CONFIG.UI.INACTIVE_TAB_TRANSPARENCY
	tabButton.Text = ""
	tabButton.TextSize = 18
	tabButton.Font = Enum.Font.GothamBold
	tabButton.LayoutOrder = order
	tabButton.ClipsDescendants = true
	tabButton.Parent = tabsContainer
    tabButton:SetAttribute("TabName", tabConfig.Name)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = tabButton
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "NeonStroke"
    stroke.Color = CONFIG.PALETTE.NIGHT_PLUM
    stroke.Thickness = 3 
    stroke.Transparency = 1 
    stroke.Parent = tabButton
    
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.Size = UDim2.new(0, 45, 1, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = tabConfig.Icon
	iconLabel.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	iconLabel.TextSize = 18
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.Parent = tabButton
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -50, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = tabConfig.Name
	nameLabel.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTransparency = 1
	nameLabel.Parent = tabButton
	
	tabButton.MouseEnter:Connect(function()
        if tabButton ~= getCurrentActiveTabButton() then 
            animateTabExpand(tabButton, UDim2.new(1, -10, 0, 45), 0, CONFIG.UI.TAB_HOVER_COLOR, CONFIG.UI.INACTIVE_TAB_TRANSPARENCY) 
            animateTabShadow(tabButton, true) 
        end
	end)
	
	tabButton.MouseLeave:Connect(function()
        if tabButton ~= getCurrentActiveTabButton() then
            animateTabExpand(tabButton, UDim2.new(0, 45, 0, 45), 1, CONFIG.UI.TAB_INACTIVE_COLOR, CONFIG.UI.INACTIVE_TAB_TRANSPARENCY) 
            animateTabShadow(tabButton, false) 
        end
	end)
    
    tabButton.MouseButton1Click:Connect(function() 
        switchTabFunc(tabButton)
    end)
	
	return tabButton
end

Builder.createToggleSwitch = function(name, globalFuncName, parent)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = name .. "Toggle"
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = parent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0.8, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = CONFIG.PALETTE.TEXT_SECONDARY 
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = buttonFrame
    
    local switchButton = Instance.new("TextButton")
    switchButton.Name = "Switch"
    switchButton.Size = UDim2.new(0, 50, 0, 25)
    switchButton.AnchorPoint = Vector2.new(1, 0.5)
    switchButton.Position = UDim2.new(1, -10, 0.5, 0)
    switchButton.BackgroundColor3 = CONFIG.PALETTE.MIDNIGHT_BLOOM
    switchButton.Text = ""
    switchButton.Parent = buttonFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0.5, 0)
    switchCorner.Parent = switchButton
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.BackgroundColor3 = CONFIG.PALETTE.NIGHT_PLUM 
    toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
    toggleIndicator.Position = UDim2.new(0, 5, 0.5, 0) 
    toggleIndicator.Parent = switchButton

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0.5, 0)
    indicatorCorner.Parent = toggleIndicator
    
    local isActive = false 
    
    local function updateSwitch(active)
        local targetColor = active and CONFIG.PALETTE.GREEN_BASE or CONFIG.PALETTE.MIDNIGHT_BLOOM 
        local targetPosition = active and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 5, 0.5, 0)

        TweenService:Create(switchButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {Position = targetPosition}):Play()
        
        if _G[globalFuncName] then
            _G[globalFuncName](active)
        else
            warn("Função global não encontrada: " .. globalFuncName)
        end
    end

    switchButton.MouseButton1Click:Connect(function()
        isActive = not isActive
        updateSwitch(isActive)
    end)
    
    updateSwitch(isActive) 
    
    return buttonFrame
end

Builder.createSection = function(sectionConfig, parent)
	local sectionContainer = Instance.new("Frame")
	sectionContainer.Name = sectionConfig.Name .. "Section"
	sectionContainer.Size = UDim2.new(1, 0, 0, 45) 
	sectionContainer.BackgroundColor3 = CONFIG.PALETTE.EBONY_GLOW
    sectionContainer.BorderSizePixel = 0
	sectionContainer.Parent = parent

    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 10)
    sectionCorner.Parent = sectionContainer
	
	local sectionTitle = Instance.new("TextLabel")
	sectionTitle.Name = "SectionTitle"
	sectionTitle.Size = UDim2.new(1, -20, 0, 20)
	sectionTitle.Position = UDim2.new(0, 10, 0, 10) 
	sectionTitle.BackgroundTransparency = 1
	sectionTitle.Text = string.upper(sectionConfig.Name)
	sectionTitle.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	sectionTitle.TextSize = 16
	sectionTitle.Font = Enum.Font.GothamBold
	sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	sectionTitle.Parent = sectionContainer
	
	local buttonsContainer = Instance.new("Frame")
	buttonsContainer.Name = "Buttons"
	buttonsContainer.Size = UDim2.new(1, -20, 1, -40) 
	buttonsContainer.Position = UDim2.new(0, 10, 0, 35) 
	buttonsContainer.BackgroundTransparency = 1
	buttonsContainer.Parent = sectionContainer
	
	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0, 8)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	buttonLayout.Parent = buttonsContainer

    buttonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = buttonLayout.AbsoluteContentSize.Y + 45 
        sectionContainer.Size = UDim2.new(1, 0, 0, contentHeight)
    end)
    
    if sectionConfig.Items then
        for _, item in ipairs(sectionConfig.Items) do
            if item.Type == "Toggle" then
                Builder.createToggleSwitch(item.Name, item.GlobalFunc, buttonsContainer)
            end
        end
    end

	return {Container = sectionContainer, Buttons = buttonsContainer}
end

Builder.setupTabContent = function(tabName, contentParent)
    local tabConfig = nil
    for _, config in ipairs(CONFIG.TABS_CONFIG) do
        if config.Name == tabName then
            tabConfig = config
            break
        end
    end
    if not tabConfig then return end
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = tabName .. "ScrollContent"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = CONFIG.PALETTE.INDIGO_DUSK
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y 
    scrollFrame.Parent = contentParent

    local container = Instance.new("Frame")
    container.Name = "SectionsContainer"
    container.Size = UDim2.new(1, -40, 1, -20)
    container.Position = UDim2.new(0, 20, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Name = "SectionsListLayout"
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 20) 
    listLayout.Parent = container

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    for order, sectionConfig in ipairs(tabConfig.Sections) do
        local section = Builder.createSection(sectionConfig, container)
        section.Container.LayoutOrder = order
    end
end


-- =================================================================
-- LÓGICA PRINCIPAL (STATE E CONTROLE)
-- =================================================================

-- Variáveis de Estado
local currentActiveTabButton = nil
local contentFrame = nil
local TAB_BUTTONS = {}

-- Funções Globais Placeholders (Serão sobrescritas pelo scripts.lua quando carregado)
_G.toggleNeonESPAura = function(active) warn("Função toggleNeonESPAura não carregada.") end
_G.toggleLineESP = function(active) warn("Função toggleLineESP não carregada.") end

local function getCurrentActiveTabButton()
    return currentActiveTabButton
end

local function switchTab(tabButton)
    local tabName = tabButton:GetAttribute("TabName")
    
    if currentActiveTabButton == tabButton then return end

    Builder.resetTabButton(currentActiveTabButton)

    Builder.animateTabExpand(
        tabButton, 
        UDim2.new(1, -10, 0, 45), 
        0, 
        CONFIG.UI.TAB_ACTIVE_COLOR, 
        0
    ) 
    animateTabShadow(tabButton, true) 
    currentActiveTabButton = tabButton
    
	for _, child in pairs(contentFrame:GetChildren()) do 
		if not child:IsA("UICorner") then
			child:Destroy()
		end
	end
	
	local tabTitle = Instance.new("TextLabel")
	tabTitle.Name = "TabTitle"
	tabTitle.Size = UDim2.new(1, -40, 0, 40)
	tabTitle.Position = UDim2.new(0, 20, 0, 20)
	tabTitle.BackgroundTransparency = 1
	tabTitle.Text = tabName
	tabTitle.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	tabTitle.TextSize = 24
	tabTitle.Font = Enum.Font.GothamBold
	tabTitle.TextXAlignment = Enum.TextXAlignment.Left
	tabTitle.Parent = contentFrame
	
	local tabContent = Instance.new("Frame")
	tabContent.Name = "TabContent"
	tabContent.Size = UDim2.new(1, 0, 1, -70)
	tabContent.Position = UDim2.new(0, 0, 0, 70)
	tabContent.BackgroundTransparency = 1
	tabContent.Parent = contentFrame
	
	Builder.setupTabContent(tabName, tabContent)
end


local function setupGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Interface"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = CONFIG.PALETTE.BLACK_SATIN
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    local tabsScrollFrame = Instance.new("ScrollingFrame")
    tabsScrollFrame.Name = "TabsScrollFrame"
    tabsScrollFrame.Size = UDim2.new(0.2, 0, 1, -80)
    tabsScrollFrame.Position = UDim2.new(0, 20, 0, 60)
    tabsScrollFrame.BackgroundTransparency = 1
    tabsScrollFrame.ScrollBarThickness = 6
    tabsScrollFrame.ScrollBarImageColor3 = CONFIG.PALETTE.INDIGO_DUSK
    tabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    tabsScrollFrame.Parent = mainFrame
    
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, -10, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = tabsScrollFrame
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 12)
    tabsLayout.Parent = tabsContainer

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y)
    end)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(0, 200, 0, 30)
    titleLabel.Position = UDim2.new(0, 20, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "nightfall hub"
    titleLabel.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame

    local topButtonsContainer = Instance.new("Frame")
    topButtonsContainer.Name = "TopButtons"
    topButtonsContainer.Size = UDim2.new(0, 100, 0, 30)
    topButtonsContainer.Position = UDim2.new(1, -120, 0, 20)
    topButtonsContainer.BackgroundTransparency = 1
    topButtonsContainer.Parent = mainFrame
    
    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    topLayout.Padding = UDim.new(0, 8)
    topLayout.Parent = topButtonsContainer

    local minimizeButton = Builder.createTopButton("Minimize", "—", topButtonsContainer)
    local closeButton = Builder.createTopButton("Close", "✕", topButtonsContainer)

    local contentFrameRef = Instance.new("Frame")
    contentFrameRef.Name = "ContentFrame"
    contentFrameRef.Size = UDim2.new(0.75, -40, 1, -80)
    contentFrameRef.Position = UDim2.new(0.25, 0, 0, 60)
    contentFrameRef.BackgroundColor3 = CONFIG.PALETTE.EBONY_GLOW
    contentFrameRef.BackgroundTransparency = CONFIG.UI.CONTENT_FRAME_TRANSPARENCY 
    contentFrameRef.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 12)
    contentCorner.Parent = contentFrameRef
    
    local firstTabButton = nil
    for order, tabConfig in ipairs(CONFIG.TABS_CONFIG) do
        local button = Builder.createTabButton(tabConfig, order, tabsContainer, getCurrentActiveTabButton, switchTab)
        if order == 1 then
            firstTabButton = button
        end
        TAB_BUTTONS[tabConfig.Name] = button
    end
    
    local isMinimized = false
    closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.8, 0, 0, 60)
            }):Play()
            tabsScrollFrame.Visible = false
            contentFrameRef.Visible = false
            titleLabel.Visible = true
            minimizeButton.Text = "□"
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.8, 0, 0.8, 0)
            }):Play()
            task.wait(0.1) 
            tabsScrollFrame.Visible = true
            contentFrameRef.Visible = true
            titleLabel.Visible = true
            minimizeButton.Text = "—"
        end
    end)

    return contentFrameRef, firstTabButton
end

contentFrame, firstTabButton = setupGUI() 
switchTab(firstTabButton)
