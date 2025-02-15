

ISAutoFitnessUI = ISPanelJoypad:derive("ISAutoFitnessUI");
ISAutoFitnessUI.instance = {};

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

local function noise(str)
	if getDebug() then print(str) end
end


function ISAutoFitnessUI:setVisible(bVisible)
	if self.javaObject == nil then
		self:instantiate();
	end
	self.javaObject:setVisible(bVisible);
	if self.visibleTarget and self.visibleFunction then
		self.visibleFunction(self.visibleTarget, self);
	end
end

function ISAutoFitnessUI:initialise()
	ISPanelJoypad.initialise(self);
	local btnWid = 100

	self.ok = ISButton:new(UI_BORDER_SPACING+1, self:getHeight() - BUTTON_HGT - UI_BORDER_SPACING - 1, btnWid, BUTTON_HGT, "       Start", self, ISAutoFitnessUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	--self.ok:setImage(getTexture("media/ui/AutoFitnessUI_black.png"))
	self.ok:setImage(getTexture("media/ui/AutoFitnessUI_white.png"))
	self.ok.borderColor = 	{ r = 0.81, g = 0.57, b = 0.47 , a=1}
	self:addChild(self.ok);

	self.cancel = ISButton:new(self.ok:getRight() + UI_BORDER_SPACING, self.ok.y, btnWid, BUTTON_HGT, getText("UI_Cancel"), self, ISAutoFitnessUI.onClick);
	self.cancel.internal = "CANCEL";
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise();
	self.cancel:instantiate();
	self.cancel.borderColor = self.buttonBorderColor;
	self:addChild(self.cancel);

	self.close = ISButton:new(self:getWidth() - btnWid - UI_BORDER_SPACING - 1, self.ok.y, btnWid, BUTTON_HGT, getText("UI_Close"), self, ISAutoFitnessUI.onClick);
	self.close.internal = "CLOSE";
	self.close.anchorLeft = false
	self.close.anchorRight = true
	self.close.anchorTop = false
	self.close.anchorBottom = true
	self.close:initialise();
	self.close:instantiate();
	self.close.borderColor = self.buttonBorderColor;
	self:addChild(self.close);

	-- reset values, DEBUG ONLY!
--	self.resetBtn = ISButton:new(self.close.x - btnWid - 2, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, "Reset Val", self, ISAutoFitnessUI.onClick);
--	self.resetBtn.internal = "RESETVALUES";
--	self.resetBtn.anchorLeft = false
--	self.resetBtn.anchorRight = true
--	self.resetBtn.anchorTop = false
--	self.resetBtn.anchorBottom = true
--	self.resetBtn:initialise();
--	self.resetBtn:instantiate();
--	self.resetBtn.borderColor = self.buttonBorderColor;
--	self:addChild(self.resetBtn);

	-- exercises type
	self.exercises = ISRadioButtons:new(UI_BORDER_SPACING + 1, 50, 120, 20, self, ISAutoFitnessUI.clickedExe)
	self.exercises.choicesColor = {r=1, g=1, b=1, a=1}
	self.exercises:initialise()
	self.exercises.autoWidth = true;
	self:addChild(self.exercises)
	self:updateExercises();

	self.barHgt = BUTTON_HGT
	self.barY = self.exercises:getBottom() + 10
	local barBottom = self.barY + self.barHgt

	-- time
	self.timeLbl = ISLabel:new (self.exercises.x, barBottom + 5, FONT_HGT_SMALL, getText("IGUI_FitnessTime"), 1, 1, 1, 1, UIFont.Small, true)
	self.timeLbl:initialise();
	self.timeLbl:instantiate();
	self:addChild(self.timeLbl)

	self.exeTime = ISTextEntryBox:new("10", self.timeLbl.x, self.timeLbl.y + self.timeLbl:getHeight() + 7, BUTTON_HGT, BUTTON_HGT)
	self.exeTime:initialise();
	self.exeTime:instantiate();
	self.exeTime.font = UIFont.Medium
	self.exeTime:setOnlyNumbers(true);
	self.exeTime:setEditable(false);
	self:addChild(self.exeTime)

	-- +/- buttons
	self.plusBtn = ISButton:new(self.exeTime.x + self.exeTime:getWidth() + UI_BORDER_SPACING, self.exeTime.y, BUTTON_HGT, BUTTON_HGT, "+", self, self.onClickTime)
	self.plusBtn:initialise();
	self.plusBtn:instantiate();
	self.plusBtn.internal = "TIMEPLUS";
	self:addChild(self.plusBtn)

	self.minusBtn = ISButton:new(self.plusBtn.x + self.plusBtn:getWidth() + UI_BORDER_SPACING, self.exeTime.y, BUTTON_HGT, BUTTON_HGT, "-", self, self.onClickTime)
	self.minusBtn:initialise();
	self.minusBtn:instantiate();
	self.minusBtn.internal = "TIMEMINUS";
	self:addChild(self.minusBtn)

    self.autoCheckbox = ISTickBox:new(UI_BORDER_SPACING+110, 251, 100, FONT_HGT_SMALL+4, "", self, ISAutoFitnessUI.onAutoToggle)--AUTO
    self.autoCheckbox:initialise()
    self.autoCheckbox:addOption("AUTO")
    self:addChild(self.autoCheckbox)
	self.autoCheckbox.textColor = { r = 0.19, g = 0.02, b = 0.9, a=1}


	self:setHeight(self.minusBtn:getBottom() + 10 + BUTTON_HGT + UI_BORDER_SPACING + 1)

	-- tooltip of selected exercise
	self.tooltipLbl = ISRichTextPanel:new(self.exercises.x + self.exercises:getWidth() + 10, self.exercises.y, self:getWidth() - (self.exercises.x + self.exercises:getWidth() + 20), 150);
	self.tooltipLbl:initialise();
	self:addChild(self.tooltipLbl);

	self.tooltipLbl.background = false;
	self.tooltipLbl.autosetheight = true;
	self.tooltipLbl.clip = true
	self.tooltipLbl.text = "";
	self.tooltipLbl:paginate();

	self.selectedExe = "squats";
	self:selectedNewExercise();

	self:insertNewLineOfButtons(self.exercises)
	self:insertNewLineOfButtons(self.plusBtn, self.minusBtn)
	self:insertNewLineOfButtons(self.ok, self.cancel, self.close)
end

function ISAutoFitnessUI:onClickTime(button)
	local currentTime = tonumber(self.exeTime:getInternalText());

	if button.internal == "TIMEPLUS" and currentTime < 60 then
		currentTime = currentTime + 10;
	end
	if button.internal == "TIMEMINUS" and currentTime > 10 then
		currentTime = currentTime - 10;
	end
	self.exeTime:setText(currentTime .. "");
end

function ISAutoFitnessUI:clickedExe(buttons, index)

	for i=1,#self.exercises.options do
		if self.exercises:isSelected(i) then
			self.selectedExe = self.exercises:getOptionData(i);
			self:selectedNewExercise();
			return;
		end
	end
end

function ISAutoFitnessUI:updateExercises()
	self.exercises:clear();

	for i,v in pairs(FitnessExercises.exercisesType) do
		self:addExerciseToList(i, v);
	end


end

function ISAutoFitnessUI:selectedNewExercise()
	self.exeData = FitnessExercises.exercisesType[self.selectedExe];
	self.tooltipLbl.text = "";
	if self.exeData.tooltip then
--		self.tooltipLbl:setName(self.exeData.tooltip);
		self.tooltipLbl.text = self.exeData.tooltip;
	end
	if self.exeData.stiffness then
		local stiffnessTable = luautils.split(self.exeData.stiffness, ",");
		for i,v in ipairs(stiffnessTable) do
			if v == "legs" then
				self.tooltipLbl.text = self.tooltipLbl.text .. " <LINE> " .. getText("IGUI_Fitness_LegsStiffness");
			elseif v == "arms" then
				self.tooltipLbl.text = self.tooltipLbl.text .. " <LINE> " .. getText("IGUI_Fitness_ArmsStiffness");
			elseif v == "abs" then
				self.tooltipLbl.text = self.tooltipLbl.text .. " <LINE> " .. getText("IGUI_Fitness_AbsStiffness");
			end
		end
--		print(stiffnessTable, stiffnessTable[1], stiffnessTable[2]);
	end
	if ISAutoFitnessUI.ShowExtraInfo then
		if self.exeData.stiffness == "legs" then
			self.tooltipLbl.text = self.tooltipLbl.text .. getText("IGUI_Fitness_LegsStiffness");
		end
		self.currentRegularity = self.player:getFitness():getRegularity(self.selectedExe);
	end
	self.tooltipLbl:paginate();
end

function ISAutoFitnessUI:addExerciseToList(type, data)
	local text = data.name;
	local enabled = true;
	if data.item and not self.player:getInventory():contains(data.item, true) then
		enabled = false;
		text = text .. getText("IGUI_FitnessNeedItem", getItemDisplayName(data.item))
	end
	self.exercises:addOption(text, type, nil, enabled);
end


function ISAutoFitnessUI:render()
	ISPanelJoypad.render(self);
	local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
	local currentAction = actionQueue.queue[1]
	self:updateButtons(currentAction);
	if ISAutoFitnessUI.ShowExtraInfo then
		self:drawText("Current exe Regularity: " .. round(self.currentRegularity, 4), 10, 10, 1,1,1,1, UIFont.Small);
		self:drawText("Stiffness in " .. self.fitness:getCurrentExeStiffnessTimer(self.exeData.stiffness) .. " (" .. self.fitness:getCurrentExeStiffnessInc(self.exeData.stiffness) .. ")", 10, 22, 1,1,1,1, UIFont.Small);
	end

	self:drawProgressBar(self.exercises.x, self.barY, self.regularityProgressBarWidth, self.barHgt, self:getCurrentRegularity() * 1.5, self.fgBar)
	self:drawRectBorder(self.exercises.x, self.barY, self.regularityProgressBarWidth, self.barHgt, 1.0, 0.5, 0.5, 0.5);
	self:drawTextCentre(getText("IGUI_FitnessRegularity"), self.exercises.x + 75, self.barY + (self.barHgt - FONT_HGT_SMALL) / 2, 1,1,1,1, UIFont.Small);
end

function ISAutoFitnessUI:getCurrentRegularity()
	return (self.player:getFitness():getRegularity(self.selectedExe) / self.regularityProgressBarWidth);
end

function ISAutoFitnessUI:prerender()
	local z = 20;
	local splitPoint = 100;
	local x = 10;
	self:drawRect(0, 0, self:getWidth(), self:getHeight(), self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	self:drawTextCentre("Auto Exercise", self:getWidth()/2, self.titleY, 1,1,1,1, UIFont.Medium);
	if self.joyfocus and self:getJoypadFocus() == self.ok then
		self:setISButtonForA(self.ok)
	else
		self.ISButtonA = nil
		self.ok.isJoypad = false
	end
end

-----------------------    **        ---------------------------
function ISAutoFitnessUI.isTired(pl)
	local bool = false
	local EnduranceLevelTreshold = SandboxVars.AutoFitness.EnduranceLevelTreshold  or 2
	if pl:getMoodles():getMoodleLevel(MoodleType.Endurance) > EnduranceLevelTreshold then bool = true end
	if pl:getMoodles():getMoodleLevel(MoodleType.Pain) >= 3 then bool = true end
	if pl:getStats():getEndurance() < 0.3 then bool = true end
	if pl:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) >= 2 then bool = true end
	return bool
end


function ISAutoFitnessUI:endpanel()
	self:removeFromUIManager();
	ISAutoFitnessUI.instance[self.player:getPlayerNum()+1] = nil;
end


function ISAutoFitnessUI:isDoingWorkout()
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
    local currentAction = actionQueue.queue[1]
    return currentAction and (currentAction.Type == "ISFitnessAction" or currentAction.Type == "ISAutoFitnessAction")
end


--player should repeat exercise if not yet tired
--player should sit down if tired
--player should stand up and repeat exercise when its no longer tired and dont have any action queued
function ISAutoFitnessUI:MainListener()
	print("MainListener")
    local isDoingWorkout = self:isDoingWorkout()
    local isNoAction = self.player:getCharacterActions():isEmpty()
    local isJustMoved = self.player:isJustMoved()
    local isSitting = self.player:isCurrentState(PlayerSitOnGroundState.instance())
    local isIdle = self.player:isCurrentState(IdleState.instance())
    local isTired = ISAutoFitnessUI.isTired(self.player)
	local ExerciseEnded = self.player:getVariableBoolean("ExerciseEnded")
    if self.autoRepeat then
--[[ 		self.player:setVariable("ExerciseStarted", false);
		self.player:setVariable("ExerciseEnded", true);
 ]]
        if isNoAction and not isJustMoved and not self.player:getVehicle() then
            if isTired then
                if isIdle and not isSitting then
                    ISTimedActionQueue.add(ISSitOnGround:new(self.player))
                end
            else
                if isSitting then
                    ISTimedActionQueue.add(ISWaitWhileGettingUp:new(self.player))
                else
					if not isDoingWorkout or ExerciseEnded   then
						local action = ISAutoFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self.exeData, self.exeData.type)
						action.fitnessUI = self
						ISTimedActionQueue.addGetUpAndThen(self.player, action)
					end
                end
            end
        end
        if isDoingWorkout then
            ISTimedActionQueue.clear(self.player)
        end
    else
        ISTimedActionQueue.clear(self.player)
    end
