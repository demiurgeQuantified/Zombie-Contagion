local Carrier = {}
Carrier.wantRandomCarriers = true
Carrier.carrierChance = 5

---@param player IsoPlayer
Carrier.OnPlayerDeath = function(player)
    if not player:HasTrait("Carrier") then return end
    player:getBodyDamage():setInfectionLevel(1)
end

Events.OnPlayerDeath.Add(Carrier.OnPlayerDeath)

---@param player IsoPlayer
---@param square IsoGridSquare
Carrier.OnNewGame = function(player, square)
    if not Carrier.wantRandomCarriers then return end -- TODO: add sandbox option
    if ZombRand(100) + 1 <= Carrier.carrierChance then
        player:getTraits():add("Carrier")
        -- TODO: some way to make this hidden (removing the trait icon might be enough?)
    end
end
Events.OnNewGame.Add(Carrier.OnNewGame)

return Carrier