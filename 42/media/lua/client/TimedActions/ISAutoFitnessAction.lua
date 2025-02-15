
require "TimedActions/ISBaseTimedAction"

ISAutoFitnessAction = ISBaseTimedAction:derive("ISAutoFitnessAction");

function ISAutoFitnessAction:isValidStart()
	self.EnduranceLevelTreshold = SandboxVars.AutoFitness.EnduranceLevelTreshold or 2

	local bool =  self.character:getStats():getEndurance() > 0.3  and self.character:getMoodles():getMoodleLevel(MoodleType.Endurance) <= self.EnduranceLevelTreshold
	print(bool)
	return bool
	--ISFitnessUI.enduranceLevelTreshold
end

function ISAutoFitnessAction:isValid()
	return true
	--return self.character:getVehicle() == nil;
end

function ISAutoFitnessAction:update()

	if self.character:getMoodles():getMoodleLevel(MoodleType.Endurance) > SandboxVars.AutoFitness.EnduranceLevelTreshold then
		print("self.character:getMoodles():getMoodleLevel(MoodleType.Endurance)")
		print(self.character:getMoodles():getMoodleLevel(MoodleType.Endurance))
		print("self.EnduranceLevelTreshold")
		print(self.EnduranceLevelTreshold)
		isStop = true
		ISTimedActionQueue.add(ISSitOnGround:new(self.character))
	end
 	if self.character:getStats():getEndurance() > 0.3  then
		print("self.character:getStats():getEndurance() > 0.3  ")
		print(self.character:getStats():getEndurance() )
		isStop = true
		ISTimedActionQueue.add(ISSitOnGround:new(self.character))
	end


	if self.character:isClimbing() or self.character:isAiming() then
		self:forceStop();
	end
	if self.character:isSneaking() then
		self.character:setSneaking(false)
	end
	if self.character:pressedMovement(true) or self.character:getMoodles():getMoodleLevel(MoodleType.Endurance) > ISFitnessUI.enduranceLevelTreshold then
		self.character:setVariable("ExerciseStarted", false);
		self.character:setVariable("ExerciseEnded", true);
	end

	if getGameTime():getCalender():getTimeInMillis() > self.endMS then
		self.character:setVariable("ExerciseStarted", false);
		self.character:setVariable("ExerciseEnded", true);
		self:forceStop();
	end

	self.character:setMetabolicTarget(self.exeData.metabolics);
end

function ISAutoFitnessAction:start()
	self.action:setUseProgressBar(false)
	if self.character:getCurrentState() ~= FitnessState.instance() then
		self.character:setVariable("ExerciseType", self.exercise);
		self.character:reportEvent("EventFitness");
		self.character:clearVariable("ExerciseStarted");
		self.character:clearVariable("ExerciseEnded");

		self.character:reportEvent("EventUpdateFitness");
	end
end

function ISAutoFitnessAction:showHandModel()
	if self.exeData.item then
		local pr = self.character:getPrimaryHandItem()
		local sr = self.character:getSecondaryHandItem()
		if pr and pr:getType() == self.exeData.item then
			self:setOverrideHandModels(pr:getStaticModel(), nil);
		elseif sr and sr:getType() == self.exeData.item then
			self:setOverrideHandModels(nil, sr:getStaticModel());
		end
	else
		self:setOverrideHandModels(nil, nil);
	end
end
-----------------------            ---------------------------
--[[
function ISAutoFitnessAction:waitToStart()
	if self.character:isAiming() then
		self.character:nullifyAiming()
	end
	if self.character:isSneaking() then
		self.character:setSneaking(false)
	end
	if not self.character:isCurrentState(IdleState.instance()) then
		return true
	end
	return false
end
 ]]

function ISAutoFitnessAction:waitToStart()
	if self.character:isAiming() then
		self.character:nullifyAiming()
	end
	if self.character:isSneaking() then
		self.character:setSneaking(false)
	end
	if  self.character:isCurrentState(IdleState.instance()) or  self.character:isCurrentState(PlayerSitOnGroundState.instance()) then

		return false
	end
	return true
end
function ISAutoFitnessAction:stop()
	--self.character:PlayAnim("Idle");

	if not isClient() and not isServer() then
		self.character:SetVariable("FitnessFinished","true");
	end

	self.character:setVariable("ExerciseEnded", true);
	ISBaseTimedAction.stop(self);
end
--[[ function ISAutoFitnessAction:perform()
	self.character:PlayAnim("Idle");
	self.character:setVariable("ExerciseEnded", true);

	ISBaseTimedAction.perform(self);
end
 ]]