end


-----------------------            ---------------------------

function ISAutoFitnessUI:updateButtons(currentAction)
	self.cancel.enable = false;
	self.ok.enable = true;
	if currentAction and (currentAction.Type == "ISFitnessAction") and currentAction.action then
		self.cancel.enable = true;
	end
	if currentAction and (currentAction.Type == "ISAutoFitnessAction") and currentAction.action then
		self.cancel.enable = true;
	end
	if self.player:getMoodles():getMoodleLevel(MoodleType.Endurance) > ISAutoFitnessUI.enduranceLevelTreshold then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_TooExhaustedFitness");
	end
	if self.player:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) > 2 then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_TooHeavyFitness");
	end
--[[ 	if self.player:getVariableBoolean("sitonground") or self.player:isSittingOnFurniture() then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_StandStillFitness");
	end ]]
	if self.player:getVehicle() then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_CantDriveAndFitness");
		self:endpanel()
	end
	if self.player:getMoodles():getMoodleLevel(MoodleType.Pain) > 3 then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_TooMuchPainFitness");
	end
	if self.player:isClimbing() then
		self.ok.enable = false;
	end
	if  ISAutoFitnessUI.isTired(plself.player) then
		self.ok.enable = false;
	end
	print("self.ok.enable  "..self.ok.enable)
	getPlayer():setHaloNote("self.ok.enable  "..tostring(self.ok.enable),150,250,150,900)
	-----------------------            ---------------------------
