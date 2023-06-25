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
if not isServer() then return end
local ZContagion = require 'zcontagion/main'
ZContagion.InfectionChance = 7 -- x in 100 chance at peak of infection
ZContagion.InfectionRange = 1.5
ZContagion.InfectionRange = ZContagion.InfectionRange * ZContagion.InfectionRange -- square it so we can use a cheaper distance calculation
ZContagion.InfectionChanceIndoorsMultiplier = 0.25 -- when indoors, a longer range with lower infectivity is also used
ZContagion.InfectionRangeIndoors = 5
ZContagion.InfectionRangeIndoors = ZContagion.InfectionRangeIndoors * ZContagion.InfectionRangeIndoors
ZContagion.ResilientMultiplier = 0.45
ZContagion.ProneToIllnessMultiplier = 1.7
ZContagion.InjuryMultiplier = 0.2
ZContagion.TransmitterMaskEffectiveness = 3
ZContagion.DefaultMaskMultiplier = 0.34
ZContagion.PostInfectionImmuneHours = 12 -- so that infected players can be quarantined together without just re-infecting each other immediately
ZContagion.CarrierInfectivity = 0.4
