local currentProp = nil
local currentPropModel = nil -- Store the model name here
local currentBone = nil
local currentAnim = nil
local currentDict = nil
local currentFlags = nil
local isMoving = false
local moveSpeed = 0.001
local rotateSpeed = 0.15
local rotateMode = false
local mode = 'Rotate'

local propOffset = vector3(0.0, 0.0, 0.0)
local propRot = vector3(0.0, 0.0, 0.0)

-- Show control instructions and speed
function pshowControls()
	lib.showTextUI(
		'[Arrow Keys] - Move FWD & Back, Up & Down  \n' .. 
		'[LMB & RMB] - Move Left & Right  \n' ..
		'[H] - Change Rotate/Move mode  \n' ..
		'[Scroll Wheel] - Adjust Move/Rotate Speed  \n' ..
		'Current Move Speed: ' .. moveSpeed .. '  \n' ..
		'Current Rotate Speed: ' .. rotateSpeed .. '  \n' ..
		'[E] - Go Back \n',
		{ 
			position = 'right-center',
			style = {
				borderRadius = 1,
				backgroundColor = '#0d0d0d',
				color = 'orange'
			}
		}
	)
end

-- Hide control instructions
function phideControls()
    lib.hideTextUI()
end

-- Copy text to clipboard
function CopyToClipboard(data)
    SendNUIMessage({
        string = data
    })
end

-- Register the main menu
lib.registerContext({
    id = 'main_menu',
    title = 'Prop Menu',
    options = {
        { title = 'Spawn Prop', id = 'spawn_prop_menu', event = 'propMenu:spawnPropMenu' },
        { title = 'Enter Prop Model', id = 'enter_prop_model', event = 'propMenu:enterPropModel' },
        { title = 'Delete Prop', id = 'delete_prop', event = 'propMenu:deleteProp' },
        { title = 'Choose Animation', id = 'anim_menu', event = 'propMenu:animMenu' },
        { title = 'Move Object', id = 'move_object', event = 'propMenu:moveObject' },
        { title = 'Save Data', id = 'save_data', event = 'propMenu:saveData' },
        { title = 'Reset', id = 'reset_menu', event = 'propMenu:resetMenu' },
        { title = 'Cancel', id = 'cancel_menu', event = 'propMenu:cancelMenu' }
    }
})

lib.registerContext({
    id = 'main_menu2',
    title = 'Prop Menu',
    options = {
        { title = 'Spawn Prop', id = 'spawn_prop_menu', event = 'propMenu:spawnPropMenu' },
        { title = 'Enter Prop Model', id = 'enter_prop_model', event = 'propMenu:enterPropModel' },
        { title = 'Choose Animation', id = 'anim_menu', event = 'propMenu:animMenu' },
        { title = 'Cancel', id = 'cancel_menu', event = 'propMenu:cancelMenu' }
    }
})

RegisterCommand('props', function()
	lib.hideTextUI()
    lib.showContext('main_menu2')
end)

AddEventHandler('propMenu:spawnPropMenu', function()
    local propOptions = {}
    for _, prop in pairs(ConfigProps.Props) do
        table.insert(propOptions, { title = prop, event = 'propMenu:selectProp', args = { prop = prop } })
    end

    lib.registerContext({
        id = 'spawn_prop_menu',
        title = 'Select Prop',
        options = propOptions,
        menu = 'main_menu2'
    })
    lib.showContext('spawn_prop_menu')
end)

AddEventHandler('propMenu:selectProp', function(data)
    currentProp = data.prop
    currentPropModel = data.prop -- Store the model name
    lib.registerContext({
        id = 'select_bone_menu',
        title = 'Select Bone',
        options = {
            { title = 'Left Hand', event = 'propMenu:attachProp', args = { bone = 18905 } },
            { title = 'Right Hand', event = 'propMenu:attachProp', args = { bone = 57005 } },
			{ title = 'Left Foot', event = 'propMenu:attachProp', args = { bone = 14201 } },
			{ title = 'Right Foot', event = 'propMenu:attachProp', args = { bone = 52301 } },
			{ title = 'Head', event = 'propMenu:attachProp', args = { bone = 31086 } },
			{ title = 'Neck', event = 'propMenu:attachProp', args = { bone = 39317 } },
			{ title = 'Pelvis', event = 'propMenu:attachProp', args = { bone = 11816 } }
        },
        menu = 'main_menu2'
    })
    lib.showContext('select_bone_menu')
end)