end



function ISAutoFitnessUI:equipItems()
	if self.exeData.item and not self.player:getInventory():contains(self.exeData.item, true) then
		return false;
	end
	if not self.exeData.prop then
		ISInventoryPaneContextMenu.unequipItem(self.player:getPrimaryHandItem(), self.player:getPlayerNum())
		if not self.player:isItemInBothHands(self.player:getPrimaryHandItem()) then
			ISInventoryPaneContextMenu.unequipItem(self.player:getSecondaryHandItem(), self.player:getPlayerNum())
		end
	end
	if self.exeData.prop == "twohands" then
		ISWorldObjectContextMenu.equip(self.player, self.player:getPrimaryHandItem(), self.exeData.item, true, true);
	end
	if self.exeData.prop == "primary" then
		ISWorldObjectContextMenu.equip(self.player, self.player:getPrimaryHandItem(), self.exeData.item, true, false);
		self.player:setSecondaryHandItem(nil);
	end
	if self.exeData.prop == "switch" then
		ISWorldObjectContextMenu.equip(self.player, self.player:getPrimaryHandItem(), self.exeData.item, true, false);
		self.player:setSecondaryHandItem(nil);
	end
		-----------------------            ---------------------------

	if not self.isShouldKeep then
		for i=0,self.player:getWornItems():size()-1 do
			local item = self.player:getWornItems():get(i):getItem();
			if item and instanceof(item, "InventoryContainer") then
				ISTimedActionQueue.add(ISUnequipAction:new(self.player, item, 50));
			end
		end
	end
	-----------------------            ---------------------------
	return true;
