local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Webhook proxy URLs
local DiscordProxyURL_A = "https://yellow-sky-7435.simbaerenhund.workers.dev/"
local DiscordProxyURL_B = "https://tight-sound-3e80.simbaerenhund.workers.dev/"

-- Pet groups
local groupA = {
    "Cocofanto Elefanto", "Girafa Celestre", "Gattatino Neonino", "Matteo", "Tralalero Tralala",
    "Los Crocodillitos", "Espresso Signora", "Odin Din Din Dun", "Statutino Libertino",
    "Trenostruzzo Turbo 3000", "Ballerino Lololo", "Piccione Macchina", "Tigroligre Frutonni",
    "Orcalero Orcala", "La Vacca Saturno Saturnita", "Chimpanzini Spiderini", "Los Tralaleritos",
    "Las Tralaleritas", "Las Vaquitas Saturnitas", "Graipuss Medussi"
}

local groupB = {
    "Graipuss Medussi", "Chicleteira Bicicletera", "La Grande Combinasion",
    "Nuclearo Dinossauro", "Garama and Madundung"
}

-- Get plot owner's name
local function getOwner(plot)
    local gui = plot:FindFirstChild("PlotSign") and plot.PlotSign:FindFirstChild("SurfaceGui")
    local label = gui and gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("TextLabel")
    return label and label.Text:match("^(.-)'s Base") or "Unknown"
end

-- Send embed to Discord via proxy
local function SendMessageEMBED(url, embed)
    local headers = { ["Content-Type"] = "application/json" }
    local body = HttpService:JSONEncode({ embeds = { embed } })

    local success, response = pcall(function()
        return request({
            Url = url,
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)

    print("Webhook to:", success and "✅ Sent" or "❌ Failed")
end

-- Pet scanner
local function scanPets(targetPets, webhookURL)
    local petsFound = {}
    local myPlot

    for _, plot in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
        local base = plot:FindFirstChild("YourBase", true)
        if base and base.Enabled then
            myPlot = plot.Name
            break
        end
    end

    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        if plot.Name ~= myPlot then
            local owner = getOwner(plot)
            for _, obj in ipairs(plot:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Name == "DisplayName" then
                    if table.find(targetPets, obj.Text) then
                        table.insert(petsFound, obj.Text .. " | Owner: " .. owner)
                    end
                end
            end
        end
    end

    local jobId = game.JobId
    local placeId = game.PlaceId

    if #petsFound > 0 then
        local petList = ""
        for _, pet in ipairs(petsFound) do
            petList = petList .. "✅ " .. pet .. "\n"
        end

        SendMessageEMBED(webhookURL, {
            title = "🧠 Brainrot Notify | Pulsar X",
            description = petList,
            color = 65280,
            fields = {
                {
                    name = "🆔 JOBID Mobile",
                    value = jobId,
                    inline = true
                },
                {
                    name = "🆔 JOBID PC",
                    value = jobId,
                    inline = true
                },
                {
                    name = "📜 Join Script Mobile",
                    value = ("```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%d, \"%s\", game.Players.LocalPlayer)\n```"):format(placeId, jobId),
                    inline = false
                },
                {
                    name = "📜 Join Script PC",
                    value = ("```lua\ngame:GetService(\"TeleportService\"):TeleportToPlaceInstance(%d, \"%s\", game.Players.LocalPlayer)\n```"):format(placeId, jobId),
                    inline = false
                },
                {
                    name = "🔗 Join Link",
                    value = ("[Click to Join](https://fern.wtf/joiner?placeId=%d&gameInstanceId=%s)"):format(placeId, jobId),
                    inline = false
                }
            },
            footer = { text = "Comp Hub Pet Finder" }
        })
    else
        SendMessageEMBED(webhookURL, {
            title = "🐾 Comp Hub - No Pets Found",
            description = "No pets from the list were found in this server.",
            color = 16711680,
            fields = {},
            footer = { text = "Comp Hub Pet Finder" }
        })
    end
end

-- Scan both groups
scanPets(groupA, DiscordProxyURL_A)
scanPets(groupB, DiscordProxyURL_B)
