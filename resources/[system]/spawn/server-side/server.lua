-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("spawn",cRP)
vCLIENT = Tunnel.getInterface("spawn")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local charActived = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.initSystem()
	local source = source
	local characterList = {}
	local discord = vRP.getIdentities(source)
	local consult = vRP.query("characters/getCharacters",{ discord = discord })

	if consult[1] then
		for k,v in pairs(consult) do
			table.insert(characterList,{ user_id = v["id"], name = v["name"].." "..v["name2"], locate = v["locate"] })
		end
	end

	return characterList
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.characterChosen(user_id)
	local source = source
	vRP.characterChosen(source,user_id,nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCHARACTERS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.getCharacters()
	local source = source
	local getCharacters = {}
	local discord = vRP.getIdentities(source)
	local consult = vRP.query("characters/getCharacters",{ discord = discord })

	if consult[1] then
		for k,v in pairs(consult) do
			local userTablesSkin = vRP.userData(v["id"],"Datatable")
			local userTablesBarber = vRP.userData(v["id"],"Barbershop")
			local userTablesClotings = vRP.userData(v["id"],"Clothings")
			local userTablesTatto = vRP.userData(v["id"],"Tatuagens")
			
			table.insert(getCharacters,{ skin = userTablesSkin["skin"], barber = userTablesBarber, clothes = userTablesClotings, tattoos = userTablesTatto })
		end
	end

	return getCharacters
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.newCharacter(name,name2,sex,locate)
	local source = source
	if charActived[source] == nil then
		charActived[source] = true

		local discord = vRP.getIdentities(source)
		local infoAccount = vRP.infoAccount(discord)
		local amountCharacters = parseInt(infoAccount["chars"])
		local myChars = vRP.query("characters/countPersons",{ discord = discord })

		if vRP.discordPremium(discord) then
			amountCharacters = amountCharacters + 1
		end

		if parseInt(amountCharacters) <= parseInt(myChars[1]["qtd"]) then
			TriggerClientEvent("Notify",source,"amarelo","Limite de personagens atingido.",3000)
			charActived[source] = nil
			return
		end

		if sex == "mp_m_freemode_01" then
            vRP.execute("characters/newCharacter",{ discord = discord, name = name, name2 = name2, locate = locate, sex = "M", phone = vRP.generatePhone(), serial = vRP.generateSerial(), blood = math.random(4), bank = 2000 })
        else
            vRP.execute("characters/newCharacter",{ discord = discord, name = name, name2 = name2, locate = locate, sex = "F", phone = vRP.generatePhone(), serial = vRP.generateSerial(), blood = math.random(4), bank = 2000 })
        end
		local consult = vRP.query("characters/lastCharacters",{ discord = discord })
		if consult[1] then
			vRP.characterChosen(source,consult[1]["id"],sex,locate)
			vCLIENT.closeNew(source)
		end

		charActived[source] = nil
	end
end