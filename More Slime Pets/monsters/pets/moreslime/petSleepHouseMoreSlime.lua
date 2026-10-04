local reactToObjectOld = petBehavior.reactToObject

function petBehavior.reactToObject(entityId)
local entityName = world.entityName(entityId)
if entityName == "pethouseMoreSlime" then
petBehavior.queueAction("sleep", {sleepTarget = entityId})
else
reactToObjectOld(entityId)
end
end