local QBCore = exports['qb-core']:GetCoreObject()
local CurrentCops = 0

RegisterNetEvent('police:SetCopCount')
AddEventHandler('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('nc-police:SetCopCount')
AddEventHandler('nc-police:SetCopCount', function(Amount)
    CurrentCops = Amount
end)

RegisterNetEvent('henox-atmrobbery:client:roubar', function()
    RobAtm()
end)

function RobAtm()
	local pos = GetEntityCoords(PlayerPedId())
	if LocalPlayer.state.isLoggedIn then
		QBCore.Functions.TriggerCallback("henox-atmrobbery:Cooldown", function(cooldown)
			if not cooldown then
				if CurrentCops >= 0 then
					QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
						if hasItem then
							PoliceCall()
							local minigame = exports['hackingminigame']:Open()   
                               if(minigame == true) then -- success
							   ClearPedTasksImmediately(PlayerPedId())
							   HackSuccess() 
							else
								Citizen.Wait(1000)
							    ClearPedTasksImmediately(PlayerPedId())
								HackFailed()
							end
						else
							QBCore.Functions.Notify("Trojan USB gerekiyor", "error")
						end
					end, "trojan_usb")
				else
					QBCore.Functions.Notify("Yeterli Polis Yok", "error")
				end
			else
				QBCore.Functions.Notify("Bu ATM daha yeni soyuldu, daha sonra tekrar deneyin...")
			end
		end)
	else
		Citizen.Wait(3000)
	end
end

function RobbingTheMoney()
    Anim = true
    QBCore.Functions.Progressbar("power_hack", "Parayı alıyorsun...", (45000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash_heels",
        anim = "grab",
        flags = 16,
    }, {
       model = "prop_cs_heist_bag_02",
       bone = 57005,
       coords = { x = -0.005, y = 0.00, z = -0.16 },
       rotation = { x = 250.0, y = -30.0, z = 0.0 },


    }, {}, function() -- Done
        Anim = false
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
		SetPedComponentVariation((PlayerPedId()), 5, 47, 0, 0)

    end, function() -- Cancel
        Anim = false
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
		
    end)
    
    Citizen.CreateThread(function()
        while Anim do
            TriggerServerEvent('ps-hud:Server:gain:stress', math.random(2, 3))
            Citizen.Wait(12000)
        end
    end)
end

function HackFailed()
	QBCore.Functions.Notify("Başarısız?")
    if math.random(1, 100) <= 40 then
		TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
		QBCore.Functions.Notify("Parmak izini bıraktın...")
	end
end

function HackSuccess()
	QBCore.Functions.Notify("Başarılı!")
    ClearPedTasksImmediately(PlayerPedId())
	RobbingTheMoney()
	TriggerServerEvent("henox-atmrobbery:success")	
    TriggerServerEvent('henox-atmrobbery:Server:BeginCooldown')
end

function PoliceCall()
    local chance = 75
    if GetClockHours() >= 0 and GetClockHours() <= 6 then
        chance = 50
    end
    if math.random(1, 100) <= chance then
        TriggerServerEvent('police:server:policeAlert', 'ATM Soygunu devam ediyor')
    end
end

local prop = {
    "prop_atm_01",
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}
  exports['qb-target']:AddTargetModel(prop, {
      options = {
          {
              type = "client",
              event = "henox-atmrobbery:client:roubar",
              icon = "fas fa-user-secret",
              label = "ATM Hackle",
        },
    },
        distance = 2.0    
})
