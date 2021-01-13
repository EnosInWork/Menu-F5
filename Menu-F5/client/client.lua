ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(0)
    end

    RefreshMoney()

    menu.WeaponData = ESX.GetWeaponList()

	for i = 1, #menu.WeaponData, 1 do
		if menu.WeaponData[i].name == 'WEAPON_UNARMED' then
			menu.WeaponData[i] = nil
		else
			menu.WeaponData[i].hash = GetHashKey(menu.WeaponData[i].name)
		end
    end

RMenu.Add('inventory', 'main', RageUI.CreateMenu("Inventaire", "", 0,0))

RMenu.Add('inventory', 'inventory', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Choix", " "))
RMenu.Add('inventory', 'inventaire', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Choix", " "))
RMenu.Add('inventory', 'weapon', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Inventaire", " "))
RMenu.Add('inventory', 'inventaire', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Inventaire", " "))
RMenu.Add('inventory', 'inventaire_use', RageUI.CreateSubMenu(RMenu:Get('inventory', 'inventaire'), "Inventaire", " "))
RMenu.Add('inventory', 'weapon_use', RageUI.CreateSubMenu(RMenu:Get('inventory', 'weapon'), "Inventaire", " "))
RMenu.Add('inventory', 'portefeuille', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Portefeuille", " "))
RMenu.Add('inventory', 'portefeuille_use', RageUI.CreateSubMenu(RMenu:Get('inventory', 'portefeuille'), "Portefeuille", " "))
RMenu.Add('inventory', 'portefeuille_money', RageUI.CreateSubMenu(RMenu:Get('inventory', 'portefeuille'), "Portefeuille", " "))
RMenu.Add('inventory', 'portefeuille_work', RageUI.CreateSubMenu(RMenu:Get('inventory', 'portefeuille'), "Emplois", " "))
RMenu.Add('inventory', 'portefeuille_billing', RageUI.CreateSubMenu(RMenu:Get('inventory', 'portefeuille'), "Factures", " "))
RMenu.Add('inventory', 'divers', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Divers", " "))
RMenu.Add('inventory', 'sim', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Carte-SIM", " "))
RMenu.Add('inventory', 'key', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Clé(s)", " "))
RMenu.Add('inventory', 'visual', RageUI.CreateSubMenu(RMenu:Get('inventory', 'divers'), "Visuel", " "))
RMenu.Add('inventory', 'tserv', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Touche Serveur", " "))
RMenu.Add('inventory', 'boss', RageUI.CreateSubMenu(RMenu:Get('inventory', 'portefeuille'), "Gestion d'entreprise", " "))
RMenu.Add('inventory', 'voiture', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Gestion Véhicule", " "))
RMenu.Add('inventory', 'voiture_porte', RageUI.CreateSubMenu(RMenu:Get('inventory', 'voiture'), "Véhicule", " "))
RMenu.Add('inventory', 'clothes', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Vêtements", " "))
RMenu.Add('inventory', 'accessories', RageUI.CreateSubMenu(RMenu:Get('inventory', 'main'), "Accessoire", " "))

RMenu:Get('inventory', 'main'):SetSubtitle(" ")
RMenu:Get('inventory', 'main').EnableMouse = false
RMenu:Get('inventory', 'main').Closed = function()

        menu.Menu = false
    end
end)

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		societymoney = ESX.Math.GroupDigits(money)
	end
end)

function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			societymoney = ESX.Math.GroupDigits(money)
		end, ESX.PlayerData.job.name)
	end
end

function ShowAboveRadarMessage(msg, flash, saveToBrief, hudColorIndex)
    if saveToBrief == nil then saveToBrief = true end
    AddTextEntry('notif', msg)
    BeginTextCommandThefeedPost('notif')
    if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
    EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

function CheckQuantity(number)
  number = tonumber(number)

  if type(number) == 'number' then
    number = ESX.Math.Round(number)

    if number > 0 then
      return true, number
    end
  end

  return false, number
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
  
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
      Citizen.Wait(0)
    end
  
    if UpdateOnscreenKeyboard() ~= 2 then
      local result = GetOnscreenKeyboardResult()
      Citizen.Wait(500)
      return result
    else
      Citizen.Wait(500)
      return nil
    end
  end

RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(money)
	  ESX.PlayerData.money = money
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)

RegisterNetEvent('VMLife:Weapon_addAmmoToPedC')
AddEventHandler('VMLife:Weapon_addAmmoToPedC', function(value, quantity)
  local weaponHash = GetHashKey(value)

    if HasPedGotWeapon(PlayerPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
        AddAmmoToPed(PlayerPed, value, quantity)
    end
end)

------------------------------------ Color Menu ------------------------------------------

local menuColor = {255, 0, 0}
Citizen.CreateThread(function()
    Wait(1000)
    menuColor[1] = GetResourceKvpInt("menuR")
    menuColor[2] = GetResourceKvpInt("menuG")
    menuColor[3] = GetResourceKvpInt("menuB")
    ReloadColor()
end)

local AllMenuToChange = nil
function ReloadColor()
    Citizen.CreateThread(function()
        if AllMenuToChange == nil then
            AllMenuToChange = {}
            for Name, Menu in pairs(RMenu['inventory']) do
                if Menu.Menu.Sprite.Dictionary == "commonmenu" then
                    table.insert(AllMenuToChange, Name)
                end
            end
        end
        for k,v in pairs(AllMenuToChange) do
            RMenu:Get('inventory', v):SetRectangleBanner(255, 0, 0)
            for name, menu in pairs(RMenu['inventory']) do
              RMenu:Get('inventory', name).TitleFont = 4
          end
        end
    end)
end

----------------------------------------------------------------------------------


menu = {
    ItemSelected = {},
    ItemSelected2 = {},
    WeaponData = {},
    Menu = false,
    Ped = PlayerPedId(),
    bank = nil,
    sale = nil,
    map = true,
    billing = {},
    visual = false,
    visual2 = false,
    visual3 = false,
    visual5 = false,
    visual6 = false,
    visual7 = false,
    visual8 = false,
    list2 = 1,
    Filtres = {'normal', 'améliorees', 'amplifiees', 'noir/blanc'},
}


menu.V = {
    VehPed = GetVehiclePedIsIn(menu.Ped, false),
    Get = GetVehiclePedIsUsing(menu.Ped),
    agauche = false,
    argauche = false,
    adroite = false,
    ardroite = false,
    capot = false,
    test = false
}

cartesim = {}
clevoiture = {}

function openMenu()
    if menu.Menu then
        menu.Menu = false
    else
        menu.Menu = true
        RageUI.Visible(RMenu:Get('inventory', 'main'), true)

        Citizen.CreateThread(function()
            while menu.Menu do

                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'main'), true, true, true, function() 

                        RageUI.ButtonWithStyle("Inventaire", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'inventaire'))

                        RageUI.ButtonWithStyle("Portefeuille", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'portefeuille'))

                        RageUI.ButtonWithStyle("Gestion des Armes", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'weapon'))

                        RageUI.ButtonWithStyle("Carte-SIM", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'sim'))

                        RageUI.ButtonWithStyle("Clé(s)", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'key'))

                        RageUI.ButtonWithStyle("Animations", nil, {RightLabel = "→→"}, true, function(Hovered, Active,Selected)
                            if (Selected) then 
                                emote()
                                RageUI.CloseAll()
                            end 
                        end)

                        RageUI.ButtonWithStyle("Vétements", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'clothes'))

                        RageUI.ButtonWithStyle("Divers", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'divers'))

                    if IsPedSittingInAnyVehicle(menu.Ped) then
                        RageUI.ButtonWithStyle("Gestion Véhicule", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected)
                        end, RMenu:Get('inventory', 'voiture'))                       
                        else
                        RageUI.ButtonWithStyle('Gestion Véhicule', description, {RightBadge = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                                if (Selected) then
                                    end 
                                end)
                            end

                    end, function()
                    end)

                ----------------------------------------------------------------------------------
                RageUI.IsVisible(RMenu:Get('inventory', 'voiture'), true, true, true, function()

                    Ped = GetPlayerPed(-1)
                    GetSourcevehicle = GetVehiclePedIsIn(Ped, false)

                    RageUI.ButtonWithStyle("Allumer/Eteindre votre moteur", nil, {RightBadge = RageUI.BadgeStyle.Car}, true, function(Hovered,Active,Selected) 
                        if Selected then
                            if GetIsVehicleEngineRunning(menu.V.VehPed) then
                                    SetVehicleEngineOn(menu.V.VehPed, false, false, true)
                                    SetVehicleUndriveable(menu.V.VehPed, true)
                            elseif not GetIsVehicleEngineRunning(menu.V.VehPed) then
                                    SetVehicleEngineOn(menu.V.VehPed, true, false, true)
                                    SetVehicleUndriveable(menu.V.VehPed, false)
                                end
                            end
                        end)
         
                    RageUI.ButtonWithStyle("Gestion des portes", nil, {RightLabel = "→→"}, true, function(Hovered,Active,Selected) 
                        if Selected then
                            end
                        end, RMenu:Get('inventory', 'voiture_porte'))                            
                    end,function()
                end)
                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'voiture_porte'), true, true, true, function()

                    RageUI.ButtonWithStyle("Ouvrir/Fermer Avant Gauche", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
                        if Selected then
                                SetVehicleDoorOpen(menu.V.VehPed, 0, menu.V.agauche)
                                    menu.V.agauche = not menu.V.agauche
                                end
                            end)

                    RageUI.ButtonWithStyle("Ouvrir/Fermer Avant Droite", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
                        if Selected then
                            if not menu.V.adroite then
                                menu.V.adroite = true
                                SetVehicleDoorOpen(menu.V.VehPed, 1, false, false)
                            elseif menu.V.adroite then
                                menu.V.adroite = false
                                SetVehicleDoorShut(menu.V.VehPed, 1, false, false)
                                end
                            end
                        end)

                    RageUI.ButtonWithStyle("Ouvrir/Fermer Ariére Gauche", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
                        if Selected then
                            if not menu.V.argauche then
                                menu.V.argauche = true
                                SetVehicleDoorOpen(menu.V.VehPed, 2, false, false)
                            elseif menu.V.argauche then
                                menu.V.argauche = false
                                SetVehicleDoorShut(menu.V.VehPed, 2, false, false)
                                end
                            end
                        end)

                    RageUI.ButtonWithStyle("Ouvrir/Fermer Ariére Droite", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
                        if Selected then
                            if not menu.V.ardroite then
                                menu.V.ardroite = true
                                SetVehicleDoorOpen(menu.V.VehPed, 3, false, false)
                            elseif menu.V.ardroite then
                                menu.V.ardroite = false
                                SetVehicleDoorShut(menu.V.VehPed, 3, false, false)
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("Ouvrir/Fermer Capot", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected) 
                            if Selected then
                                if not menu.V.capot then
                                    menu.V.capot = true
                                    SetVehicleDoorOpen(menu.V.VehPed, 4, false, false)
                                elseif menu.V.capot then
                                    menu.V.capot = false
                                    SetVehicleDoorShut(menu.V.VehPed, 4, false, false)
                                    end
                                end
                            end)
                    end,function()
                end)

                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'inventaire'), true, true, true, function()
                    ESX.PlayerData = ESX.GetPlayerData()
                    for i = 1, #ESX.PlayerData.inventory do
                        if ESX.PlayerData.inventory[i].count > 0 then
                            RageUI.ButtonWithStyle('[' ..ESX.PlayerData.inventory[i].count.. '] - ~s~' ..ESX.PlayerData.inventory[i].label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                    menu.ItemSelected = ESX.PlayerData.inventory[i]
                                    end 
                                end, RMenu:Get('inventory', 'inventaire_use'))
                            end
                        end
                    end)

                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'weapon'), true, true, true, function() 
                    ESX.PlayerData = ESX.GetPlayerData()
                    for i = 1, #menu.WeaponData, 1 do
                        if HasPedGotWeapon(menu.Ped, menu.WeaponData[i].hash, false) then
                            local ammo = GetAmmoInPedWeapon(menu.Ped, menu.WeaponData[i].hash)
            
                            RageUI.ButtonWithStyle('[' ..ammo.. '] - ~s~' ..menu.WeaponData[i].label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                if (Selected) then
                                    menu.ItemSelected = menu.WeaponData[i]
                                end
                            end,RMenu:Get('inventory', 'weapon_use'))
                        end
                    end
                end)

                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'weapon_use'), true, true, true, function() 
                    RageUI.ButtonWithStyle('Donner des munitions', nil, {RightBadge = RageUI.BadgeStyle.Ammo}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local post, quantity = CheckQuantity(KeyboardInput('Nombre de munitions', '180'), '', 8)
    
                            if post then
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)
                                    local pPed = GetPlayerPed(-1)
                                    local coords = GetEntityCoords(pPed)
                                    local x,y,z = table.unpack(coords)
                                    DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
    
                                    if IsPedOnFoot(closestPed) then
                                        local ammo = GetAmmoInPedWeapon(menu.Ped, menu.ItemSelected.hash)
    
                                        if ammo > 0 then
                                            if quantity <= ammo and quantity >= 0 then
                                                local finalAmmo = math.floor(ammo - quantity)
                                                SetPedAmmo(menu.Ped, menu.ItemSelected.name, finalAmmo)
    
                                                TriggerServerEvent('VMLife:Weapon_addAmmoToPedS', GetPlayerServerId(closestPlayer), menu.ItemSelected.name, quantity)
                                                ShowAboveRadarMessage('Vous avez donné x%s munitions à %s', quantity, GetPlayerName(closestPlayer))
                                                --RageUI.CloseAll()
                                            else
                                                ShowAboveRadarMessage('Vous ne possédez pas autant de munitions')
                                            end
                                        else
                                            ShowAboveRadarMessage("Vous n'avez pas de munition")
                                        end
                                    else
                                        ShowAboveRadarMessage('Vous ne pouvez pas donner des munitions dans un ~~r~véhicule~s~', menu.ItemSelected.label)
                                    end
                                else
                                    ShowAboveRadarMessage('Aucun joueur ~r~proche~s~ !')
                                end
                            else
                                ShowAboveRadarMessage('Nombre de munition ~r~invalid')
                            end
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Jeter l'arme", nil, {RightBadge = RageUI.BadgeStyle.Gun}, true, function(Hovered, Active, Selected)
                        if Selected then
                            if IsPedOnFoot(menu.Ped) then
                                TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', menu.ItemSelected.name)
                                --RageUI.CloseAll()
                            else
                                ShowAboveRadarMessage("~r~Impossible~s~ de jeter l'armes dans un véhicule", menu.ItemSelected.label)
                            end
                        end
                    end)

                    if HasPedGotWeapon(menu.Ped, menu.ItemSelected.hash, false) then
                        RageUI.ButtonWithStyle("Donner l'arme", nil, {RightBadge = RageUI.BadgeStyle.Gun}, true, function(Hovered, Active, Selected)
                            if Selected then
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                            if closestDistance ~= -1 and closestDistance <= 3 then
                                local closestPed = GetPlayerPed(closestPlayer)
                                local pPed = GetPlayerPed(-1)
                                local coords = GetEntityCoords(pPed)
                                local x,y,z = table.unpack(coords)
                                DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
    
                                if IsPedOnFoot(closestPed) then
                                    local ammo = GetAmmoInPedWeapon(menu.Ped, menu.ItemSelected.hash)
                                    TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_weapon', menu.ItemSelected.name, ammo)
                                    --seAll()
                                else
                                    ShowAboveRadarMessage('~r~Impossible~s~ de donner une arme dans un véhicule', menu.ItemSelected.label)
                                end
                            else
                                ShowAboveRadarMessage('Aucun joueur ~r~proche !')
                            end
                        end
                    end)
                end

                    end,function()
                end)


                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'inventaire_use'), true, true, true, function()
                    
                    RageUI.ButtonWithStyle("Utiliser", nil, {RightBadge = RageUI.BadgeStyle.Heart}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                           -- local NumerItems = KeyboardInput("Combiens d'items voulez-vous utiliser ?", "", 3)
                         if menu.ItemSelected.usable then
                             TriggerServerEvent('esx:useItem', menu.ItemSelected.name)
                            else
                                ShowAboveRadarMessage('l\'items n\'est pas utilisable', menu.ItemSelected.label)
                                end
                            end
                        end) 

                        RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                if menu.ItemSelected.canRemove then
                                    local post,quantity = CheckQuantity(KeyboardInput("Nombres d'items que vous voulez jeter", '', '', 100))
                                    if post then
                                        if not IsPedSittingInAnyVehicle(PlayerPed) then
                                            TriggerServerEvent('esx:removeInventoryItem', 'item_standard', menu.ItemSelected.name, quantity)
                                            --RageUI.CloseAll()
                                        end
                                    end
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                local sonner,quantity = CheckQuantity(KeyboardInput("Nombres d'items que vous voulez donner", '', '', 100))
                                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                                local pPed = GetPlayerPed(-1)
                                local coords = GetEntityCoords(pPed)
                                local x,y,z = table.unpack(coords)
                                DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
            
                                if sonner then
                                    if closestDistance ~= -1 and closestDistance <= 3 then
                                        local closestPed = GetPlayerPed(closestPlayer)
            
                                        if IsPedOnFoot(closestPed) then
                                                TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', menu.ItemSelected.name, quantity)
                                                --RageUI.CloseAll()
                                            else
                                                ShowAboveRadarMessage("~∑~ Nombres d'items invalid !")
                                            end
                                        --else
                                            --ShowAboveRadarMessage("~∑~ Tu ne peux pas donner d'items dans un véhicule !", menu.ItemSelected.label
                                    else
                                        ShowAboveRadarMessage("∑ Aucun joueur ~r~Proche~n~ !")
                                        end
                                    end
                                end
                            end)
                        end,function()
                    end)
                ----------------------------------------------------------------------------------
                RageUI.IsVisible(RMenu:Get('inventory', 'portefeuille_billing'), true, true, true, function()
                    ESX.TriggerServerCallback('VInventory:billing', function(bills) menu.billing = bills end)

                    if #menu.billing == 0 then
                        RageUI.ButtonWithStyle("Aucune facture", nil, { RightLabel = "" }, true, function(Hovered, Active, Selected)
                            if (Selected) then
                            end
                        end)
                    end
                        
                    for i = 1, #menu.billing, 1 do
                    RageUI.ButtonWithStyle(menu.billing[i].label, nil, {RightLabel = '[~b~$' .. ESX.Math.GroupDigits(menu.billing[i].amount.."~s~] →")}, true, function(Hovered,Active,Selected)
                        if Selected then
                                ESX.TriggerServerCallback('esx_billing:payBill', function()
                                ESX.TriggerServerCallback('VInventory:billing', function(bills) menu.billing = bills end)
                                        end)
                                    end
                                end)
                            end
                      --  end)
                end, function()
                end)
                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'portefeuille'), true, true, true, function()

                    RageUI.ButtonWithStyle("Emplois", nil, {RightLabel = "~b~"..ESX.PlayerData.job.label .."~s~ →"}, true, function(Hovered, Active, Selected)
                        if Selected then
                        end
                    end, RMenu:Get('inventory', 'portefeuille_work'))

                    RageUI.ButtonWithStyle('Facture', description, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                        if (Selected) then 
                            end 
                        end, RMenu:Get('inventory', 'portefeuille_billing'))

                    RageUI.ButtonWithStyle('Liquide', description, {RightLabel = "~g~$"..ESX.Math.GroupDigits(ESX.PlayerData.money.."~s~ →")}, true, function(Hovered, Active, Selected) 
                        if (Selected) then 
                            end 
                        end, RMenu:Get('inventory', 'portefeuille_money'))
            
                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == 'bank'  then
                            menu.bank = RageUI.ButtonWithStyle('Banque', description, {RightLabel = "~b~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money.."~s~")}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                        end 
                                    end)

                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == 'black_money'  then
                            menu.sale = RageUI.ButtonWithStyle('Non déclaré', description, {RightLabel = "~r~$"..ESX.Math.GroupDigits(ESX.PlayerData.accounts[i].money.."~s~ →")}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                        end 
                                    end, RMenu:Get('inventory', 'portefeuille_use'))

                                    RageUI.ButtonWithStyle(('~b~Montrer ~s~ça carte d\'identité'), nil, {}, true, function(Hovered, Active, Selected)
                                        if (Selected) then
                                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer))
                                            else
                                                ESX.ShowNotification(('Aucun joueur à proximité'))
                                            end
                                        end
                                    end)
            
                                    RageUI.ButtonWithStyle(('~g~Regarder ~s~ça carte d\'identité'), nil, {}, true, function(Hovered, Active, Selected)
                                        if (Selected) then
                                            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                                        end
                                    end)

                                    RageUI.ButtonWithStyle(('~b~Montrer ~s~son permis de conduire'), nil, {}, true, function(Hovered, Active, Selected)
                                        if (Selected) then
                                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'driver')
                                            else
                                                ESX.ShowNotification(('Aucun joueur à proximité'))
                                            end
                                        end
                                    end)
                        
                                    RageUI.ButtonWithStyle(('~g~Regarder ~s~son permis de conduire'), nil, {}, true, function(Hovered, Active, Selected)
                                        if (Selected) then
                                            TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
                                        end
                                    end)
                        
                                    RageUI.ButtonWithStyle(('~b~Montrer ~s~son PPA'), nil, {}, true, function(Hovered, Active, Selected)
                                        if (Selected) then
                                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(closestPlayer), 'weapon')
                                            else
                                                ESX.ShowNotification(('Aucun joueur à proximité'))
                                            end
                                        end
                                    end)

                                    RageUI.ButtonWithStyle(('~g~Regarder ~s~son PPA'), nil, {}, true, function(Hovered, Active, Selected)
                                        if (Selected) then
                                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        
                                            if closestDistance ~= -1 and closestDistance <= 3.0 then
                                                TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
                                            end
                                        end
                                    end)


                                end
                            end
                        end
                    end
                end)
                ----------------------------------------------------------------------------------


                RageUI.IsVisible(RMenu:Get('inventory', 'portefeuille_use'), true, true, true, function() 

                    for i = 1, #ESX.PlayerData.accounts, 1 do
                        if ESX.PlayerData.accounts[i].name == 'black_money' then
                            RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered,Active,Selected)
                                if Selected then
                                    local black, quantity = CheckQuantity(KeyboardInput("Somme d'argent que vous voulez donner", '', '', 1000))
                                        if black then
                                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    
                                    if closestDistance ~= -1 and closestDistance <= 3 then
                                        local closestPed = GetPlayerPed(closestPlayer)
    
                                        if not IsPedSittingInAnyVehicle(closestPed) then
                                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                            --RageUI.CloseAll()
                                        else
                                           ShowAboveRadarMessage(_U('Vous ne pouvez pas donner ', 'de l\'argent dans un véhicles'))
                                        end
                                    else
                                       ShowAboveRadarMessage('Aucun joueur proche !')
                                    end
                                else
                                   ShowAboveRadarMessage('Somme invalid')
                                end
                            end
                        end)
    
                        RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                            if Selected then
                                local black, quantity = CheckQuantity(KeyboardInput("Somme d'argent que vous voulez jeter", '', '', 1000))
                                if black then
                                    if not IsPedSittingInAnyVehicle(PlayerPed) then
                                        TriggerServerEvent('esx:removeInventoryItem', 'item_account', ESX.PlayerData.accounts[i].name, quantity)
                                       -- RageUI.CloseAll()
                                            else
                                               ShowAboveRadarMessage('Vous pouvez pas jeter', 'de l\'argent')
                                                end
                                            else
                                               ShowAboveRadarMessage('Somme Invalid')
                                            end
                                        end
                                    end)
                                end
                            end
                        end)
                ----------------------------------------------------------------------------------


                    RageUI.IsVisible(RMenu:Get('inventory', 'portefeuille_work'), true, true, true, function()
                        RageUI.ButtonWithStyle("Grade", nil, {RightLabel = "~b~"..ESX.PlayerData.job.grade_label .."~s~"}, true, function(Hovered, Active, Selected)
                            if Selected then
                            end
                        end)
    
                        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ademo' then
    
                        RageUI.ButtonWithStyle("Démisionner", nil, {RightBadge = RageUI.BadgeStyle.Alert, Color = { BackgroundColor = { 154, 0, 0, 0 } } }, true, function(Hovered, Active, Selected)
                            if Selected then
                                TriggerServerEvent("job:set", "unemployed")
                            end
                        end)
                    end

                        if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then

                        RageUI.ButtonWithStyle("Gestion d'entreprise", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                            if Selected then
                        end
                    end, RMenu:Get('inventory', 'boss'))
                else
                    RageUI.ButtonWithStyle("Gestion d'entreprise", nil, {RightBadge = RageUI.BadgeStyle.Lock}, false, function(Hovered, Active, Selected)
                            if Selected then
                                end
                            end)
                        end 
                    end, function()
                end)

                

                -- ----------------------------------------------------------------------------------

                 RageUI.IsVisible(RMenu:Get('inventory', 'boss'), true, true, true, function()

                     if societymoney ~= nil then
                         RageUI.Separator("[ Societé ~b~"..ESX.PlayerData.job.label.."~s~ ] - [ Argent ~g~"..societymoney.."$~s~ ]")
                     end

                 RageUI.ButtonWithStyle('Recruter une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                     if (Selected) then
                         if ESX.PlayerData.job.grade_name == 'boss' then
                             local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        
                             if closestPlayer == -1 or closestDistance > 3.0 then
                                 ShowAboveRadarMessage('Aucun joueur proche')
                             else
                                 TriggerServerEvent('vInventory:Boss_recruterplayer', GetPlayerServerId(closestPlayer), ESX.PlayerData.job.name, 0)
                             end
                         else
                             ShowAboveRadarMessage('Vous n\'avez pas les ~r~droits~w~')
                         end
                     end
                 end)
        
                 RageUI.ButtonWithStyle('Virer une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                     if (Selected) then
                         if ESX.PlayerData.job.grade_name == 'boss' then
                             local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        
                             if closestPlayer == -1 or closestDistance > 3.0 then
                                 ShowAboveRadarMessage('Aucun joueur proche')
                             else
                                 TriggerServerEvent('vInventory:Boss_virerplayer', GetPlayerServerId(closestPlayer))
                             end
                         else
                             ShowAboveRadarMessage('Vous n\'avez pas les ~r~droits~w~')
                         end
                     end
                 end)
        
                 RageUI.ButtonWithStyle('Promouvoir une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                         if ESX.PlayerData.job.grade_name == 'boss' then
                             local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        
                             if closestPlayer == -1 or closestDistance > 3.0 then
                                 ShowAboveRadarMessage('Aucun joueur proche')
                             else
                                 TriggerServerEvent('vInventory:Boss_promouvoirplayer', GetPlayerServerId(closestPlayer))
                         end
                         else
                             ShowAboveRadarMessage('Vous n\'avez pas les ~r~droits~w~')
                         end
                     end
                 end)
        
                 RageUI.ButtonWithStyle('Destituer une personne', nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                     if (Selected) then
                         if ESX.PlayerData.job.grade_name == 'boss' then
                             local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        
                             if closestPlayer == -1 or closestDistance > 3.0 then
                                     ShowAboveRadarMessage('Aucun joueur proche')
                                 else
                                TriggerServerEvent('vInventory:Boss_destituerplayer', GetPlayerServerId(closestPlayer))
                                     end
                                 else
                                     ShowAboveRadarMessage('Vous n\'avez pas les ~r~droits~w~')
                                 end
                             end
                         end)
                     end, function()
                 end)
                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'portefeuille_money'), true, true, true, function()

                    RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered,Active,Selected)
                        if Selected then
                            local black, quantity = CheckQuantity(KeyboardInput("Somme d'argent que vous voulez donner", '', '', 1000))
                                if black then
                                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                            if closestDistance ~= -1 and closestDistance <= 3 then
                                local closestPed = GetPlayerPed(closestPlayer)

                                if not IsPedSittingInAnyVehicle(closestPed) then
                                    TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_money', ESX.PlayerData.money, quantity)
                                    --RageUI.CloseAll()
                                else
                                   ShowAboveRadarMessage(_U('Vous ne pouvez pas donner ', 'de l\'argent dans un véhicles'))
                                end
                            else
                               ShowAboveRadarMessage('Aucun joueur proche !')
                            end
                        else
                           ShowAboveRadarMessage('Somme invalid')
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local black, quantity = CheckQuantity(KeyboardInput("Somme d'argent que vous voulez jeter", '', '', 1000))
                        if black then
                            if not IsPedSittingInAnyVehicle(PlayerPed) then
                                TriggerServerEvent('esx:removeInventoryItem', 'item_money', ESX.PlayerData.money, quantity)
                                --RageUI.CloseAll()
                                    else
                                       ShowAboveRadarMessage('Vous pouvez pas jeter', 'de l\'argent')
                                        end
                                    else
                                       ShowAboveRadarMessage('Somme Invalid')
                                    end
                                end
                            end)
                        end)

                ----------------------------------------------------------------------------------

                RageUI.IsVisible(RMenu:Get('inventory', 'divers'), true, true, true, function()

                    RageUI.Checkbox("Afficher / Désactiver la map", description, menu.map,{},function(Hovered,Ative,Selected,Checked)
                        if Selected then
                            menu.map = Checked
                            if Checked then
                                DisplayRadar(true)
                            else
                                DisplayRadar(false)
                            end
                        end
                    end)

                    local ragdolling = false
                    RageUI.ButtonWithStyle('Dormir / Se Reveiller', description, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                        if (Selected) then
                            ragdolling = not ragdolling
                            while ragdolling do
                             Wait(0)
                            local myPed = GetPlayerPed(-1)
                            SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
                            ResetPedRagdollTimer(myPed)
                            AddTextEntry(GetCurrentResourceName(), ('Appuyez sur ~INPUT_JUMP~ pour vous ~b~Réveillé'))
                            DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
                            ResetPedRagdollTimer(myPed)
                            if IsControlJustPressed(0, 22) then 
                            break
                        end
                    end
                end
            end)

            RageUI.ButtonWithStyle("Faire un report", description, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                if (Selected) then 
                    local report = KeyboardInput("", '', '', 1000)
                    ExecuteCommand("report " ..report)
                end 
            end)

            RageUI.ButtonWithStyle('Touche Serveur', description, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                if (Selected) then 
                    end 
                end, RMenu:Get('inventory', 'tserv'))

                RageUI.ButtonWithStyle("Rejoindre le ~b~Discord", description, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                    if (Selected) then 
                        ExecuteCommand("discord")
                    end 
                end)

            -----------------------------------------------------------------------

             RageUI.ButtonWithStyle("Menu Filtres", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
                    if Selected then
                         end
                    end, RMenu:Get('inventory', 'visual'))
                end)

                RageUI.IsVisible(RMenu:Get('inventory', 'visual'), true, true, true, function()

                    RageUI.Checkbox("Vue & lumières améliorées", description, menu.visual, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual = Checked
                            if Checked then
                                SetTimecycleModifier('tunnel')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)

                    RageUI.Checkbox("Vue lumineux", description, menu.visual7, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual7 = Checked
                            if Checked then
                                SetTimecycleModifier('rply_vignette_neg')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)
        
                    RageUI.Checkbox("Couleurs amplifiées", description, menu.visual2, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual2 = Checked
                            if Checked then
                                SetTimecycleModifier('rply_saturation')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)
        
                    RageUI.Checkbox("Noir & blancs", description, menu.visual3, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual3 = Checked
                            if Checked then
                                SetTimecycleModifier('rply_saturation_neg')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)

                    RageUI.Checkbox("Visual 1", description, menu.visual5, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual5 = Checked
                            if Checked then
                                SetTimecycleModifier('yell_tunnel_nodirect')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)

                    RageUI.Checkbox("Blanc", description, menu.visual6, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual6 = Checked
                            if Checked then
                                SetTimecycleModifier('rply_contrast_neg')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)

                    RageUI.Checkbox("Dégats", description, menu.visual8, {}, function(Hovered, Selected, Active, Checked) 
                        if Selected then 
                            menu.visual8 = Checked
                            if Checked then
                                SetTimecycleModifier('rply_vignette')
                            else
                                SetTimecycleModifier('')
                            end
                        end 
                    end)

                    end,function()
                    end)