end


function ISAutoFitnessUI:getLastAction()
  local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
  local lastAction = actionQueue.queue[#actionQueue.queue]
  if lastAction then
    return lastAction
  end
  return nil
end

function ISAutoFitnessUI:getCurrentAction()
  local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
  local currentAction = actionQueue.queue[1]
  if currentAction and currentAction.action then
    return currentAction
  end
  return nil
end

function ISAutoFitnessUI:checkActions()

	--[[ if self.lastAction then
		self.player:addLineChatElement(tostring(self.lastAction.type))
		print("lastAction")
		print(tostring(self.lastAction.type))
	end
	if self.getCurrentAction then
		self.player:addLineChatElement(tostring(self.getCurrentAction.type))
		print("getCurrentAction")
		print(tostring(self.getCurrentAction.type))
	end
	 ]]
end

function ISAutoFitnessUI:onClick(button)
	if button.internal == "OK" then
--[[ 		local haveItem = self:equipItems();
		if not haveItem then return; end ]]
		if not self.autoRepeat then
			self.action = ISFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self.exeData, self.exeData.type);
			Events.OnPlayerUpdate.Remove(self:MainListener)
		else
			self.action = ISAutoFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self.exeData, self.exeData.type, true);
			Events.OnPlayerUpdate.Add(self:MainListener)
			self.player:addLineChatElement(tostring(self.selectedExe))
		end

		self.action.fitnessUI = self;
		ISTimedActionQueue.addGetUpAndThen(self.player, self.action);

		local function listener()
			local queue = ISTimedActionQueue.getTimedActionQueue(self.player)
			local currentAction = queue and queue.queue[1] or nil