function ISAutoFitnessAction:perform()
	-- Perform fitness action
	self.character:getXp():AddXP(Perks.Fitness, 1)

	-- Check endurance after action
	if self.character:getMoodles():getMoodleLevel(MoodleType.Endurance) <= self.EnduranceLevelTreshold or self.character:getStats():getEndurance() > 0.3 then
		if  self.character:isCurrentState(PlayerSitOnGroundState.instance()) then
			ISTimedActionQueue.add(ISWaitWhileGettingUp:new(self.character))
		end
		local action = ISAutoFitnessAction:new(self.character, self.exercise, tonumber(self.timeToExe()), self.exeData, self.exeDataType, self.isAutoRepeat)
		ISTimedActionQueue.add(action)
	else
		if self.character:isCurrentState(IdleState.instance()) then
			ISTimedActionQueue.add(ISSitOnGround:new(self.character))

		end
		--ISTimedActionQueue.add(ISWaitWhileGettingUp:new(self.character))

		--ISTimedActionQueue.add(ISSitOnGround:new(self.character))

	end
	self.character:addLineChatElement(tostring('perform'))
	ISBaseTimedAction.perform(self)
end



function ISAutoFitnessAction:perform()
	self.character:PlayAnim("Idle");
	self.character:setVariable("ExerciseEnded", true);

	self.character:addLineChatElement(tostring('perform'))
	if self.character:isCurrentState(IdleState.instance()) then
		ISTimedActionQueue.add(ISSitOnGround:new(self.character))
	else
		ISTimedActionQueue.add(ISWaitWhileGettingUp:new(self.character))
	end

	self.character:setHaloNote(tostring("perform"),150,250,150,900)
	ISBaseTimedAction.perform(self);
end

-----------------------            ---------------------------

function ISAutoFitnessAction:complete()
	if not isClient() and not isServer() then
		self.character:SetVariable("FitnessFinished","true");
	end
	emulateAnimEventOnce(self.netAction, 100, nil, "FitnessFinished=TRUE")

	self.character:addLineChatElement(tostring('complete'))
	if self.character:isCurrentState(IdleState.instance()) then
		ISTimedActionQueue.add(ISSitOnGround:new(self.character))
	else
		ISTimedActionQueue.add(ISWaitWhileGettingUp:new(self.character))
	end

	return true;
end


function ISAutoFitnessAction:exeLooped()
	self.repnb = self.repnb + 1;
	self.fitness:exerciseRepeat();
	self:setFitnessSpeed();
end

function ISAutoFitnessAction:serverStart()
	self.fitness = self.character:getFitness();
	self.fitness:init();
	self.fitness:setCurrentExercise(self.exeDataType);
	local period = 0;
	if self.exeDataType == "squats" then
		period = 3000;
	elseif self.exeDataType == "pushups" then
		period = 1300;
	elseif self.exeDataType == "burpees" then
		period = 2400;
	elseif self.exeDataType == "barbellcull" then
		period = 2200;
	elseif self.exeDataType == "dumbbellpress" then
		period = 1500;
	elseif self.exeDataType == "bicepscurl" then
		period = 1900;
	end
	emulateAnimEvent(self.netAction, period, "ActiveAnimLooped", nil)
end

function ISAutoFitnessAction:serverStop()
	emulateAnimEventOnce(self.netAction, 100, nil, "FitnessFinished=TRUE")
end

function ISAutoFitnessAction:animEvent(event, parameter)
	local isSinglePlayerMode = (not isClient() and not isServer());

	if isServer() or isSinglePlayerMode then
		if parameter == "FitnessFinished=TRUE" then
			self:forceStop();
		--	ISTimedActionQueue.clear(pl)

		end

		if event == "ActiveAnimLooped" then
			self:exeLooped();
		end
	else
		if event == "ActiveAnimLooped" then
			if self.exeData.prop == "switch" then
				self.switchTime = self.switchTime -1;
				if self.switchTime == 1 then
					self.switchTime = 5;
					if self.switchHandUsed == "right" then
						self.switchHandUsed = "left";
						self.character:setVariable("ExerciseHand", "left");
						self.character:setSecondaryHandItem(self.character:getPrimaryHandItem());
						self.character:setPrimaryHandItem(nil);
					else
						self.switchHandUsed = "right";
						self.character:clearVariable("ExerciseHand");
						self.character:setPrimaryHandItem(self.character:getSecondaryHandItem());
						self.character:setSecondaryHandItem(nil);
					end
				end
			end
			self.character:reportEvent("EventUpdateFitness");
		end
	end
end

function ISAutoFitnessAction:setFitnessSpeed()
	self.character:setFitnessSpeed()
end

function ISAutoFitnessAction:getDuration()
	return SandboxVars.AutoFitness.ActionDuration or 5000000
end

function ISAutoFitnessAction:new(character, exercise, timeToExe, exeData, exeDataType, isAutoRepeat)
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
	o.isAutoRepeat = isAutoRepeat or true
	o:setFitnessSpeed();
	o.fitness:setCurrentExercise(exeDataType);
	o.caloriesModifier = SandboxVars.AutoFitness.CaloriesModifier or 3
	return o;
end