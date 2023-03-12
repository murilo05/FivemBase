-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICELIST
-----------------------------------------------------------------------------------------------------------------------------------------
local serviceList = {
	{ -1071.85,-823.2,6.00,"Lspd",1.0,18 },
	{ 1852.85,3687.79,34.07,"Sheriff-1",1.0,17 },
	{ -919.12,-2028.21,10.3,"Sheriff-2",1.0,17 },
	{ 1840.20,2578.48,46.07,"Corrections",1.0,24 },
	{ -919.12,-2028.21,10.3,"Ranger",1.0,69 },
	{ 382.01,-1596.39,29.91,"State",1.0,11 },
	{ 1146.33,-1553.53,36.18,"Paramedic-1",1.0,6 },
	{ 1831.79,3672.95,34.27,"Paramedic-2",1.0,6 },
	{ -254.77,6331.03,32.79,"Paramedic-3",1.5,6 },
	{ 835.71,-933.74,33.16,"Mechanic",1.0,0 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	for k,v in pairs(serviceList) do
		exports["target"]:AddCircleZone("service:"..v[4],vector3(v[1],v[2],v[3]),0.25,{
			name = "service:"..v[4],
			heading = 3374176
		},{
			shop = k,
			distance = v[5],
			options = {
				{
					label = "Entrar em Serviço",
					event = "service:Toggle",
					tunnel = "shop"
				}
			}
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE:TOGGLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("service:Toggle")
AddEventHandler("service:Toggle",function(Service)
	TriggerServerEvent("service:Toggle",serviceList[Service][4],serviceList[Service][6])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVICE:LABEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("service:Label")
AddEventHandler("service:Label",function(Service,Text)
	if Service == "Sheriff" then
		exports["target"]:LabelText("service:Sheriff-1",Text)
		exports["target"]:LabelText("service:Sheriff-2",Text)
	elseif Service == "Paramedic" then
		exports["target"]:LabelText("service:Paramedic-1",Text)
		exports["target"]:LabelText("service:Paramedic-2",Text)
		exports["target"]:LabelText("service:Paramedic-3",Text)
	else
		exports["target"]:LabelText("service:"..Service,Text)
	end
end)