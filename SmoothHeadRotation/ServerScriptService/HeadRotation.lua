local UpdateRate = 1/20

local HeadRotationRemote = Instance.new("RemoteEvent")
HeadRotationRemote.Name = "HeadRotationRemote"

local Rotations = setmetatable({}, {__mode = "k"})
HeadRotationRemote.OnServerEvent:Connect(function (Plr, Rotation)
    Rotations[Plr] = Rotation
end)

HeadRotationRemote.Parent = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")

function HandleCharacter(Character)
    local OldHead = Character:WaitForChild("Head")
    local NewHead = OldHead:Clone()
    NewHead:ClearAllChildren()
    NewHead.Massless = true
    NewHead.Transparency = 1
    NewHead.Name = "NewHead"
    NewHead.Parent = OldHead.Parent

    local OldWeld = Character:FindFirstChild("Neck", true)
    while not OldWeld do OldWeld = Character:FindFirstChild("Neck", true) end
    local NewWeld = OldWeld:Clone()
    NewWeld.Part1 = NewHead
    NewWeld.Name = "NewNeck"
    NewWeld.Parent = OldWeld.Parent
end

function PlayerAdded(Plr)
    HandleCharacter(Plr.Character or Plr.CharacterAdded:Wait())
    Plr.CharacterAdded:Connect(HandleCharacter)
end

Players.PlayerAdded:Connect(PlayerAdded)
for _, Plr in ipairs(Players:GetPlayers()) do
    PlayerAdded(Plr)
end

while wait(UpdateRate) do
    if next(Rotations) then
        local Rots
        for _, Plr in ipairs(Players:GetPlayers()) do
            if Rotations[Plr] then
                local Rots = {}
                for b, c in pairs(Rotations) do
                    if b ~= Plr then
                        Rots[#Rots + 1] = {b, c}
                    end
                end

                if next(Rots) then
                    HeadRotationRemote:FireClient(Plr, Rots)
                end
            else
                if not Rots then
                    Rots = {}
                    for b, c in pairs(Rotations) do
                        Rots[#Rots + 1] = {b, c}
                    end
                end

                HeadRotationRemote:FireClient(Plr, Rots)
            end
        end

        Rotations = setmetatable({}, {__mode = "k"})
    end
end