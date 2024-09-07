-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variables
local targetDistance = 15 -- Distance for auto-movement checks
local notifyDuration = 5  -- Duration for temporary notifications
local activeNotifications = {}  -- Store active persistent notifications
local notifyVisible = {}        -- Track visibility of notifications

-- GUI setup for notifications
local ScreenGui = Instance.new("ScreenGui")
local NotifyLabel = Instance.new("TextLabel")

ScreenGui.Parent = player.PlayerGui

NotifyLabel.Size = UDim2.new(0, 400, 0, 50)
NotifyLabel.Position = UDim2.new(0.5, -200, 0.1, 0)
NotifyLabel.TextScaled = true
NotifyLabel.BackgroundTransparency = 0.5
NotifyLabel.TextStrokeTransparency = 0.5
NotifyLabel.Text = ""
NotifyLabel.Visible = false
NotifyLabel.Parent = ScreenGui

-- Function to show notifications
local function showNotification(message, color, keybind, persistent)
    -- Hide previous persistent notification if it exists
    if persistent and notifyVisible[keybind] then
        activeNotifications[keybind].Visible = false
        activeNotifications[keybind] = nil
        notifyVisible[keybind] = false
    end

    -- Show or update notification
    NotifyLabel.Text = message
    NotifyLabel.TextColor3 = color
    NotifyLabel.Visible = true

    if persistent then
        activeNotifications[keybind] = NotifyLabel
        notifyVisible[keybind] = true
    else
        task.delay(notifyDuration, function()
            NotifyLabel.Visible = false
        end)
    end
end

-- Function to move the character
local function moveCharacter(direction)
    local moveDistance = 10 -- Define movement distance
    local moveVector = Vector3.new(0, 0, 0)

    if direction == "forward" then
        moveVector = rootPart.CFrame.LookVector * moveDistance
    elseif direction == "backward" then
        moveVector = -rootPart.CFrame.LookVector * moveDistance
    elseif direction == "left" then
        moveVector = -rootPart.CFrame.RightVector * moveDistance
    elseif direction == "right" then
        moveVector = rootPart.CFrame.RightVector * moveDistance
    end

    local targetPosition = rootPart.Position + moveVector
    humanoid:MoveTo(targetPosition)
end

-- Function to handle automatic movement based on proximity
local function handleMovement(distance)
    if distance < 5 then
        showNotification("You're too close! Moving back...", Color3.fromRGB(255, 0, 0), "Distance", false)
        moveCharacter("backward")
    elseif distance < 10 then
        showNotification("Almost there! Adjusting position.", Color3.fromRGB(128, 0, 128), "Distance", false)
    else
        showNotification("Perfect! You're in the right spot.", Color3.fromRGB(0, 0, 255), "Distance", false)
    end
end

-- Function to determine color based on distance
local function getDistanceColor(distance)
    if distance < 5 then
        return Color3.fromRGB(255, 0, 0) -- Red for too close
    elseif distance < 10 then
        return Color3.fromRGB(128, 0, 128) -- Purple for almost
    else
        return Color3.fromRGB(0, 0, 255) -- Blue for right spot
    end
end

-- Coroutine for proximity monitoring
local function monitorProximity()
    while true do
        task.wait(1)
        local randomDistance = math.random(1, 15) -- Simulated distance
        local distanceColor = getDistanceColor(randomDistance)
        handleMovement(randomDistance)
    end
end

-- Function to handle special mode with Key 'A'
local function triggerTrialMemeMode()
    showNotification("Trialmeme Mode: Activating movement patterns!", Color3.fromRGB(114, 137, 218), "Trialmeme", false)
    moveCharacter("forward")
    task.wait(1)
    moveCharacter("backward")
end

-- Wrapper function for safe coroutine execution
local function safeExecuteMovement()
    local movementCoroutine = coroutine.create(function()
        xpcall(monitorProximity, function(err)
            warn("Error occurred: " .. tostring(err))
        end)
    end)
    coroutine.resume(movementCoroutine)
end

-- Key input handler
local function onKeyPress(input)
    local keyCode = input.KeyCode

    if keyCode == Enum.KeyCode.X then
        showNotification("X Key Pressed: Moving forward", Color3.fromRGB(114, 137, 218), "X", true)
        moveCharacter("forward")
    elseif keyCode == Enum.KeyCode.Z then
        showNotification("Z Key Pressed: Moving backward", Color3.fromRGB(114, 137, 218), "Z", true)
        moveCharacter("backward")
    elseif keyCode == Enum.KeyCode.Q then
        showNotification("Session Ended: Starting proximity check.", Color3.fromRGB(0, 255, 0), "Session", true)
        safeExecuteMovement()
    elseif keyCode == Enum.KeyCode.A then
        triggerTrialMemeMode()
    elseif keyCode == Enum.KeyCode.R then
        -- Clear all active notifications
        for key, label in pairs(activeNotifications) do
            if label then
                label.Visible = false
            end
        end
        activeNotifications = {}
        notifyVisible = {}
        showNotification("Notifications Cleared", Color3.fromRGB(255, 255, 255), "Clear", false)
    end
end

-- Set up key press listener
UserInputService.InputBegan:Connect(onKeyPress)

-- Start the coroutine-based movement system
safeExecuteMovement()