AddEventHandler('propMenu:enterPropModel', function()
    local input = lib.inputDialog('Prop Model', {'Prop Model Name'})
	if input then
		print(input[1])
		currentPropModel = input[1]
		currentProp = input[1]
		lib.registerContext({
			id = 'select_bone_menu',
			title = 'Select Bone',
			options = {
				{ title = 'Left Hand', event = 'propMenu:attachProp', args = { bone = 18905 } },
				{ title = 'Right Hand', event = 'propMenu:attachProp', args = { bone = 57005 } },
				{ title = 'Left Foot', event = 'propMenu:attachProp', args = { bone = 14201 } },
				{ title = 'Right Foot', event = 'propMenu:attachProp', args = { bone = 52301 } },
				{ title = 'Head', event = 'propMenu:attachProp', args = { bone = 31086 } },
				{ title = 'Neck', event = 'propMenu:attachProp', args = { bone = 39317 } },
				{ title = 'Pelvis', event = 'propMenu:attachProp', args = { bone = 11816 } }
			},
			menu = 'main_menu2'
		})
		lib.showContext('select_bone_menu')
	else
		lib.showContext('main_menu2')
	end
end)

AddEventHandler('propMenu:attachProp', function(data)
    if currentProp then
		RequestModel(currentProp)
		while not HasModelLoaded(currentProp) do
			Wait(1)
		end
        local ped = PlayerPedId()
        local boneIndex = GetPedBoneIndex(ped, data.bone)
        currentBone = data.bone
        currentProp = CreateObject(GetHashKey(currentProp), 0.0, 0.0, 0.0, true, true, true)
        AttachEntityToEntity(currentProp, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
    lib.showContext('main_menu')
end)

AddEventHandler('propMenu:animMenu', function()
    local animOptions = {}
    for _, anim in pairs(ConfigProps.Animations) do
        table.insert(animOptions, { title = anim.label, event = 'propMenu:selectAnim', args = { anim = anim } })
    end

    if currentProp then
        lib.registerContext({
            id = 'anim_menu',
            title = 'Select Animation',
            options = animOptions,
            menu = 'main_menu'
        })
    else
        lib.registerContext({
            id = 'anim_menu',
            title = 'Select Animation',
            options = animOptions,
            menu = 'main_menu2'
        })
    end    
    lib.showContext('anim_menu')
end)

AddEventHandler('propMenu:selectAnim', function(data)
    currentAnim = data.anim.anim
    currentDict = data.anim.dict
    currentFlags = data.anim.flags
    RequestAnimDict(currentDict)
    while not HasAnimDictLoaded(currentDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), currentDict, currentAnim, 8.0, 8.0, -1, currentFlags, 0, false, false, false)
    lib.showContext('anim_menu')
end)

