Citizen.CreateThread(function()
	while true do
		SetDiscordAppId(949909010386124840)

        local first_name = exports["isPed"]:isPed("firstname")
        local last_name = exports["isPed"]:isPed("lastname")

        if first_name then
            SetRichPresence("Playing as " .. first_name .. " " .. last_name)
        else
            SetRichPresence(a .. "/48 | Milkin Snakes ")
        end

        SetDiscordRichPresenceAssetSmall('6e5') -- Name of the smaller image asset.
		SetDiscordRichPresenceAssetSmallText('RPFrogs Community Server')
        SetDiscordAppId(949909010386124840)
        SetDiscordRichPresenceAsset('1000x1000')
        SetDiscordRichPresenceAsset('logo')
        SetDiscordRichPresenceAction(0, 'RPFrogs Discord', 'https://discord.gg/rpfrog')
        SetDiscordRichPresenceAction(1, 'Play Now', 'fivem://62.171.159.104:30120')
      

		Citizen.Wait(60000)
	end
end)