--[[
			self.lastAction = self:getLastAction()
			if not self.player:hasTimedActions() then
				print(self.lastAction.type)
				self.player:setVariable("Ext", "WipeLeftArm");
				self.player:reportEvent("EventDoExt");
				if self.lastAction then
					self.player:addLineChatElement(tostring(msg))
					self.player:addLineChatElement(tostring(self.lastAction.type))
				end

			end ]]
			if self.player:isCurrentState(IdleState.instance()) or not self.player:hasTimedActions() then

				self.player:addLineChatElement(tostring(selectedExe))
				--ISAutoFitnessUI:checkActions()
				self.player:playEmote('shrug')
				print("listener removed")
				getPlayer():Say("listener removed")
				Events.OnTick.Remove(listener)
			else
				self.player:addLineChatElement(tostring(currentAction.Type))
			end
		end
		Events.OnTick.Add(listener)

		--self.player:hasTimedActions()

	elseif button.internal == "CLOSE" then
		self:setVisible(false);
		self:removeFromUIManager();
		local playerNum = self.player:getPlayerNum()
		if JoypadState.players[playerNum+1] then
			setJoypadFocus(playerNum, nil)
		end
		self.player:setVariable("Ext", "WipeLeftArm");
		self.player:reportEvent("EventDoExt");
		Events.OnPlayerUpdate.Remove(self:MainListener)
	elseif button.internal == "CANCEL" then
		self.player:setVariable("ExerciseStarted", false);
		self.player:setVariable("ExerciseEnded", true);
--		local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
--		local currentAction = actionQueue.queue[1]
--		if currentAction and (currentAction.Type == "ISFitnessAction") and currentAction.action then
--			currentAction.action:forceStop()
--		end
		self.player:setVariable("Ext", "WipeLeftArm");
		self.player:reportEvent("EventDoExt");
		Events.OnPlayerUpdate.Remove(self:MainListener)
	elseif button.internal == "RESETVALUES" then
		self.fitness:resetValues();
	end
end

function ISAutoFitnessUI:onGainJoypadFocus(joypadData)
	ISPanelJoypad.onGainJoypadFocus(self, joypadData)
	self.joypadIndexY = 1
	self.joypadIndex = 1
	self.joypadButtons = self.joypadButtonsY[self.joypadIndexY]
	self.joypadButtons[self.joypadIndex]:setJoypadFocused(true)
	self:setISButtonForB(self.cancel)
	self:setISButtonForY(self.close)
end

function ISAutoFitnessUI:onJoypadDown(button)
	ISPanelJoypad.onJoypadDown(self, button)
	if button == Joypad.BButton then
		self:onClick(self.cancel)
	end
end

