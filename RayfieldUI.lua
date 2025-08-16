-- Rayfield-like UI Library for Roblox
local Rayfield = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Colors
local COLORS = {
    BACKGROUND = Color3.fromRGB(18, 18, 18),
    HEADER = Color3.fromRGB(25, 25, 25),
    BUTTON = Color3.fromRGB(28, 28, 28),
    BUTTON_HOVER = Color3.fromRGB(38, 38, 38),
    ACCENT = Color3.fromRGB(120, 120, 255),
    TEXT_PRIMARY = Color3.fromRGB(240, 240, 240),
    TEXT_SECONDARY = Color3.fromRGB(220, 220, 220)
}

-- Utility Functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

-- Main Window
function Rayfield.newWindow(name, size, position)
    local window = {}
    
    -- Remove old GUI
    local old = game.CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Main container
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = size or UDim2.new(0, 350, 0, 500)
    mainContainer.Position = position or UDim2.new(0.5, -175, 0.5, -250)
    mainContainer.BackgroundColor3 = COLORS.BACKGROUND
    mainContainer.BorderSizePixel = 0
    mainContainer.Active = true
    mainContainer.Parent = screenGui
    
    createCorner(mainContainer, 12)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = COLORS.HEADER
    header.BorderSizePixel = 0
    header.Parent = mainContainer
    
    createCorner(header, 12)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name or "Rayfield"
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = COLORS.TEXT_SECONDARY
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = header
    
    createCorner(closeBtn, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Content container
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -20, 1, -65)
    contentContainer.Position = UDim2.new(0, 10, 0, 55)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.ScrollBarThickness = 4
    contentContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentContainer.Parent = mainContainer
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim2.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = contentContainer
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Dragging
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainContainer.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    window.gui = screenGui
    window.main = mainContainer
    window.content = contentContainer
    
    return window
end

-- Section
function Rayfield.createSection(window, name)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundTransparency = 1
    section.Parent = window.content
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = name
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = section
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 0, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 25)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = section
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim2.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, contentLayout.AbsoluteContentSize.Y + 25)
    end)
    
    return contentFrame
end

-- Button
function Rayfield.createButton(section, name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = COLORS.BUTTON
    button.Text = name
    button.TextColor3 = COLORS.TEXT_SECONDARY
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = section
    
    createCorner(button, 8)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.BUTTON_HOVER
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.BUTTON
        }):Play()
    end)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

-- Toggle
function Rayfield.createToggle(section, name, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -40, 0.5, -10)
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
        TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = newPos}):Play()
        
        if callback then
            callback(isOn)
        end
    end)
    
    return toggle, function() return isOn end
end

-- Slider
function Rayfield.createSlider(section, name, minValue, maxValue, defaultValue, suffix, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 80, 0, 20)
    valueLabel.Position = UDim2.new(1, -80, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or minValue) .. (suffix or "")
    valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 4)
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
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderBg
    
    createCorner(sliderKnob, 6)
    
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize
            
            local relativePos = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            currentValue = minValue + (maxValue - minValue) * relativePos
            
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            sliderKnob.Position = UDim2.new(relativePos, -6, 0.5, -6)
            valueLabel.Text = tostring(math.floor(currentValue)) .. (suffix or "")
            
            if callback then
                callback(currentValue)
            end
        end
    end)
    
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return sliderBg, function() return currentValue end
end

-- Dropdown
function Rayfield.createDropdown(section, name, options, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0, 120, 0, 25)
    dropdown.Position = UDim2.new(1, -120, 0.5, -12.5)
    dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropdown.Text = defaultValue or options[1] or "Select"
    dropdown.TextColor3 = COLORS.TEXT_SECONDARY
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 12
    dropdown.BorderSizePixel = 0
    dropdown.Parent = container
    
    createCorner(dropdown, 6)
    
    local dropdownList = Instance.new("Frame")
    dropdownList.Size = UDim2.new(0, 120, 0, 0)
    dropdownList.Position = UDim2.new(1, -120, 1, 5)
    dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.Parent = container
    
    createCorner(dropdownList, 6)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim2.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = dropdownList
    
    local isOpen = false
    local currentValue = defaultValue or options[1]
    
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Size = UDim2.new(1, -4, 0, 25)
        optionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        optionBtn.Text = option
        optionBtn.TextColor3 = COLORS.TEXT_SECONDARY
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 12
        optionBtn.BorderSizePixel = 0
        optionBtn.LayoutOrder = i
        optionBtn.Parent = dropdownList
        
        createCorner(optionBtn, 4)
        
        optionBtn.MouseButton1Click:Connect(function()
            currentValue = option
            dropdown.Text = option
            isOpen = false
            dropdownList.Visible = false
            
            if callback then
                callback(option)
            end
        end)
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropdownList.Size = UDim2.new(0, 120, 0, listLayout.AbsoluteContentSize.Y + 4)
    end)
    
    dropdown.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        dropdownList.Visible = isOpen
    end)
    
    return dropdown, function() return currentValue end
