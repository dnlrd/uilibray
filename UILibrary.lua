-- UILibrary.lua - Reusable UI Components for Roblox
-- A modern, minimal UI library with smooth animations and clean design

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Constants
local COLORS = {
    BACKGROUND = Color3.fromRGB(18, 18, 18),
    HEADER = Color3.fromRGB(25, 25, 25),
    BUTTON = Color3.fromRGB(28, 28, 28),
    BUTTON_HOVER = Color3.fromRGB(38, 38, 38),
    ACCENT = Color3.fromRGB(120, 120, 255),
    TEXT_PRIMARY = Color3.fromRGB(240, 240, 240),
    TEXT_SECONDARY = Color3.fromRGB(220, 220, 220),
    TEXT_MUTED = Color3.fromRGB(180, 180, 180),
    CLOSE_HOVER = Color3.fromRGB(200, 60, 60),
    SHADOW = Color3.fromRGB(0, 0, 0)
}

local FONTS = {
    PRIMARY = Enum.Font.GothamBold,
    SECONDARY = Enum.Font.Gotham
}

-- Utility Functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createShadow(parent, size, transparency)
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, size, 1, size)
    shadow.Position = UDim2.new(0, -size/2, 0, -size/2)
    shadow.BackgroundColor3 = COLORS.SHADOW
    shadow.BackgroundTransparency = transparency or 0.7
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    createCorner(shadow, 14)
    return shadow
end

-- Main Container Class
function UILibrary.newContainer(name, size, position)
    local container = {}
    
    -- Remove old GUI if it exists
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Create main container
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = size or UDim2.new(0, 220, 0, 320)
    mainContainer.Position = position or UDim2.new(0, 30, 0.5, -160)
    mainContainer.BackgroundColor3 = COLORS.BACKGROUND
    mainContainer.BorderSizePixel = 0
    mainContainer.Active = true
    mainContainer.Parent = screenGui
    
    createCorner(mainContainer, 12)
    createShadow(mainContainer, 8, 0.7)
    
    container.gui = screenGui
    container.main = mainContainer
    container.isMinimized = false
    container.originalSize = mainContainer.Size
    
    return container
end

-- Header Component
function UILibrary.createHeader(parent, title, showMinimize, showClose)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = COLORS.HEADER
    header.BorderSizePixel = 0
    header.Parent = parent
    
    createCorner(header, 12)
    
    -- Header bottom mask
    local headerMask = Instance.new("Frame")
    headerMask.Size = UDim2.new(1, 0, 0, 12)
    headerMask.Position = UDim2.new(0, 0, 1, -12)
    headerMask.BackgroundColor3 = COLORS.HEADER
    headerMask.BorderSizePixel = 0
    headerMask.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Console"
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.Font = FONTS.PRIMARY
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local buttons = {}
    
    -- Minimize button
    if showMinimize then
        local minimizeBtn = Instance.new("TextButton")
        minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
        minimizeBtn.Position = UDim2.new(1, -68, 0.5, -14)
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        minimizeBtn.Text = "−"
        minimizeBtn.TextColor3 = COLORS.TEXT_SECONDARY
        minimizeBtn.Font = FONTS.SECONDARY
        minimizeBtn.TextSize = 16
        minimizeBtn.BorderSizePixel = 0
        minimizeBtn.Parent = header
        
        createCorner(minimizeBtn, 6)
        buttons.minimize = minimizeBtn
    end
    
    -- Close button
    if showClose then
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = COLORS.TEXT_SECONDARY
        closeBtn.Font = FONTS.SECONDARY
        closeBtn.TextSize = 14
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = header
        
        createCorner(closeBtn, 6)
        buttons.close = closeBtn
    end
    
    return header, buttons
end

