
ISAutoFitnessUI = ISAutoFitnessUI or {}

-----------------------     hook*       ---------------------------
--just in case a modder needs to disable my mod or wants to do compat use
--ISAutoFitnessUI.ISFitnessUINewHook() to call ISFitnessUI:new()
--i only needed to hook in order for me to pass the boolean isAutoRepeat
--to prevent time from setting back to 1 after each set during auto mode

ISAutoFitnessUI.ISFitnessUINewHook = ISFitnessUI.new

function ISFitnessUI:new(x, y, width, height, player, clickedSquare)
    ISAutoFitnessUI.openPanel()
end
-----------------------            ---------------------------


function ISNewHealthPanel:onClick(button)
    if button.internal == "FITNESS" then
        if JoypadState.players[self.playerNum+1] then
            getPlayerInfoPanel(self.playerNum):toggleView(xpSystemText.health)
        end
        if ISAutoFitnessUI.instance and ISAutoFitnessUI.instance[self.character:getPlayerNum()+1] then
            ISAutoFitnessUI.instance[self.character:getPlayerNum()+1]:removeFromUIManager();
            ISAutoFitnessUI.instance[self.character:getPlayerNum()+1] = nil;
        end
        if ISAutoFitnessUI.instance and ISAutoFitnessUI.instance[self.character:getPlayerNum()+1] and ISAutoFitnessUI.instance[self.character:getPlayerNum()+1]:isVisible() then
            return;
        end
        local modal = ISAutoFitnessUI:new(0,0, 600, 350, self.character);
        modal:initialise()
        modal:addToUIManager()
        if JoypadState.players[self.character:getPlayerNum()+1] then
            setJoypadFocus(self.character:getPlayerNum(), modal)
        end
    end
end
-----------------------            ---------------------------

function ISAutoFitnessUI.Context(player, context, worldobjects, test)

	local isHideMenu = SandboxVars.AutoFitness.HideContextmenu or false
	if isHideMenu then return end

	local optTip = context:addOption("Auto Exercise Panel", getPlayer(), function()
		local modal = ISAutoFitnessUI:new(0,0, 600, 350,  getPlayer());
        modal:initialise()
        modal:addToUIManager()
		--ISAutoFitnessUI.openPanel()
	end)
	local tip = ISWorldObjectContextMenu.addToolTip()

	local iconPath = "media/ui/AutoFitnessUI_main.png"
	optTip.iconTexture = getTexture(iconPath)
	tip:setTexture(iconPath)

end
Events.OnFillWorldObjectContextMenu.Add(ISAutoFitnessUI.Context)
--[[
function ISAutoFitnessUI.openPanel()
    local modal = ISAutoFitnessUI:new(0,0, 600, 350, getPlayer());
    modal:initialise()
    modal:addToUIManager()
end


function ISAutoFitnessUI.context(player, context, worldobjects, test)

	local pl = getSpecificPlayer(player)




    local op = context:addOption('Auto Exercise Panel', worldobjects, function()
        ISAutoFitnessUI.openPanel()
        context:hideAndChildren()
    end)
    local tip = ISWorldObjectContextMenu.addToolTip()

    local iconPath = "media/ui/AutoFitnessUI_main.png"

    op.iconTexture = getTexture(iconPath)
    tip:setTexture(iconPath)
end
Events.OnFillWorldObjectContextMenu.Add(ISAutoFitnessUI.Context)

 ]]