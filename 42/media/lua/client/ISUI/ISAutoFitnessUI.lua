
ISAutoFitnessUI = ISAutoFitnessUI or {}
-----------------------            ---------------------------
ISAutoFitnessUI = ISPanelJoypad:derive("ISAutoFitnessUI");
ISAutoFitnessUI.instance = {};
ISAutoFitnessUI.enduranceLevelTreshold = 2;

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

	self.ok = ISButton:new(UI_BORDER_SPACING+1, self:getHeight() - BUTTON_HGT - UI_BORDER_SPACING - 1, btnWid, BUTTON_HGT, getText("UI_Ok"), self, ISAutoFitnessUI.onClick);
	self.ok.internal = "OK";
	self.ok.anchorTop = false
	self.ok.anchorBottom = true
	self.ok:initialise();
	self.ok:instantiate();
	self.ok.borderColor = self.buttonBorderColor;
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

	self.exercises = ISRadioButtons:new(UI_BORDER_SPACING + 1, 50, 120, 20, self, ISAutoFitnessUI.clickedExe)
	self.exercises.choicesColor = {r=1, g=1, b=1, a=1}
	self.exercises:initialise()
	self.exercises.autoWidth = true;
	self:addChild(self.exercises)
	self:updateExercises();

	self.barHgt = BUTTON_HGT
	self.barY = self.exercises:getBottom() + 10
	local barBottom = self.barY + self.barHgt

	self.timeLbl = ISLabel:new (self.exercises.x, barBottom + 5, FONT_HGT_SMALL, getText("IGUI_FitnessTime"),  0.46, 0.84, 0.49, 1, UIFont.Small, true)
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

	-----------------------            ---------------------------
    self.autoCheckbox = ISTickBox:new(UI_BORDER_SPACING+110, 251, 100, FONT_HGT_SMALL+4, "AUTO", self, ISAutoFitnessUI.onAutoToggle)
    self.autoCheckbox:initialise()
    self.autoCheckbox:addOption("AUTO")
    self:addChild(self.autoCheckbox)
	self.autoCheckbox.textColor = { r = 0.13, g = 0.02, b = 0.13, a=1}

	-----------------------            ---------------------------


	self:setHeight(self.minusBtn:getBottom() + 10 + BUTTON_HGT + UI_BORDER_SPACING + 1)

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
-----------            ---------------------------

-----------------------            ---------------------------
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
	if SandboxVars.AutoFitness.ShowExtraInfo then
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
	local showCur = SandboxVars.AutoFitness.ShowExtraInfo or false
	if showCur then
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
	self:drawTextCentre("Auto Exercise Panel", self:getWidth()/2, self.titleY, 1,1,1,1, UIFont.Medium);
	if self.joyfocus and self:getJoypadFocus() == self.ok then
		self:setISButtonForA(self.ok)
	else
		self.ISButtonA = nil
		self.ok.isJoypad = false
	end
end

function ISAutoFitnessUI:updateButtons(currentAction)
	self.cancel.enable = false;
	self.ok.enable = true;

	if currentAction and (currentAction.Type == "ISFitnessAction") and currentAction.action then
		self.cancel.enable = true;
	end
	local thresh = SandboxVars.AutoFitness.EnduranceLevelTreshold or 2
	if self.player:getMoodles():getMoodleLevel(MoodleType.Endurance) > thresh then
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
	local isShouldKeep = SandboxVars.AutoFitness.KeepContainerItems or true
	if not isShouldKeep then
		for i=0,self.player:getWornItems():size()-1 do
			local item = self.player:getWornItems():get(i):getItem();
			if item and instanceof(item, "InventoryContainer") then
				ISTimedActionQueue.add(ISUnequipAction:new(self.player, item, 50));
			end
		end
	end
	return true;
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
-----------------------            ---------------------------

--[[
       getPlayer():setVariable("sitonground", false)

	if self.player:isSitOnGround() or self.player:isSittingOnFurniture() then

    if self.actionScript and self.actionScript:isCantSit() == true and self.character:isSitOnGround() then
        self.character:setSitOnGround(false)
    end
	self.player:setVariable("sitonground", true)
	self.player:setVariable("sitonground", false)

	 ]]
-----------------------            ---------------------------
function ISAutoFitnessUI:addGetUpAndThen(action)
    if self:canContinueExercise() then
        if self.player:isSitOnGround() or self.player:isSittingOnFurniture() then
            local getUpAction = ISAutoFitnessContinue:new(self.player)
            ISTimedActionQueue.add(getUpAction)
        end
        ISTimedActionQueue.add(action)
	else

    end
end

function ISAutoFitnessUI:onAutoToggle()
    self.autoRepeat = self.autoCheckbox and self.autoCheckbox:isSelected(1) or false
end

function ISAutoFitnessUI.canContinueExercise()
	setSitOnGround(false)
	local pl = getPlayer()
	local thresh = SandboxVars.AutoFitness.EnduranceLevelTreshold or 0
    return pl:getMoodles():getMoodleLevel(MoodleType.Endurance) <= thresh
        and pl:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) <= 2
        --and not pl:getVariableBoolean("sitonground")
        --and not pl:isSittingOnFurniture()
        and not pl:getVehicle()
        and pl:getMoodles():getMoodleLevel(MoodleType.Pain) <= 3
        and not pl:isClimbing()
end

