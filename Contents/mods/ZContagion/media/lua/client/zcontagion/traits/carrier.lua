local Carrier = {}

---@param player IsoPlayer
Carrier.OnPlayerDeath = function(player)
    if not player:HasTrait("Carrier") then return end
    player:getBodyDamage():setInfectionLevel(1)
end

Events.OnPlayerDeath.Add(Carrier.OnPlayerDeath)

return Carrier