-- Button Component
function UILibrary.createButton(parent, name, icon, order)
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, 0, 0, 48)
    btnContainer.BackgroundTransparency = 1
    btnContainer.LayoutOrder = order or 1
    btnContainer.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = COLORS.BUTTON
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = btnContainer
    
    createCorner(btn, 10)
    
    -- Icon
    if icon then
        local iconLabel = Instance.new("TextLabel")
        iconLabel.Size = UDim2.new(0, 24, 1, 0)
        iconLabel.Position = UDim2.new(0, 18, 0, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = COLORS.ACCENT
        iconLabel.Font = FONTS.SECONDARY
        iconLabel.TextSize = 18
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.Parent = btn
    end
    
    -- Text
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -60, 1, 0)
    textLabel.Position = UDim2.new(0, 48, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = COLORS.TEXT_SECONDARY
    textLabel.Font = FONTS.SECONDARY
    textLabel.TextSize = 15
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = btn
    
    -- Hover animations
    local hoverTween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = COLORS.BUTTON_HOVER
    })
    local normalTween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = COLORS.BUTTON
    })
    
    btn.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    btn.MouseLeave:Connect(function()
        normalTween:Play()
    end)
    
    return btn
end

-- Window Component
function UILibrary.createWindow(name, size, position)
    local window = Instance.new("Frame")
    window.Size = size or UDim2.new(0, 350, 0, 300)
    window.Position = position or UDim2.new(0.5, -175, 0.5, -150)
    window.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    window.BorderSizePixel = 0
    window.Visible = false
    window.Active = true
    window.Parent = game:GetService("CoreGui")
    
    createCorner(window, 12)
    createShadow(window, 12, 0.6)
    
    return window
end

-- Settings Control Components
function UILibrary.createToggle(parent, name, defaultValue, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = FONTS.PRIMARY
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -40, 0, 25)
    toggle.BackgroundColor3 = defaultValue and COLORS.ACCENT or Color3.fromRGB(60, 60, 60)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = container
    
    createCorner(toggle, 10)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = defaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggle
    
    createCorner(toggleKnob, 8)
    
    local isOn = defaultValue or false
    
    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        local newColor = isOn and COLORS.ACCENT or Color3.fromRGB(60, 60, 60)
        local newPos = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
        TweenService:Create(toggleKnob, TweenService:Create(0.2), {Position = newPos}):Play()
    end)
    
    return toggle, function() return isOn end
end

function UILibrary.createSlider(parent, name, minValue, maxValue, defaultValue, suffix, order)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order or 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = FONTS.PRIMARY
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -130, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    createCorner(sliderBg, 2)
    
    local currentValue = defaultValue or minValue
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.ACCENT
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    createCorner(sliderFill, 2)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80, 0, 20)
    valueLabel.Position = UDim2.new(1, -80, 0, 15)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(currentValue) .. (suffix or "")
    valueLabel.TextColor3 = COLORS.TEXT_MUTED
    valueLabel.Font = FONTS.SECONDARY
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    return sliderBg, function() return currentValue end
end

-- Dragging functionality
function UILibrary.makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Animation helpers
function UILibrary.fadeIn(frame, duration)
    frame.BackgroundTransparency = 1
    frame.Visible = true
    local fadeIn = TweenService:Create(frame, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0
    })
    fadeIn:Play()
    return fadeIn
end

function UILibrary.fadeOut(frame, duration, callback)
    local fadeOut = TweenService:Create(frame, TweenInfo.new(duration or 0.2), {
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    if callback then
        fadeOut.Completed:Connect(callback)
    end
    return fadeOut
end

-- Content container with layout
function UILibrary.createContentContainer(parent)
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 1, -45)
    contentContainer.Position = UDim2.new(0, 0, 0, 45)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = parent
    
    -- Layout for buttons
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Padding = UDim2.new(0, 12)
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Parent = contentContainer
    
    -- Padding
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 25)
    contentPadding.PaddingLeft = UDim.new(0, 18)
    contentPadding.PaddingRight = UDim.new(0, 18)
    contentPadding.PaddingBottom = UDim.new(0, 25)
    contentPadding.Parent = contentContainer
    
    return contentContainer
end

-- Scrolling content container
function UILibrary.createScrollingContainer(parent, size, position)
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = size or UDim2.new(1, -20, 1, -60)
    scrollingFrame.Position = position or UDim2.new(0, 10, 0, 50)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim2.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollingFrame
    
    -- Auto-resize canvas
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    return scrollingFrame
end

return UILibrary
