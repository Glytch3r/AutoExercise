

local hook = ISFitnessAction.stop
function ISFitnessAction:stop()

    self.character:PlayAnim("Idle");
    if not isClient() and not isServer() then
        self.character:SetVariable("FitnessFinished","true");
    end
    self.character:setVariable("ExerciseEnded", true);
    if not self.isAutoRepeat then
        setGameSpeed(1);
    end
    ISBaseTimedAction.stop(self);
end

local hook = ISFitnessAction.perform
function ISFitnessAction:perform()

	self.character:setVariable("ExerciseEnded", true);
    if not self.isAutoRepeat then
        setGameSpeed(1);
        self.character:PlayAnim("Idle");
    else

    end
	ISBaseTimedAction.perform(self);
end

-----------------------     hook*       ---------------------------
--just in case a modder needs to disable my mod or wants to do compat use
--ISAutoFitnessUI.ISFitnessActionNewHook() to call ISFitnessAction:new()
--i only needed to hook in order for me to pass the boolean isAutoRepeat
--to prevent time from setting back to 1 after each set during auto mode
ISAutoFitnessUI = ISAutoFitnessUI or {}
ISAutoFitnessUI.ISFitnessActionNewHook = ISFitnessAction.new

function ISFitnessAction:new(character, exercise, timeToExe, exeData, exeDataType, isAutoRepeat)
	local o = ISBaseTimedAction.new(self, character);
	o.character = character;
	o.exercise = exercise;
	o.timeToExe = timeToExe;
	o.exeData = exeData;
	o.exeDataType = exeDataType;
	o.switchTime = 5;
	o.switchHandUsed = "right";

	o.startMS = getGameTime():getCalender():getTimeInMillis();
	o.endMS = o.startMS + (timeToExe * 60000)
	o.maxTime = o:getDuration();
	o.fitness = character:getFitness();
	o.repnb = 0;
	o.isAutoRepeat = isAutoRepeat
	o:setFitnessSpeed();
	o.fitness:setCurrentExercise(exeDataType);
	o.caloriesModifier = 3;
	return o;
end

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

function ISFitnessUI:new(x, y, width, height, player, clickedSquare)
    ISAutoFitnessUI.openPanel()
end

function ISFitnessAction:waitToStart()
	if self.character:isAiming() then
		self.character:nullifyAiming()
	end
	if self.character:isCurrentState(IdleState.instance()) or self.character:isCurrentState(PlayerSitOnGroundState.instance()) then
		return false
    else
        return true

	end
end
