-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("spawn",cRP)
vSERVER = Tunnel.getInterface("spawn")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Peds = {}
local spawnLocates = {}
local brokenCamera = false
local Camera = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- PEDCOORDS
-----------------------------------------------------------------------------------------------------------------------------------------
local pedCoords = {
	{ -766.7,328.32,211.4,269.3,"random@shop_tattoo","_idle_a" },
	{ -766.45,327.41,211.4,269.3,"anim@heists@heist_corona@single_team","single_team_loop_boss" },
	{ -766.45,329.45,211.4,269.3,"jh_1_ig_3-2","cs_jewelass_dual-2" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- OTHERLOCATES
-----------------------------------------------------------------------------------------------------------------------------------------
local otherLocates = {
	{ 102.78,-1068.54,29.22,"Garagem Principal" },
	{ -466.4,-354.77,34.26,"Hospital" },
	{ 129.64,-1712.51,29.25,"Barbearia" },
	{ -1178.88,-884.72,13.85,"Burguer Shot" },
	{ 597.05,2743.02,42.06,"Sandy Shores" },
	{ -138.38,6355.26,31.49,"Paleto Bay" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONCLIENTRESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onClientResourceStart",function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end

	DoScreenFadeOut(0)
	ShutdownLoadingScreen()

	Citizen.Wait(1000)

	local ped = PlayerPedId()
	SetEntityCoords(ped,-764.43,327.96,211.4,0,0,1)
	LocalPlayer["state"]["Invisible"] = true
	SetEntityVisible(ped,false,false)
	FreezeEntityPosition(ped,true)
	SetEntityInvincible(ped,true)
	SetEntityHealth(ped,101)

	Citizen.Wait(1000)

	local Characters = vSERVER.getCharacters()
	if parseInt(#Characters) > 0 then
		for k,v in pairs(Characters) do
			RequestModel(v["skin"])
			while not HasModelLoaded(v["skin"]) do
				Citizen.Wait(1)
			end

			if HasModelLoaded(v["skin"]) then
				Peds[k] = CreatePed(4,v["skin"],pedCoords[k][1],pedCoords[k][2],pedCoords[k][3] - 1,pedCoords[k][4],false,false)
				SetEntityInvincible(Peds[k],true)
				FreezeEntityPosition(Peds[k],true)
				SetBlockingOfNonTemporaryEvents(Peds[k],true)
				SetModelAsNoLongerNeeded(v["skin"])

				RequestAnimDict(pedCoords[k][5])
				while not HasAnimDictLoaded(pedCoords[k][5]) do
					Citizen.Wait(1)
				end

				TaskPlayAnim(Peds[k],pedCoords[k][5],pedCoords[k][6],8.0,0.0,-1,49,0,0,0,0)

				Clothes(Peds[k],v["clothes"])
				Barber(Peds[k],v["barber"])

				for k,v in pairs(v["tattoos"]) do
					SetPedDecoration(Peds[k],GetHashKey(v[1]),GetHashKey(k))
				end
			end
		end
	end

	Citizen.Wait(1000)

	Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
	SetCamActive(Camera,true)
	RenderScriptCams(true,true,1,true,true)
	SetCamCoord(Camera,-764.43,327.96,211.4)
	SetCamRot(Camera,0.0,0.0,79.38,2)

	TriggerServerEvent("Queue:playerConnect")
	SendNUIMessage({ action = "openSystem" })
	SetNuiFocus(true,true)

	DoScreenFadeIn(1000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEDISPLAY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("generateDisplay",function(data,cb)
	cb({ result = vSERVER.initSystem() })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("characterChosen",function(data)
	for k,v in pairs(Peds) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end

	vSERVER.characterChosen(data["id"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("newCharacter",function(data)
	vSERVER.newCharacter(data["name"],data["name2"],data["sex"],data["loc"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATESPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("generateSpawn",function(data,cb)
	cb({ result = spawnLocates })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- JUSTSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("spawn:justSpawn")
AddEventHandler("spawn:justSpawn",function(status,spawnType)
	DoScreenFadeOut(0)

	spawnLocates = {}
	local ped = PlayerPedId()
	RenderScriptCams(false,false,0,true,true)
	SetCamActive(characterCamera,false)
	DestroyCam(characterCamera,true)
	characterCamera = nil

	if spawnType then
		LocalPlayer["state"]["Invisible"] = true
		SetEntityVisible(ped,false,false)

		local numberLine = 0
		for k,v in pairs(status) do
			numberLine = numberLine + 1

			if k == "Modern" then
				spawnLocates[numberLine] = { x = v[1], y = v[2], z = v[3], name = "Eclipse Towers", hash = numberLine }
			else
				local nameCoords = GetStreetNameAtCoord(v[1],v[2],v[3])
				local streetName = GetStreetNameFromHashKey(nameCoords)

				spawnLocates[numberLine] = { x = v[1], y = v[2], z = v[3], name = streetName, hash = numberLine }
			end
		end

		for k,v in pairs(otherLocates) do
			numberLine = numberLine + 1
			spawnLocates[numberLine] = { x = v[1], y = v[2], z = v[3], name = v[4], hash = numberLine }
		end

		Citizen.Wait(2000)

		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		characterCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",coords["x"],coords["y"],coords["z"] + 200.0,270.00,0.0,0.0,80.0,0,0)
		SetCamActive(characterCamera,true)
		RenderScriptCams(true,false,1,true,true)

		SendNUIMessage({ action = "openSpawn" })

		DoScreenFadeIn(1000)
	else
		LocalPlayer["state"]["Invisible"] = false
		SetEntityVisible(ped,true,false)
		TriggerEvent("hud:Active",true)
		SetNuiFocus(false,false)
		brokenCamera = false

		Citizen.Wait(1000)

		DoScreenFadeIn(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSENEW
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.closeNew()
	SendNUIMessage({ action = "closeNew" })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("spawnChosen",function(data)
	local ped = PlayerPedId()

	if data["hash"] == "spawn" then
		DoScreenFadeOut(0)

		SendNUIMessage({ action = "closeSpawn" })
		TriggerEvent("hud:Active",true)
		SetNuiFocus(false,false)

		LocalPlayer["state"]["Invisible"] = false
		RenderScriptCams(false,false,0,true,true)
		SetCamActive(characterCamera,false)
		DestroyCam(characterCamera,true)
		SetEntityVisible(ped,true,false)
		characterCamera = nil
		brokenCamera = false

		Citizen.Wait(1000)

		DoScreenFadeIn(1000)
	else
		brokenCamera = false
		DoScreenFadeOut(0)

		Citizen.Wait(1000)

		SetCamRot(characterCamera,270.0)
		SetCamActive(characterCamera,true)
		brokenCamera = true
		local speed = 0.7
		weight = 270.0

		DoScreenFadeIn(1000)

		SetEntityCoords(ped,spawnLocates[data["hash"]]["x"],spawnLocates[data["hash"]]["y"],spawnLocates[data["hash"]]["z"],1,0,0,0)
		local coords = GetEntityCoords(ped)

		SetCamCoord(characterCamera,coords["x"],coords["y"],coords["z"] + 200.0)
		local i = coords["z"] + 200.0

		while i > spawnLocates[data["hash"]]["z"] + 1.5 do
			i = i - speed
			SetCamCoord(characterCamera,coords["x"],coords["y"],i)

			if i <= spawnLocates[data["hash"]]["z"] + 35.0 and weight < 360.0 then
				if speed - 0.0078 >= 0.05 then
					speed = speed - 0.0078
				end

				weight = weight + 0.75
				SetCamRot(characterCamera,weight)
			end

			if not brokenCamera then
				break
			end

			Citizen.Wait(0)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function Clothes(ped,data)
	if data["backpack"] == nil then
		data["backpack"] = {}
		data["backpack"]["item"] = 0
		data["backpack"]["texture"] = 0
	end

	SetPedComponentVariation(ped,4,data["pants"]["item"],data["pants"]["texture"],1)
	SetPedComponentVariation(ped,3,data["arms"]["item"],data["arms"]["texture"],1)
	SetPedComponentVariation(ped,5,data["backpack"]["item"],data["backpack"]["texture"],1)
	SetPedComponentVariation(ped,8,data["tshirt"]["item"],data["tshirt"]["texture"],1)
	SetPedComponentVariation(ped,9,data["vest"]["item"],data["vest"]["texture"],1)
	SetPedComponentVariation(ped,11,data["torso"]["item"],data["torso"]["texture"],1)
	SetPedComponentVariation(ped,6,data["shoes"]["item"],data["shoes"]["texture"],1)
	SetPedComponentVariation(ped,1,data["mask"]["item"],data["mask"]["texture"],1)
	SetPedComponentVariation(ped,10,data["decals"]["item"],data["decals"]["texture"],1)
	SetPedComponentVariation(ped,7,data["accessory"]["item"],data["accessory"]["texture"],1)

	if data["hat"]["item"] ~= -1 and data["hat"]["item"] ~= 0 then
		SetPedPropIndex(ped,0,data["hat"]["item"],data["hat"]["texture"],1)
	else
		ClearPedProp(ped,0)
	end

	if data["glass"]["item"] ~= -1 and data["glass"]["item"] ~= 0 then
		SetPedPropIndex(ped,1,data["glass"]["item"],data["glass"]["texture"],1)
	else
		ClearPedProp(ped,1)
	end

	if data["ear"]["item"] ~= -1 and data["ear"]["item"] ~= 0 then
		SetPedPropIndex(ped,2,data["ear"]["item"],data["ear"]["texture"],1)
	else
		ClearPedProp(ped,2)
	end

	if data["watch"]["item"] ~= -1 and data["watch"]["item"] ~= 0 then
		SetPedPropIndex(ped,6,data["watch"]["item"],data["watch"]["texture"],1)
	else
		ClearPedProp(ped,6)
	end

	if data["bracelet"]["item"] ~= -1 and data["bracelet"]["item"] ~= 0 then
		SetPedPropIndex(ped,7,data["bracelet"]["item"],data["bracelet"]["texture"],1)
	else
		ClearPedProp(ped,7)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function Barber(ped,status)
	myClothes = {}
	myClothes = { status[1] or 0, status[2] or 0, status[3] or 0, status[4] or 0, status[5] or 0, status[6] or 0, status[7] or 0, status[8] or 0, status[9] or 0, status[10] or 0, status[11] or 0, status[12] or 0, status[13] or 0, status[14] or 0, status[15] or 0, status[16] or 0, status[17] or 0, status[18] or 0, status[19] or 0, status[20] or 0, status[21] or 0, status[22] or 0, status[23] or 0, status[24] or 0, status[25] or 0, status[26] or 0, status[27] or 0, status[28] or 0, status[29] or 0, status[30] or 0, status[31] or 0, status[32] or 0, status[33] or 0, status[34] or 0, status[35] or 0, status[36] or 0, status[37] or 0, status[38] or 0, status[39] or 0, status[40] or 0, status[41] or 0 }

    local weightFace = myClothes[2] / 100 + 0.0
    local weightSkin = myClothes[4] / 100 + 0.0

	SetPedHeadBlendData(ped,myClothes[41],myClothes[1],0,myClothes[41],myClothes[1],0,weightFace,weightSkin,0.0,false)

	SetPedEyeColor(ped,myClothes[3])

	if myClothes[5] == 0 then
		SetPedHeadOverlay(ped,0,myClothes[5],0.0)
	else
		SetPedHeadOverlay(ped,0,myClothes[5],1.0)
	end

	SetPedHeadOverlay(ped,6,myClothes[6],1.0)

	if myClothes[7] == 0 then
		SetPedHeadOverlay(ped,9,myClothes[7],0.0)
	else
		SetPedHeadOverlay(ped,9,myClothes[7],1.0)
	end

	SetPedHeadOverlay(ped,3,myClothes[8],1.0)

	SetPedComponentVariation(ped,2,myClothes[9],0,1)
	SetPedHairColor(ped,myClothes[10],myClothes[11])

	SetPedHeadOverlay(ped,4,myClothes[12],myClothes[13] * 0.1)
	SetPedHeadOverlayColor(ped,4,1,myClothes[14],myClothes[14])

	SetPedHeadOverlay(ped,8,myClothes[15],myClothes[16] * 0.1)
	SetPedHeadOverlayColor(ped,8,1,myClothes[17],myClothes[17])

	SetPedHeadOverlay(ped,2,myClothes[18],myClothes[19] * 0.1)
	SetPedHeadOverlayColor(ped,2,1,myClothes[20],myClothes[20])

	SetPedHeadOverlay(ped,1,myClothes[21],myClothes[22] * 0.1)
	SetPedHeadOverlayColor(ped,1,1,myClothes[23],myClothes[23])

	SetPedHeadOverlay(ped,5,myClothes[24],myClothes[25] * 0.1)
	SetPedHeadOverlayColor(ped,5,1,myClothes[26],myClothes[26])

	SetPedFaceFeature(ped,0,myClothes[27] * 0.1)
	SetPedFaceFeature(ped,1,myClothes[28] * 0.1)
	SetPedFaceFeature(ped,4,myClothes[29] * 0.1)
	SetPedFaceFeature(ped,6,myClothes[30] * 0.1)
	SetPedFaceFeature(ped,8,myClothes[31] * 0.1)
	SetPedFaceFeature(ped,9,myClothes[32] * 0.1)
	SetPedFaceFeature(ped,10,myClothes[33] * 0.1)
	SetPedFaceFeature(ped,12,myClothes[34] * 0.1)
	SetPedFaceFeature(ped,13,myClothes[35] * 0.1)
	SetPedFaceFeature(ped,14,myClothes[36] * 0.1)
	SetPedFaceFeature(ped,15,myClothes[37] * 0.1)
	SetPedFaceFeature(ped,16,myClothes[38] * 0.1)
	SetPedFaceFeature(ped,17,myClothes[39] * 0.1)
	SetPedFaceFeature(ped,19,myClothes[40] * 0.1)
end