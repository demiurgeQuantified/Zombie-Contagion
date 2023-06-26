--[[ZOMBIE CONTAGION
    Copyright (C) 2022 albion

    This program is free software: you can redistribute it and/or modify
    it under the terms of Version 3 of the GNU Affero General Public License as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    For any questions, contact me through steam or on Discord - albion#0123
]]
if isClient() then return end
local Config = {}

Config.InfectionChance = 7 -- x in 100 chance at peak of infection
Config.InfectionRange = 1.5^2

Config.InfectionChanceIndoorsMultiplier = 0.25 -- when indoors, a longer range with lower infectivity is also used
Config.InfectionRangeIndoors = 5^2

Config.ResilientMultiplier = 0.45
Config.ProneToIllnessMultiplier = 1.7

Config.InjuryMultiplier = 0.2

Config.TransmitterMaskEffectiveness = 3
Config.DefaultMaskMultiplier = 0.34
Config.maskOverrides = {["Hat_BandanaMask"] = 0.44, ["Hat_BandanaMaskTINT"] = 0.44, ["Hat_DustMask"] = 0.44}

Config.PostInfectionImmuneHours = 12 -- so that infected players can be quarantined together without just re-infecting each other immediately

Config.CarrierInfectivity = 0.4

return Config