-- Safe Zone Script
-- Covers Police Departments, Fire Departments, and Hospitals
-- Shows plain message on screen until player leaves
-- Slows vehicles when inside Safe Zone

local safeZones = {
    -- Police Departments
    {x = 441.2, y = -981.9, z = 30.7, radius = 100.0},   -- Mission Row PD
    {x = -448.2, y = 6012.3, z = 31.7, radius = 100.0},  -- Paleto Bay PD
    {x = 1851.2, y = 3686.0, z = 34.2, radius = 100.0},  -- Sandy Shores PD

    -- Fire Departments
    {x = 1200.0, y = -1470.0, z = 34.8, radius = 100.0}, -- LS Fire Station
    {x = -379.0, y = 6118.0, z = 31.8, radius = 100.0},  -- Paleto Bay Fire Station

    -- Hospitals
    {x = 307.7, y = -1433.4, z = 29.9, radius = 120.0},  -- Pillbox Hill Medical Center
    {x = 1839.5, y = 3672.0, z = 34.3, radius = 120.0},  -- Sandy Shores Medical
    {x = -247.7, y = 6331.2, z = 32.4, radius = 120.0}   -- Paleto Bay Medical
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)

        local inSafeZone = false

        for _, zone in pairs(safeZones) do
            local dist = #(coords - vector3(zone.x, zone.y, zone.z))
            if dist < zone.radius then
                inSafeZone = true
                break
            end
        end

        if inSafeZone then
            -- Force unarmed
            SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
            -- Disable firing
            DisablePlayerFiring(player, true)
            -- Make player invincible
            SetEntityInvincible(player, true)
            -- Block melee attacks
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 140, true) -- Melee attack light
            DisableControlAction(0, 141, true) -- Melee attack heavy
            DisableControlAction(0, 142, true) -- Melee attack alternate

            -- Draw plain message constantly while inside
            DrawTxt("You are inside a Safe Zone", 0.5, 0.9)

            -- Vehicle slowdown
            if IsPedInAnyVehicle(player, false) then
                local veh = GetVehiclePedIsIn(player, false)
                -- Limit max speed (e.g., 20 mph ˜ 9 m/s)
                SetEntityMaxSpeed(veh, 9.0)
            end
        else
            -- Restore normal gameplay
            SetEntityInvincible(player, false)
            if IsPedInAnyVehicle(player, false) then
                local veh = GetVehiclePedIsIn(player, false)
                -- Reset vehicle max speed (default GTA handling)
                SetEntityMaxSpeed(veh, GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveMaxFlatVel"))
            end
        end
    end
end)

-- Helper function to draw text on screen
function DrawTxt(text, x, y)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(0.45, 0.45)
    SetTextColour(0, 255, 0, 255) -- Green text
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
