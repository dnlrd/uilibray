-- Test script to verify close and minimize buttons work
local UILibrary = require(script.Parent.UILibrary)

-- Create main container
local container = UILibrary.newContainer("TestGUI", UDim2.new(0, 250, 0, 300))

-- Create header with both minimize and close buttons
local header, buttons = UILibrary.createHeader(container.main, "Test GUI", true, true)

-- Create content container
local content = UILibrary.createContentContainer(container.main)

-- Add a test button
local testBtn = UILibrary.createButton(content, "Test Button", "🧪", 1)

-- Test button functionality
testBtn.MouseButton1Click:Connect(function()
    print("Test button clicked!")
end)

-- Minimize/Maximize functionality
local isMinimized = false
local originalSize = container.main.Size

local function minimizeGUI()
    isMinimized = true
    content.Visible = false
    container.main.Size = UDim2.new(0, 250, 0, 45)
    buttons.minimize.Text = "□"
    
    local minimizeTween = game:GetService("TweenService"):Create(container.main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 250, 0, 45)
    })
    minimizeTween:Play()
end

local function maximizeGUI()
    isMinimized = false
    content.Visible = true
    buttons.minimize.Text = "−"
    
    local maximizeTween = game:GetService("TweenService"):Create(container.main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = originalSize
    })
    maximizeTween:Play()
end

-- Connect minimize button
buttons.minimize.MouseButton1Click:Connect(function()
    if isMinimized then
        maximizeGUI()
    else
        minimizeGUI()
    end
end)

-- Connect close button
buttons.close.MouseButton1Click:Connect(function()
    UILibrary.fadeOut(container.main, 0.2, function()
        container.gui:Destroy()
    end)
end)

-- Make draggable
UILibrary.makeDraggable(container.main, header)

print("✨ Test GUI loaded! Try the minimize and close buttons!")