----------------------------------------------------------------------------------------------------



    RageUI.IsVisible(RMenu:Get('inventory', 'sim'), true, true, true, function()

        for sim = 1, #cartesim, 1 do
        RageUI.ButtonWithStyle(" "..cartesim[sim].label, nil, {RightLabel = ""}, true, function(Hovered, Active,Selected)
        end, RMenu:Get('inventory', 'simg'))
        end

    end,function()
    end)

----------------------------------------------------------------------------------------------------

    RageUI.IsVisible(RMenu:Get('inventory', 'key'), true, true, true, function()

        for key = 1, #clevoiture, 1 do
        RageUI.ButtonWithStyle("~b~Clé : ~s~"..clevoiture[key].value, nil, {RightLabel = ""}, true, function(Hovered, Active,Selected)
        end, RMenu:Get('inventory', 'simg'))
        end

    end,function()
    end)


----------------------------------------------------------------------------------------------------

RageUI.IsVisible(RMenu:Get('inventory', 'clothes'), true, true, true, function()

    RageUI.ButtonWithStyle("Haut", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
         if (Selected) then
            TriggerEvent('changerhaut')   
        end 
    end)

    RageUI.ButtonWithStyle("Pantalon", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
         if (Selected) then
            TriggerEvent('changerpantalon')  
        end 
    end)

    RageUI.ButtonWithStyle("Chaussure", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
        if (Selected) then 
        TriggerEvent('changerchaussure')
       end 
   end)

   RageUI.ButtonWithStyle("Masque", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
    if (Selected) then
        TriggerEvent('changermasque') 
    end 
end)

   RageUI.ButtonWithStyle("Sac", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
    if (Selected) then
        TriggerEvent('changersac') 
        end 
    end)

    RageUI.ButtonWithStyle("GPB", nil, {RightLabel = "→"}, true, function(Hovered, Active,Selected)
        if (Selected) then
            TriggerEvent('changergpb') 
        end 
    end)

end,function()
end)