function ISAutoFitnessUI:new(x, y, width, height, player, clickedSquare)
	local fontScale = FONT_HGT_SMALL / 15
	width = math.min(width * fontScale, getCore():getScreenWidth() - 150)
	height = height * fontScale
	if y == 0 then
		y = getPlayerScreenTop(player:getPlayerNum()) + (getPlayerScreenHeight(player:getPlayerNum()) - height) / 2
		y = y + 200;
	end
	if x == 0 then
		x = getPlayerScreenLeft(player:getPlayerNum()) + (getPlayerScreenWidth(player:getPlayerNum()) - width) / 2
	end
	local maxX = getCore():getScreenWidth();
	x = math.max(0, math.min(x, maxX - width));

	local o = ISPanelJoypad.new(self, x, y, width, height);
	o.backgroundColor = { r =0.047, g = 0.007, b =0.047 , a = 0.8}

	o.borderColor =  { r = 0.85, g = 0.16, b =  0.85, a = 0.61 }
	o.width = width;
	o.titleY = 10
	o.height = height;
	o.player = player;

	o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
	o.fgBarOrange = {r=1, g=0.3, b=0, a=0.7 }
	o.fgBarRed = {r=1, g=0, b=0, a=0.7 }

	o.moveWithMouse = true;
	o.clickedSquare = clickedSquare;
	o.buttonBorderColor = { r = 0.88, g = 0.22, b = 0.88, a = 1 }
	o.zoneProgress = 100;
	o.fitness = player:getFitness();
	o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
	o.regularityProgressBarWidth = 150;
	ISAutoFitnessUI.instance[player:getPlayerNum()+1] = o;
	ISAutoFitnessUI.enduranceLevelTreshold = SandboxVars.AutoFitness.EnduranceLevelTreshold or 2
	ISAutoFitnessUI.ShowExtraInfo = SandboxVars.AutoFitness.ShowExtraInfo or false
	ISAutoFitnessUI.isShouldKeep = SandboxVars.AutoFitness.KeepContainerItems or true
	o.autoRepeat = false
	o.player:getFitness():init();
	return o;
end
-----------------------            ---------------------------
function ISAutoFitnessUI.openPanel()
	local pl = getPlayer()
	if ISAutoFitnessUI.instance and ISAutoFitnessUI.instance[ pl:getPlayerNum()+1] then
		ISAutoFitnessUI.instance[ pl:getPlayerNum()+1]:removeFromUIManager();
	end
	if ISAutoFitnessUI.instance and ISAutoFitnessUI.instance[ pl:getPlayerNum()+1] and ISAutoFitnessUI.instance[ pl:getPlayerNum()+1]:isVisible() then
		return;
	end
	local modal = ISAutoFitnessUI:new(0,0, 600, 350,  pl);
	modal:initialise()
	modal:addToUIManager()
	if JoypadState.players[ pl:getPlayerNum()+1] then
		setJoypadFocus( pl:getPlayerNum(), modal)
	end
end
-----------------------            ---------------------------

function ISAutoFitnessUI:onAutoToggle()
    self.autoRepeat = self.autoCheckbox and self.autoCheckbox:isSelected(1) or false
	self.player:playSoundLocal("UIActivateTab")
	print("autoRepeat: ", tostring(self.autoRepeat))
	ISAutoFitnessUI.clicked = true
		-----------------------            ---------------------------
    if self.autoRepeat then
		self.ok:setImage(getTexture("media/ui/AutoFitnessUI_white.png"))
		self.ok.borderColor = 	{ r = 0.81, g = 0.57, b = 0.47 , a=1}
	else
		self.ok:setImage(getTexture("media/ui/AutoFitnessUI_white.png"))
		self.ok.borderColor = { r = 0.87, g = 0.74, b = 0.54, a=1}
	end
end


--[[
function ISAutoFitnessUI:MainListener()
	local isDoingWorkout  =   self:isDoingWorkout()

	local isNoAction 	  =	  self.player:getCharacterActions():isEmpty()
	local isJustMoved 	  =	  self.player:isJustMoved()

	local isSitting 	  =   self.player:isCurrentState(PlayerSitOnGroundState.instance())
	local isIdle 		  =   self.player:isCurrentState(IdleState.instance())
	local isTired 		  =   ISAutoFitnessUI.isTired(self.player)

	if self.autoRepeat then
		if isNoAction and not isJustMoved and not self.player:getVehicle() then
			if tired then
				if isIdle and not isSitting then
					ISTimedActionQueue.add(ISSitOnGround:new(self.player))
				end
			else -- not tired
				if isSitting then
					ISTimedActionQueue.add(ISWaitWhileGettingUp:new(self.player))
				else
					ISAutoFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self.exeData, self.exeData.type);
					action.fitnessUI = self;
					ISTimedActionQueue.addGetUpAndThen(self.player, self.action);
				end
			end
		end
		if isDoingWorkout then
			ISTimedActionQueue.clear(self.player)
		end
	else
		ISTimedActionQueue.clear(self.player)
	end
end
 ]]
