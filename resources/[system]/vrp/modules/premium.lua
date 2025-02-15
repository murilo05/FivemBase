-----------------------------------------------------------------------------------------------------------------------------------------
-- SETPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.setPremium(user_id)
	vRP.execute("accounts/setPremium",{ discord = vRP.userInfos[user_id]["discord"], premium = os.time() + 2592000, priority = 50 })

	if vRP.userInfos[user_id] then
		vRP.userInfos[user_id]["premium"] = parseInt(os.time() + 2592000)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADEPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.upgradePremium(user_id)
	vRP.execute("accounts/updatePremium",{ discord = vRP.userInfos[user_id]["discord"] })

	if vRP.userInfos[user_id] then
		vRP.userInfos[user_id]["premium"] = vRP.userInfos[user_id]["premium"] + 2592000
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.userPremium(user_id)
	if vRP.userInfos[user_id] then
		if vRP.userInfos[user_id]["premium"] >= os.time() then
			return true
		end
	else
		local identity = vRP.query("characters/getUsers",{ id = user_id })
		if identity[1] then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCORDPREMIUM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.discordPremium(discord)
	local infoAccount = vRP.infoAccount(discord)
	if infoAccount and infoAccount["premium"] >= os.time() then
		return true
	end

	return false
end