function ISAutoFitnessUI:onClick(button)
    if button.internal == "OK" then
        local haveItem = self:equipItems()
        if not haveItem then return end

        self:startExercise() -- Call function correctly

        if self.autoRepeat then
            local function checkEndurance()
                if self:canContinueExercise() then
                    self:startExercise()
                elseif not self.player:isSitOnGround() then
					self.player:setVariable("sitonground", true)
                end
				Events.OnPlayerUpdate.Add(function()
					if self.player:getStats():getEndurance() >= 1.0 then
						self.player:setVariable("sitonground", false)
						self:startExercise()
						Events.OnPlayerUpdate.Remove(checkEndurance)
					end
				end)

            end

            Events.OnPlayerUpdate.Add(checkEndurance)
        end

        --self.player:setVariable("sitonground", false)
    elseif button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
    elseif button.internal == "CANCEL" then
        self.player:setVariable("ExerciseStarted", false)
        self.player:setVariable("ExerciseEnded", true)
    end
end

function ISAutoFitnessUI:startExercise()
    local action = ISFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self.exeData, self.exeData.type, self.autoRepeat)
    action.fitnessUI = self
    self:addGetUpAndThen(action)
end

-----------------------            ---------------------------

-----------------------            ---------------------------

function ISAutoFitnessUI:onClick(button)
    if button.internal == "OK" then
        local haveItem = self:equipItems()
        if not haveItem then return end

        local function startExercise()
            local action = ISFitnessAction:new(self.player, self.selectedExe, tonumber(self.exeTime:getInternalText()), self.exeData, self.exeData.type, self.autoRepeat)
            action.fitnessUI = self
            self:addGetUpAndThen(action)
        end

        startExercise()

        if self.autoRepeat then
            Events.OnPlayerUpdate.Add(function()
                if self:canContinueExercise() then
                    startExercise()
                else
                    self.player:setVariable("sitonground", true)
                    self.player:reportEvent("EventSitOnGround")
                    Events.OnPlayerUpdate.Add(function()
                        if self.player:getStats():getEndurance() >= 1.0 then
                            self.player:setVariable("sitonground", false)
                            startExercise()
                            Events.OnPlayerUpdate.Remove(self)
                        end
                    end)
                end
            end)
        end
    elseif button.internal == "CLOSE" then
        self:setVisible(false)
        self:removeFromUIManager()
    elseif button.internal == "CANCEL" then
        self.player:setVariable("ExerciseStarted", false)
        self.player:setVariable("ExerciseEnded", true)
    end
end

-----------------------            ---------------------------


function ISAutoFitnessUI:new(x, y, width, height, player)
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
	setmetatable(o, self)
	o.backgroundColor = { r = 0.22, g = 0.16, b = 0.31, a = 0.81 }--{ r = 0.71, g = 0.21, b = 0.31 , a = 0.41 }
	o.borderColor =  { r = 0.22, g = 0.16, b = 0.31, a = 0.61 }
	o.width = width;
	o.titleY = 10
	o.height = height;
	o.player = player;
	o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
	o.fgBarOrange = {r=1, g=0.3, b=0, a=0.7 }
	o.fgBarRed = {r=1, g=0, b=0, a=0.7 }
	o.moveWithMouse = true;
	o.buttonBorderColor = { r = 0.25, g = 0.22, b = 0.30, a = 1 }
	o.zoneProgress = 100;
	o.fitness = player:getFitness();
	o.fgBar = {r=0, g=0.6, b=0, a=0.7 }
	o.regularityProgressBarWidth = 150;
	ISAutoFitnessUI.instance[player:getPlayerNum()+1] = o;
	o.autoRepeat = false
	o.player:getFitness():init();
	return o
end
-----------------------            ---------------------------
function ISAutoFitnessUI.openPanel()
	local pl = getPlayer()
	if ISAutoFitnessUI.instance and ISAutoFitnessUI.instance[pl:getPlayerNum()+1] then
		ISAutoFitnessUI.instance[pl:getPlayerNum()+1]:removeFromUIManager();
	end
	if ISAutoFitnessUI.instance and ISAutoFitnessUI.instance[pl:getPlayerNum()+1] and ISAutoFitnessUI.instance[pl:getPlayerNum()+1]:isVisible() then
		return;
	end
	local modal = ISAutoFitnessUI:new(0,0, 600, 350, pl);
	modal:initialise()
	modal:addToUIManager()
	if JoypadState.players[pl:getPlayerNum()+1] then
		setJoypadFocus(pl:getPlayerNum(), modal)
	end
end

-----------------------            ---------------------------

--[[
function ISJoystickButtonRadialMenu.onToggleSit(playerObj)
	local playerNum = playerObj:getPlayerNum()
	if playerObj:isCurrentState(PlayerSitOnGroundState.instance()) then
		playerObj:StopAllActionQueue()
		playerObj:setVariable("forceGetUp", true)
	else
		playerObj:setAutoWalk(false)
		STATE[playerNum+1].wasAutoWalk = false
		playerObj:reportEvent("EventSitOnGround")
	end
end
 ]]

 function ISAutoFitnessUI.Context(player, context, worldobjects, test)
	local isHideMenu = SandboxVars.AutoFitness.HideContextmenu or false
	if isHideMenu then return end
	local pl = getSpecificPlayer(player)

	local optTip = context:addOption("Auto Exercise Panel", pl, function()
		ISAutoFitnessUI.openPanel()
	end)
	local tip = ISWorldObjectContextMenu.addToolTip()

	local iconPath = "media/ui/AutoFitnessUI.png"
	optTip.iconTexture = getTexture(iconPath)
	tip:setTexture(iconPath)

end
Events.OnFillWorldObjectContextMenu.Add(ISAutoFitnessUI.Context)
