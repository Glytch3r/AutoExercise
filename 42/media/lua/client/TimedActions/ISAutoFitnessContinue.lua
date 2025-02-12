

require "TimedActions/ISBaseTimedAction"
ISAutoFitnessContinue = ISBaseTimedAction:derive("ISAutoFitnessContinue")

function ISAutoFitnessContinue:perform()
    self.character:setVariable("sitonground", false)
    self.character:reportEvent("EventGetUp") -- Ensure transition occurs
    ISBaseTimedAction.perform(self)
end

function ISAutoFitnessContinue:isValid()
    return self.character:isSitOnGround() or self.character:isSittingOnFurniture()
end

function ISAutoFitnessContinue:update()
end

function ISAutoFitnessContinue:start()
    self.character:setVariable("sitonground", false)
end

function ISAutoFitnessContinue:stop()
    ISBaseTimedAction.stop(self)
end

function ISAutoFitnessContinue:new(character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.maxTime = 30
    return o
end