
ISAutoFitnessUI = ISPanelJoypad:derive("ISAutoFitnessUI");
ISAutoFitnessUI.instance = {};

ISAutoFitnessUI.enduranceLevelTreshold = SandboxVars.AutoFitness.EnduranceLevelTreshold or 2;

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local function noise(str)
	if getDebug() then print(str) end
end



function ISAutoFitnessUI:initialise()
	ISPanelJoypad.initialise(self);
	local btnWid = 100
	local btnHgt = math.max(FONT_HGT_SMALL + 3 * 2, 25)
	local padBottom = 10

	self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Ok"), self, ISAutoFitnessUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	self.ok.borderColor = self.buttonBorderColor;
	self:addChild(self.ok);

	self.cancel = ISButton:new(self.ok:getRight() + 5, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISAutoFitnessUI.onClick);
	self.cancel.internal = "CANCEL";
	self.cancel.anchorTop = false
	self.cancel.anchorBottom = true
	self.cancel:initialise();
	self.cancel:instantiate();
	self.cancel.borderColor = self.buttonBorderColor;
	self:addChild(self.cancel);

	self.close = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Close"), self, ISAutoFitnessUI.onClick);
	self.close.internal = "CLOSE";
	self.close.anchorLeft = false
	self.close.anchorRight = true
	self.close.anchorTop = false
	self.close.anchorBottom = true
	self.close:initialise();
	self.close:instantiate();
	self.close.borderColor = self.buttonBorderColor;
	self:addChild(self.close);

	-----------------------            ---------------------------

	self.restBtn = ISButton:new(self.close.x - btnWid - 5, self.close.y, btnWid, btnHgt, "REST", self, ISAutoFitnessUI.onClick);
	self.restBtn.internal = "REST";
	self.restBtn.anchorLeft = false
	self.restBtn.anchorRight = true
	self.restBtn.anchorTop = false
	self.restBtn.anchorBottom = true
	self.restBtn:initialise();
	self.restBtn:instantiate();
	self.restBtn.borderColor.g = 1;
	self:addChild(self.restBtn);

	-----------------------            ---------------------------
	self.autoTickBox = ISTickBox:new(self.close.x - btnWid - 150, self.close.y, 200, 30, "AutoMode", self, ISAutoFitnessUI.OnTickAuto)
	self.autoTickBox.internal = "AutoMode"
	self.autoTickBox.anchorLeft = false
	self.autoTickBox.anchorRight = true
	self.autoTickBox.anchorTop = false
	self.autoTickBox.anchorBottom = true
	self.autoTickBox:initialise()
	self.autoTickBox:instantiate()
	self.autoTickBox:addOption("AutoMode", false)
	self.autoTickBox:setWidthToFit()

	self.isAutoMode = self.player:getModData()['isAutoFitness'] or false
	self.autoTickBox:setSelected(1, self.isAutoMode)

	if self.isAutoMode then
		self.autoTickBox.backgroundColor = {r=0, g=1, b=0, a=1}  -- Green when AutoMode is on
	else
		self.autoTickBox.backgroundColor = {r=1, g=0, b=0, a=1}  -- Red when AutoMode is off
	end

	self:addChild(self.autoTickBox)
	self:setAuto(false)


	-----------------------            ---------------------------
	self.exercises = ISRadioButtons:new(10, 50, 120, 20, self, ISAutoFitnessUI.clickedExe)
	self.exercises.choicesColor = {r=1, g=1, b=1, a=1}
	self.exercises:initialise()
	self.exercises.autoWidth = true;
	self:addChild(self.exercises)
	self:updateExercises();

	self.barHgt = FONT_HGT_SMALL + 2 * 2
	self.barY = self.exercises:getBottom() + 10
	local barBottom = self.barY + self.barHgt

	self.timeLbl = ISLabel:new (self.exercises.x, barBottom + 5, FONT_HGT_SMALL, getText("IGUI_FitnessTime"), 1, 1, 1, 1, UIFont.Small, true)
	self.timeLbl:initialise();
	self.timeLbl:instantiate();
	self:addChild(self.timeLbl)

	self.exeTime = ISTextEntryBox:new("10", self.timeLbl.x, self.timeLbl.y + self.timeLbl:getHeight() + 7, 30, FONT_HGT_MEDIUM + 2 * 2)
	self.exeTime:initialise();
	self.exeTime:instantiate();
	self.exeTime.font = UIFont.Medium
	self.exeTime:setOnlyNumbers(true);
	self.exeTime:setEditable(false);
	self:addChild(self.exeTime)

	self.plusBtn = ISButton:new(self.exeTime.x + self.exeTime:getWidth() + 5, self.exeTime.y, self.exeTime:getHeight(), self.exeTime:getHeight(), "+", self, self.onClickTime)
	self.plusBtn:initialise();
	self.plusBtn:instantiate();
	self.plusBtn.internal = "TIMEPLUS";
	self:addChild(self.plusBtn)

	self.minusBtn = ISButton:new(self.plusBtn.x + self.plusBtn:getWidth() + 2, self.exeTime.y, self.exeTime:getHeight(), self.exeTime:getHeight(), "-", self, self.onClickTime)
	self.minusBtn:initialise();
	self.minusBtn:instantiate();
	self.minusBtn.internal = "TIMEMINUS";
	self:addChild(self.minusBtn)

	self:setHeight(self.minusBtn:getBottom() + 10 + btnHgt + padBottom)

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