end

-- Text Input
function Rayfield.createInput(section, name, placeholder, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 25)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.Text = defaultValue or ""
    input.PlaceholderText = placeholder or "Enter text..."
    input.TextColor3 = COLORS.TEXT_SECONDARY
    input.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.BorderSizePixel = 0
    input.Parent = container
    
    createCorner(input, 6)
    
    input.FocusLost:Connect(function()
        if callback then
            callback(input.Text)
        end
    end)
    
    return input
end

-- Keybind
function Rayfield.createKeybind(section, name, defaultKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = section
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT_SECONDARY
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keybind = Instance.new("TextButton")
    keybind.Size = UDim2.new(0, 80, 0, 25)
    keybind.Position = UDim2.new(1, -80, 0.5, -12.5)
    keybind.BackgroundColor3 = COLORS.BUTTON
    keybind.Text = defaultKey or "None"
    keybind.TextColor3 = COLORS.TEXT_SECONDARY
    keybind.Font = Enum.Font.Gotham
    keybind.TextSize = 12
    keybind.BorderSizePixel = 0
    keybind.Parent = container
    
    createCorner(keybind, 6)
    
    local currentKey = defaultKey
    local listening = false
    
    keybind.MouseButton1Click:Connect(function()
        if not listening then
            listening = true
            keybind.Text = "Press any key..."
            keybind.BackgroundColor3 = COLORS.ACCENT
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    currentKey = input.KeyCode.Name
                    keybind.Text = currentKey
                    keybind.BackgroundColor3 = COLORS.BUTTON
                    listening = false
                    connection:Disconnect()
                    
                    if callback then
                        callback(currentKey)
                    end
                end
            end)
        end
    end)
    
    return keybind, function() return currentKey end
end

-- Notification
function Rayfield.createNotification(title, message, duration, notificationType)
    duration = duration or 5
    notificationType = notificationType or "Info"
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = COLORS.BACKGROUND
    notification.BorderSizePixel = 0
    notification.Parent = game:GetService("CoreGui")
    
    createCorner(notification, 8)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = COLORS.TEXT_PRIMARY
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 15, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = COLORS.TEXT_SECONDARY
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    task.delay(duration, function()
        notification:Destroy()
    end)
    
    return notification
end

-- Example usage
function Rayfield.createExampleUI()
    local window = Rayfield.newWindow("Example UI", UDim2.new(0, 400, 0, 600))
    
    local mainSection = Rayfield.createSection(window, "Main Controls")
    
    Rayfield.createButton(mainSection, "Click Me!", function()
        Rayfield.createNotification("Success", "Button clicked!", 3, "Success")
    end)
    
    local toggle, getToggleValue = Rayfield.createToggle(mainSection, "Enable Feature", false, function(value)
        print("Toggle:", value)
    end)
    
    local slider, getSliderValue = Rayfield.createSlider(mainSection, "Volume", 0, 100, 50, "%", function(value)
        print("Slider:", value)
    end)
    
    local dropdown, getDropdownValue = Rayfield.createDropdown(mainSection, "Select Option", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(value)
        print("Dropdown:", value)
    end)
    
    local input = Rayfield.createInput(mainSection, "Text Input", "Enter your name...", "", function(value)
        print("Input:", value)
    end)
    
    local keybind, getKeybindValue = Rayfield.createKeybind(mainSection, "Toggle UI", "RightControl", function(key)
        print("Keybind pressed:", key)
    end)
    
    return window
end

return Rayfield
