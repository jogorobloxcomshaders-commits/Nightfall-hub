-- Interface-Builder.lua

local Builder = {}

local TweenService = game:GetService("TweenService")
local TABS_CONFIG = nil
local CONFIG = nil

---
-- FUNÇÕES INTERNAS DE ANIMAÇÃO E ESTADO
---

local function animateTabShadow(tabButton, active)
    local stroke = tabButton:FindFirstChild("NeonStroke")

    if not stroke then return end

    if active then
        TweenService:Create(stroke, TweenInfo.new(0.3), {
            Color = CONFIG.PALETTE.NIGHT_PLUM, 
            Transparency = 0.3 
        }):Play()
    else
        TweenService:Create(stroke, TweenInfo.new(0.3), {
            Color = CONFIG.PALETTE.NIGHT_PLUM,
            Transparency = 1 
        }):Play()
    end
end

local function animateTabExpand(tabButton, targetSize, targetTransparency, targetColor, bgTransparency)
    TweenService:Create(tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = targetSize,
        BackgroundColor3 = targetColor,
        BackgroundTransparency = bgTransparency 
    }):Play()
    
    local nameLabel = tabButton:FindFirstChild("NameLabel")
    if nameLabel then
        TweenService:Create(nameLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            TextTransparency = targetTransparency
        }):Play()
    end
end

Builder.resetTabButton = function(button)
    if button then
        animateTabExpand(
            button, 
            UDim2.new(0, 45, 0, 45), 
            1, 
            CONFIG.UI.TAB_INACTIVE_COLOR, 
            CONFIG.UI.INACTIVE_TAB_TRANSPARENCY
        ) 
        animateTabShadow(button, false) 
    end
end

---
-- FUNÇÕES DE CRIAÇÃO (EXPOSTAS)
---

function Builder.createTopButton(name, icon, parent)
	local button = Instance.new("TextButton")
	button.Name = name .. "Button"
	button.Size = UDim2.new(0, 40, 0, 30)
	button.BackgroundColor3 = CONFIG.PALETTE.EBONY_GLOW
	button.BackgroundTransparency = CONFIG.UI.TOP_BUTTON_TRANSPARENCY 
	button.BorderSizePixel = 0
	button.Text = icon
	button.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "BorderStroke"
    stroke.Color = CONFIG.PALETTE.INDIGO_DUSK
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button
	
	return button
end

function Builder.createTabButton(tabConfig, order, tabsContainer, switchTabFunc)
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabConfig.Name .. "Tab"
	tabButton.Size = UDim2.new(0, 45, 0, 45)
	tabButton.BackgroundColor3 = CONFIG.UI.TAB_INACTIVE_COLOR
	tabButton.BackgroundTransparency = CONFIG.UI.INACTIVE_TAB_TRANSPARENCY
	tabButton.Text = ""
	tabButton.TextColor3 = CONFIG.PALETTE.TEXT_PRIMARY -- Cor do ícone
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
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = tabButton
    
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "IconLabel"
	iconLabel.Size = UDim2.new(0, 45, 1, 0)
	iconLabel.Position = UDim2.new(0, 0, 0, 0)
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
        if tabButton ~= switchTabFunc() then -- Pega o currentActiveTabButton via callback
            animateTabExpand(tabButton, UDim2.new(1, -10, 0, 45), 0, CONFIG.UI.TAB_HOVER_COLOR, CONFIG.UI.INACTIVE_TAB_TRANSPARENCY) 
            animateTabShadow(tabButton, true) 
        end
	end)
	
	tabButton.MouseLeave:Connect(function()
        if tabButton ~= switchTabFunc() then
            animateTabExpand(tabButton, UDim2.new(0, 45, 0, 45), 1, CONFIG.UI.TAB_INACTIVE_COLOR, CONFIG.UI.INACTIVE_TAB_TRANSPARENCY) 
            animateTabShadow(tabButton, false) 
        end
	end)
    
    tabButton.MouseButton1Click:Connect(function() 
        switchTabFunc(tabButton) -- Chama a função de switch principal
    end)
	
	return tabButton
end

function Builder.createSection(sectionConfig, parent)
	local sectionContainer = Instance.new("Frame")
	sectionContainer.Name = sectionConfig.Name .. "Section"
	sectionContainer.Size = UDim2.new(1, 0, 0, 45) -- Tamanho inicial pequeno
	sectionContainer.BackgroundTransparency = 0
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

    -- Atualiza o tamanho do Container com base no conteúdo
    buttonLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = buttonLayout.AbsoluteContentSize.Y + 45 
        sectionContainer.Size = UDim2.new(1, 0, 0, contentHeight)
    end)
    
    -- Cria os itens de UI dentro da seção
    if sectionConfig.Items then
        for _, item in ipairs(sectionConfig.Items) do
            if item.Type == "Toggle" then
                Builder.createToggleSwitch(item.Name, item.GlobalFunc, buttonsContainer)
            end
            -- Adicionar outros tipos de UI (Slider, Textbox, etc) aqui
        end
    end

	return {Container = sectionContainer, Buttons = buttonsContainer}
end

function Builder.createToggleSwitch(name, globalFuncName, parent)
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
    switchButton.BorderSizePixel = 0
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
    toggleIndicator.BorderSizePixel = 0
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
        
        -- Garante que o estado global seja atualizado
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
    
    -- Estado inicial
    updateSwitch(isActive) 
    
    return buttonFrame
end


---
-- FUNÇÃO DE INICIALIZAÇÃO
---

-- Esta função é chamada pelo Main para injetar as dependências
function Builder.init(configTable)
    CONFIG = configTable
    TABS_CONFIG = CONFIG.TABS_CONFIG
    
    -- Função que constrói o conteúdo da aba, usando o TABS_CONFIG
    Builder.setupTabContent = function(tabName, contentParent)
        local tabConfig = nil
        for _, config in ipairs(TABS_CONFIG) do
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
        
        -- Cria as seções dinamicamente
        for order, sectionConfig in ipairs(tabConfig.Sections) do
            local section = Builder.createSection(sectionConfig, container)
            section.Container.LayoutOrder = order
        end

    end
    
    return Builder
end

return Builder