AddEventHandler('propMenu:moveObject', function()
    if currentProp then
        isMoving = true
        pshowControls()

        Citizen.CreateThread(function()
            while isMoving do
                Citizen.Wait(0)

                DisablePlayerFiring(PlayerId())
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)

                -- Movement controls
                if rotateMode then
                    if IsControlPressed(0, 175) then -- Right Arrow
                        propRot = vector3(propRot.x, propRot.y, propRot.z + rotateSpeed)
                    end
                    if IsControlPressed(0, 174) then -- Left Arrow
                        propRot = vector3(propRot.x, propRot.y, propRot.z - rotateSpeed)
                    end
                    if IsControlPressed(0, 172) then -- Up Arrow
                        propRot = vector3(propRot.x + rotateSpeed, propRot.y, propRot.z)
                    end
                    if IsControlPressed(0, 173) then -- Down Arrow
                        propRot = vector3(propRot.x - rotateSpeed, propRot.y, propRot.z)
                    end
					if IsDisabledControlPressed(0, 24) then -- Left Mouse Button
                        propRot = vector3(propRot.x, propRot.y + rotateSpeed, propRot.z)
                    end
                    if IsDisabledControlPressed(0, 25) then -- Right Mouse Button
                        propRot = vector3(propRot.x, propRot.y - rotateSpeed, propRot.z)
                    end
                else
                    if IsControlPressed(0, 175) then -- Right Arrow
                        propOffset = vector3(propOffset.x + moveSpeed, propOffset.y, propOffset.z)
                    end
                    if IsControlPressed(0, 174) then -- Left Arrow
                        propOffset = vector3(propOffset.x - moveSpeed, propOffset.y, propOffset.z)
                    end
                    if IsControlPressed(0, 172) then -- Up Arrow
                        propOffset = vector3(propOffset.x, propOffset.y + moveSpeed, propOffset.z)
                    end
                    if IsControlPressed(0, 173) then -- Down Arrow
                        propOffset = vector3(propOffset.x, propOffset.y - moveSpeed, propOffset.z)
                    end
                    if IsDisabledControlPressed(0, 24) then -- Left Mouse Button
                        propOffset = vector3(propOffset.x, propOffset.y, propOffset.z + moveSpeed)
                    end
                    if IsDisabledControlPressed(0, 25) then -- Right Mouse Button
                        propOffset = vector3(propOffset.x, propOffset.y, propOffset.z - moveSpeed)
                    end
                end

                -- Apply the new offset and rotation
                local ped = PlayerPedId()
                local boneIndex = GetPedBoneIndex(ped, currentBone)
                AttachEntityToEntity(currentProp, ped, boneIndex, propOffset.x, propOffset.y, propOffset.z, propRot.x, propRot.y, propRot.z, true, true, false, true, 1, true)

                -- Toggle rotate/move mode
                if IsControlJustPressed(0, 74) then -- H key
					rotateMode = not rotateMode
                    lib.notify({ title = 'Mode', description = rotateMode and 'Rotate Mode' or 'Move Mode', type = 'inform' })
                    pshowControls()
					if mode == 'Rotate' then
						mode = 'Move'
					elseif mode == 'Move' then
						mode = 'Rotate'
					end
						
                end

                -- Adjust speed
                if IsControlJustPressed(0, 15) then -- Scroll Up
                    if rotateMode then
                        rotateSpeed = rotateSpeed + 0.01
                    else
                        moveSpeed = moveSpeed + 0.01
                    end
                    pshowControls()
                end
                if IsControlJustPressed(0, 14) then -- Scroll Down
                    if rotateMode then
                        rotateSpeed = math.max(0.01, rotateSpeed - 0.01)
                    else
                        moveSpeed = math.max(0.001, moveSpeed - 0.01)
                    end
                    pshowControls()
                end

                -- Finalize movement
                if IsControlJustPressed(0, 38) then -- E key
                    isMoving = false
                    phideControls()
                    lib.showContext('main_menu')
                end
            end
        end)
    end
end)

AddEventHandler('propMenu:saveData', function()
    if currentProp and currentBone then
        local data = string.format("Model = '%s',\nBoneID = %d,\nOffset = vector3(%f, %f, %f),\nRot = vector3(%f, %f, %f),", 
            currentPropModel, currentBone, propOffset.x, propOffset.y, propOffset.z, propRot.x, propRot.y, propRot.z)
        
        CopyToClipboard(data)
        lib.notify({ title = 'Data Saved', description = data })
        lib.showContext('main_menu')
    end
end)

AddEventHandler('propMenu:resetMenu', function()
    if currentProp then
        local ped = PlayerPedId()
        local boneIndex = GetPedBoneIndex(ped, currentBone)
        AttachEntityToEntity(currentProp, ped, boneIndex, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        propOffset = vector3(0.0, 0.0, 0.0)
        propRot = vector3(0.0, 0.0, 0.0)
        lib.notify({ title = 'Reset', description = 'All settings have been reset.' })
        lib.showContext('main_menu')
    end
end)

AddEventHandler('propMenu:cancelMenu', function()
    local ped = PlayerPedId()
	if currentProp then
        DeleteEntity(currentProp)
        ClearPedTasks(ped)
        ClearPedTasksImmediately(ped)
        currentProp = nil
        currentBone = nil
        currentAnim = nil
        currentDict = nil
        currentFlags = nil
        propOffset = vector3(0.0, 0.0, 0.0)
        propRot = vector3(0.0, 0.0, 0.0)
    end
	ClearPedTasksImmediately(ped)
    lib.showContext('main_menu2')
end)

AddEventHandler('propMenu:deleteProp', function()
    if currentProp then
        DeleteEntity(currentProp)
        currentProp = nil
        lib.notify({ title = 'Deleted', description = 'Prop has been deleted.' })
        lib.showContext('main_menu')
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if currentProp then
            DeleteEntity(currentProp)
			lib.hideTextUI()
        end
    end
end)
