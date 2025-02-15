-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("chest")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local chestOpen = ""
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTCOORDS
-----------------------------------------------------------------------------------------------------------------------------------------
local chestCoords = {
	{ "State",360.43,-1600.48,25.83,"1" },
	{ "Lspd",486.46,-994.94,31.07,"1" },
	{ "Sheriff",1861.92,3688.10,34.66,"1" },
	{ "Sheriff",-445.38,6019.65,37.38,"1" },
	{ "Ranger",386.72,800.09,187.47,"1" },
	{ "Corrections",1844.31,2573.84,46.26,"1" },
	{ "Paramedic",306.17,-601.98,43.25,"1" },
	{ "Paramedic",1828.78,3675.18,34.40,"1" },
	{ "Paramedic",-258.00,6332.62,32.72,"1" },
	{ "Mechanic",124.03,-3007.52,7.02,"1" },
	{ "Favela01",1393.05,-188.17,161.56,"1" },
	{ "Favela02",1762.62,456.43,193.76,"1" },
	{ "Favela03",2248.58,49.89,251.42,"1" },
	{ "Favela04",2874.76,2762.25,68.49,"1" },
	{ "Vagos",428.23,-2050.07,18.74,"1" },
	{ "Vanilla",93.73,-1290.75,28.72,"1" },
	{ "Vinhedo",-1870.29,2058.84,135.44,"1" },
	{ "Arcade",-1648.71,-1073.21,13.83,"1" },
	{ "Desserts",-590.63,-1058.59,22.64,"1" },
	{ "Aztecas",513.03,-1803.79,28.40,"1" },
	{ "Families",-153.34,-1628.55,33.52,"1" },
	{ "EastSide",1162.06,-1634.68,36.85,"1" },
	{ "Bloods",2890.0,4423.39,44.99,"1" },
	{ "TheLost",2527.20,4109.24,39.14,"1" },
	{ "Garden",1945.96,3845.07,35.54,"1" },
	{ "Playboy",-1524.90,148.86,60.74,"1" },
	{ "Salieris",413.24,-1498.08,33.72,"1" },
	{ "trayShot",-1195.20,-893.13,14.41,"2" },
	{ "trayDesserts",-584.01,-1059.30,22.41,"2" },
	{ "trayPops",1586.68,6457.04,26.21,"2" },
	{ "trayPizza",811.10,-752.78,26.74,"2" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTINFOS
-----------------------------------------------------------------------------------------------------------------------------------------
local chestInfos = {
	["1"] = {
		{
			event = "chest:openSystem",
			label = "Abrir",
			tunnel = "shop"
		},{
			event = "chest:upgradeSystem",
			label = "Aumentar",
			tunnel = "shop"
		}
	},
	["2"] = {
		{
			event = "chest:openSystem",
			label = "Bandeja",
			tunnel = "shop"
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)

	for k,v in pairs(chestCoords) do
		exports["target"]:AddCircleZone("Chest:"..k,vector3(v[2],v[3],v[4]),0.5,{
			name = "Chest:"..k,
			heading = 3374176,
			useZ = true
		},{
			shop = k,
			distance = 1.5,
			options = chestInfos[v[5]]
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:OPENSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("chest:openSystem",function(shopId)
	if vSERVER.checkIntPermissions(chestCoords[shopId][1]) and MumbleIsConnected() then
		SetNuiFocus(true,true)
		chestOpen = chestCoords[shopId][1]
		SendNUIMessage({ action = "showMenu" })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:UPGRADESYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("chest:upgradeSystem",function(shopId)
	if MumbleIsConnected() then
		vSERVER.upgradeSystem(chestCoords[shopId][1])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTCLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("invClose",function()
	SendNUIMessage({ action = "hideMenu" })
	SetNuiFocus(false,false)
	chestOpen = ""
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("takeItem",function(data)
	if MumbleIsConnected() then
		vSERVER.takeItem(data["item"],data["slot"],data["amount"],data["target"],chestOpen)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOREITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("storeItem",function(data)
	if MumbleIsConnected() then
		vSERVER.storeItem(data["item"],data["slot"],data["amount"],data["target"],chestOpen)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATESLOT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("updateChest",function(data)
	if MumbleIsConnected() then
		vSERVER.updateChest(data["slot"],data["target"],data["amount"],chestOpen)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTCHEST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestChest",function(data,cb)
	local myInventory,myChest,invPeso,invMaxpeso,chestPeso,chestMaxpeso = vSERVER.openChest(chestOpen)
	if myInventory then
		cb({ myInventory = myInventory, myChest = myChest, invPeso = invPeso, invMaxpeso = invMaxpeso, chestPeso = chestPeso, chestMaxpeso = chestMaxpeso })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chest:Update")
AddEventHandler("chest:Update",function(action)
	SendNUIMessage({ action = action })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:UPDATEWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("chest:UpdateWeight")
AddEventHandler("chest:UpdateWeight",function(invPeso,invMaxpeso,chestPeso,chestMaxpeso)
	SendNUIMessage({ action = "updateWeight", invPeso = invPeso, invMaxpeso = invMaxpeso, chestPeso = chestPeso, chestMaxpeso = chestMaxpeso })
end)