function ISAutoFitnessUI:render()
	ISPanelJoypad.render(self);
	self.StiffTimer = self.fitness:getCurrentExeStiffnessTimer(self.exeData.stiffness)

	self:updateButtons();

	if getDebug() or SandboxVars.AutoFitness.ShowMuscleStiffness  then
		self:drawText("Stiffness in " .. self.fitness:getCurrentExeStiffnessTimer(self.exeData.stiffness) .. " (" .. self.fitness:getCurrentExeStiffnessInc(self.exeData.stiffness) .. ")", 10, 22, 1,1,1,1, UIFont.Small);
	end

	self:drawProgressBar(self.exercises.x, self.barY, self.regularityProgressBarWidth, self.barHgt, self:getCurrentRegularity() * 1.5, self.fgBar)
	self:drawRectBorder(self.exercises.x, self.barY, self.regularityProgressBarWidth, self.barHgt, 1.0, 0.5, 0.5, 0.5);
	self:drawTextCentre(getText("IGUI_FitnessRegularity"), self.exercises.x + 75, self.barY + (self.barHgt - FONT_HGT_SMALL) / 2, 1,1,1,1, UIFont.Small);
end

-----------------------  auto*          ---------------------------
function ISAutoFitnessUI:OnTickAuto(index, selected)
    self.isAutoMode = selected
    self.player:getModData()['isAutoFitness'] = self.isAutoMode
end

function ISAutoFitnessUI:setAuto(bool)
    self.isAutoMode = bool
    self.player:getModData()['isAutoFitness'] = bool
end


-----------------------   update*         ---------------------------

function ISAutoFitnessUI:updateButtons()
	self.player:getModData()['isAutoFitness'] = self.isAutoMode
	local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
	local currentAction = actionQueue.queue[1]
	self.close.enable = true;
	self.cancel.enable = false;
	if currentAction and (currentAction.Type == "ISFitnessAction") and currentAction.action then
		self.cancel.enable = true;
	end


	self.ok.enable = true;
	if self.player:getMoodles():getMoodleLevel(MoodleType.Endurance) > ISAutoFitnessUI.enduranceLevelTreshold then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_TooExhaustedFitness");
	end
	if self.player:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) > 2 then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_TooHeavyFitness");
	end
	if self.player:getVehicle() then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_CantDriveAndFitness");

		self:removeFromUIManager();
		ISAutoFitnessUI.instance[self.player:getPlayerNum()+1] = nil;
	end
	if self.player:getMoodles():getMoodleLevel(MoodleType.Pain) > 3 then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_TooMuchPainFitness");
	end
	if self.player:isClimbing() then
		self.ok.enable = false;
	end
--[[
	if self:isResting() then
		self.ok.enable = false;
		self.ok.tooltip = getText("Tooltip_StandStillFitness");
	end ]]

	if self.isAutoMode then
		if self:isShouldRest() then
			if not self:isResting() then
				self:sit(true)
			end
		else
			if self:isResting() then
				self:sit(false)
			else
				if not self:isFitnessQueued() then
					self:workout()
				end
			end
		end
	end
end



function ISAutoFitnessUI:isShouldRest() --self:isShouldRest()
	if not self.ok.enable then return true end
	if SandboxVars.AutoFitness.CheckStiffnessTimer then
		self.StiffTimer = self.fitness:getCurrentExeStiffnessTimer(self.exeData.stiffness)
		if self.StiffTimer > 0 then return true end
    end
	return false
end



function ISAutoFitnessUI:isResting() --if self:isResting() then end
	return self.player:getVariableBoolean("sitonground") or self.player:isCurrentState(PlayerSitOnGroundState.instance()) or self.player:isSitOnGround()
end

function ISAutoFitnessUI:sit(sitDown)	--self:sit(true) self:sit(false)
    if sitDown then
        self.player:reportEvent("EventSitOnGround")
    else
        self.player:setVariable("forceGetUp", true)
        self.player:reportEvent("EventSitOnGround")
    end