----------------------------------------------------------------------------------------------------

RageUI.IsVisible(RMenu:Get('inventory', 'tserv'), true, true, true, function()
    players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert( players, player )
    end

    RageUI.ButtonWithStyle("Ouvrir/Fermer Téléphone :", description, {RightLabel = "~b~F"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

    RageUI.ButtonWithStyle("Gestion Carte SIM :", description, {RightLabel = "~b~F"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

    RageUI.ButtonWithStyle("Gestion Animations :", description, {RightLabel = "~b~F"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

    RageUI.ButtonWithStyle("Ouvrir/Fermer Radio :", description, {RightLabel = "~b~F"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

    RageUI.ButtonWithStyle("Screenshot :", description, {RightLabel = "~b~F11"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

    RageUI.ButtonWithStyle("Lever les mains en l'air :", description, {RightLabel = "~b~X"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

    RageUI.ButtonWithStyle("Pointer du doigt :", description, {RightLabel = "~b~B"}, true, function(Hovered, Active, Selected) 
        if (Selected) then 
        end 
    end)

        end,function()
        end)
                  
                  Wait(0)
                end
            end)
        end
    end

------------------------------------------- Ouverture du menu ---------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1,166) then
            openMenu()
            ESX.TriggerServerCallback('get:sim', function(keys)
                cartesim = keys
            ESX.TriggerServerCallback('get:key', function(keys)
                clevoiture = keys
                end)
            end)
        end
    end
end)

-------------------------------------------------------------------------------------------------------------------

-- Discord 

RegisterCommand("discord",function()
	discordapp()
end)

function discordapp()
	ESX.ShowNotification("~g~Bienvenue~s~ \nVoici le lien Discord du serveur : ~o~https://discord.gg/Five-Dev")
end

--- DP

function emote()
	TriggerEvent('dp:RecieveMenu')
end

-------------------------------------------------------------------------------------------------------------------

-- Vétements

RegisterNetEvent('changerhaut')
AddEventHandler('changerhaut', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.torso_1 ~= skinb.torso_1 then
                vethaut = true
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = skina.torso_1, ['torso_2'] = skina.torso_2, ['tshirt_1'] = skina.tshirt_1, ['tshirt_2'] = skina.tshirt_2, ['arms'] = skina.arms})
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['torso_1'] = 15, ['torso_2'] = 0, ['tshirt_1'] = 15, ['tshirt_2'] = 0, ['arms'] = 15})
                vethaut = false
            end
        end)
    end)
end)

RegisterNetEvent('changerpantalon')
AddEventHandler('changerpantalon', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtrousers', 'try_trousers_neutral_c'

            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())

            if skina.pants_1 ~= skinb.pants_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = skina.pants_1, ['pants_2'] = skina.pants_2})
                vetbas = true
            else
                vetbas = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 15, ['pants_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['pants_1'] = 61, ['pants_2'] = 1})
                end
            end
        end)
    end)
