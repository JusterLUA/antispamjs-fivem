local function GetIdentifiersServer(source)  
    local identifiers = {}
    local playerIdentifiers = GetPlayerIdentifiers(source)
    for _, v in pairs(playerIdentifiers) do
        local before, after = playerIdentifiers[_]:match("([^:]+):([^:]+)")
        identifiers[before] = playerIdentifiers[_]
    end
    return identifiers
end

local function sendLogs(webhook, title, message)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "SpamJS - Log", 
        embeds = {{
            ["title"] = title,
            ["description"] = "".. message .."",
            ["footer"] = {
                ["text"] = "SpamJS • "..os.date("%x %X %p"),
            },
        }}, 
    }), { 
        ['Content-Type'] = 'application/json' 
    })
end


for i = 1, #config.Eventjs, 1 do
    RegisterNetEvent(config.Eventjs[i])
    AddEventHandler(config.Eventjs[i], function()
        local source = source
        if GetIdentifiersServer(source) == nil then return end
        local license, licenseid = GetIdentifiersServer(source)["license"]:match("([^:]+):([^:]+)")
		if not delayPlayer[licenseid] then delayPlayer[licenseid] = {} end
		local limit = delayPlayer[licenseid][config.Eventjs[i]]

		if not limit then
			delayPlayer[licenseid][config.Eventjs[i]] = 1
			return
		else
            delayPlayer[licenseid][config.Eventjs[i]] = (delayPlayer[licenseid][config.Eventjs[i]] or 0) + 1
		end

		if delayPlayer[licenseid][config.Eventjs[i]] > config.delayEvent then
            sendLogs(Config.webhookjs, "Spam JS", "Le joueur "..GetPlayerName(source).." vient de se faire détecter pour SpamJS !\nLicenseID : "..licenseid)
            DropPlayer(source, Config.KickMessage)
            -- Vous pouvez add votre triggers de ban ici ! 
		end
    end)
end

AddEventHandler('playerDropped', function()
    local source = source
    local license, licenseid = GetIdentifiersServer(source)["license"]:match("([^:]+):([^:]+)")
    if license == nil or licenseid == nil then return end

	if delayPlayer[licenseid] then
		delayPlayer[licenseid] = nil
	end
end)