end
function ISAutoFitnessUI:workout()
	local haveItem = self:equipItems();
	if not haveItem then return; end
	self.action = ISFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self, self.exeData);
	ISTimedActionQueue.add(self.action);
end
function ISAutoFitnessUI:stop() --self:stop()
	self.player:setVariable("ExerciseStarted", false);
	self.player:setVariable("ExerciseEnded", true);
	if self:isFitnessQueued() then
		self:clearActions()
	end
end

-----------------------    click*        ---------------------------
function ISAutoFitnessUI:onClick(button)
	if button.internal == "OK" then
		self:workout()
	elseif button.internal == "REST" then

		if not self.isAutoMode then
			self:sit(not self:isResting())
		end

	elseif button.internal == "CLOSE" then
		self:setAuto(false)
		self:stop()
		local playerNum = self.player:getPlayerNum()
		if JoypadState.players[playerNum+1] then
			setJoypadFocus(playerNum, nil)
		end

		self:setVisible(false);
		self:removeFromUIManager();


	elseif button.internal == "CANCEL" then
		self:setAuto(false)
		self:stop()
	elseif button.internal == "RESETVALUES" then
		self.fitness:resetValues();
	end
end
-----------------------            ---------------------------
function ISAutoFitnessUI:isFitnessQueued() -- if not self:isFitnessQueued() then end
	local actionQueue = ISTimedActionQueue.getTimedActionQueue(self.player)
	for i = 1, #actionQueue.queue do
		local currentAction = actionQueue.queue[i]
		if currentAction and currentAction.Type == "ISFitnessAction" and currentAction.action then
			return true
		end
	end
	return false
end

function ISAutoFitnessUI:clearActions() -- self:clearActions()
	local pl = getPlayer()
	local actionQueue = ISTimedActionQueue.getTimedActionQueue(pl)
	for i, action in ipairs(actionQueue.queue) do
		if action.action then
			action.action:forceStop()
		end
	end
	ISTimedActionQueue.clear(pl)
end


-----------------------            ---------------------------

function ISAutoFitnessUI:getCurrentRegularity()
	return (self.player:getFitness():getRegularity(self.selectedExe) / self.regularityProgressBarWidth);
end

function ISAutoFitnessUI:prerender()
	local z = 20;
	local splitPoint = 100;
	local x = 10;
	self:drawRect(0, 0, self:getWidth(), self:getHeight(), self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
	self:drawRectBorder(0, 0, self:getWidth(), self:getHeight(), self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	self:drawTextCentre(getText("ContextMenu_Fitness"), self:getWidth()/2, self.titleY, 1,1,1,1, UIFont.Medium);
	if self.joyfocus and self:getJoypadFocus() == self.ok then
		self:setISButtonForA(self.ok)
	else
		self.ISButtonA = nil
		self.ok.isJoypad = false
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
--	if self.exeData.stiffness == "legs" then
--		self.tooltipLbl.text = self.tooltipLbl.text .. getText("IGUI_Fitness_LegsStiffness");
--	end
--	self.currentRegularity = self.player:getFitness():getRegularity(self.selectedExe);
	self.tooltipLbl:paginate();
end

function ISAutoFitnessUI:addExerciseToList(type, data)
	local text = data.name;
	local enabled = true;
	if data.item and not self.player:getInventory():contains(data.item, true) then
		local option = self.exercises.options[index];
		local item = InventoryItemFactory.CreateItem(data.item);
		enabled = false;
		text = text .. getText("IGUI_FitnessNeedItem", item:getDisplayName())
	end
	self.exercises:addOption(text, type, nil, enabled);
end

-- equip needed items for fitness (dumbbell..) and unequip unwanted items (weapons, bags..)
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

	for i=0,self.player:getWornItems():size()-1 do
		local item = self.player:getWornItems():get(i):getItem();
		if item and instanceof(item, "InventoryContainer") then
			ISTimedActionQueue.add(ISUnequipAction:new(self.player, item, 50));
		end
	end

	return true;
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


-----------------------            ---------------------------
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
	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=0.6};
	o.width = width;
	o.titleY = 10
	o.height = height;
	o.player = player;
	o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
	o.fgBarOrange = {r=1, g=0.3, b=0, a=0.7 }
	o.fgBarRed = {r=1, g=0, b=0, a=0.7 }
	o.moveWithMouse = true;
	o.clickedSquare = clickedSquare;
	o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5};
	o.zoneProgress = 100;
	o.fitness = player:getFitness();
	o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
	o.regularityProgressBarWidth = 150;
	ISAutoFitnessUI.instance[player:getPlayerNum()+1] = o;

	o.player:getFitness():init();
	return o;
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
