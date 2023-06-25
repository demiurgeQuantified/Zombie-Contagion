local Carrier = {}

Carrier.carrierChances = {
    [1] = 0,
    [2] = 0,
    [3] = 15,
    [4] = 30,
    [5] = 50
}

Carrier.traitModifiers = {
    ProneToIllness = -0.7,
    Resilient = 0.7,
    Lucky = 0.1,
    Unlucky = -0.1,
    Outdoorsman = 0.1,
    Asthmatic = -0.2,
    Smoker = -0.2
}

---@param player IsoPlayer
Carrier.OnPlayerDeath = function(player)
    if not player:HasTrait("Carrier") then return end
    player:getBodyDamage():setInfectionLevel(1)
end

Events.OnPlayerDeath.Add(Carrier.OnPlayerDeath)

---@param player IsoPlayer
---@return int
Carrier.getCarrierChance = function(player)
    local chance = Carrier.carrierChances[SandboxVars.ZContagion.CarrierChance]
    if chance == 0 then return 0 end

    local traits = player:getTraits()
    for i = 0, traits:size()-1 do
        local traitMult = Carrier.traitModifiers[traits:get(i)]
        if traitMult then
            chance = chance * (1 + traitMult)
        end
    end
    return math.floor(chance)
end

---@param player IsoPlayer
---@param square IsoGridSquare
Carrier.OnNewGame = function(player, square)
    if ZombRand(100) + 1 <= Carrier.getCarrierChance(player) then
        player:getTraits():add("Carrier")
        -- TODO: some way to make this hidden (removing the trait icon might be enough?)
    end
end
Events.OnNewGame.Add(Carrier.OnNewGame)

return Carrier