end)


RegisterNetEvent('changerchaussure')
AddEventHandler('changerchaussure', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingshoes', 'try_shoes_positive_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.shoes_1 ~= skinb.shoes_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = skina.shoes_1, ['shoes_2'] = skina.shoes_2})
                vetch = true
            else
                vetch = false
                if skina.sex == 1 then
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 35, ['shoes_2'] = 0})
                else
                    TriggerEvent('skinchanger:loadClothes', skinb, {['shoes_1'] = 34, ['shoes_2'] = 0})
                end
            end
        end)
    end)
end)

RegisterNetEvent('changersac')
AddEventHandler('changersac', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bags_1 ~= skinb.bags_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = skina.bags_1, ['bags_2'] = skina.bags_2})
                vetsac = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bags_1'] = 0, ['bags_2'] = 0})
                vetsac = false
            end
        end)
    end)
end)


RegisterNetEvent('changergpb')
AddEventHandler('changergpb', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skina)
        TriggerEvent('skinchanger:getSkin', function(skinb)
            local lib, anim = 'clothingtie', 'try_tie_neutral_a'
            ESX.Streaming.RequestAnimDict(lib, function()
                TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
            end)
            Citizen.Wait(1000)
            ClearPedTasks(PlayerPedId())
            if skina.bproof_1 ~= skinb.bproof_1 then
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = skina.bproof_1, ['bproof_2'] = skina.bproof_2})
                vetgilet = true
            else
                TriggerEvent('skinchanger:loadClothes', skinb, {['bproof_1'] = 0, ['bproof_2'] = 0})
                vetgilet = false
            end
        end)
    end)
end)
