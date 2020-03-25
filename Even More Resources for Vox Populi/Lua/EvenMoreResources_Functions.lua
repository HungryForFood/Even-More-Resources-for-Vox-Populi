--=======================================================================================================================
-- Scripts for Rice and Maize Farms:
-- ---------------------------------
-- What these scripts do is workaround the fact we can't add Crop textures in any way (we can add them but there's no way of referencing the new ones)
-- In order to do this, we are changing all plots that are of America and Asia continents. Except for those with our required resources.
-- The plots with our required resources are assigned the correct continent (America for Maize, Asia for Rice)
--=======================================================================================================================
--=======================================================================================================================
-- To use simply change these resource definitions
-------------------------------
-- The idea of this workaround is from CustomFarm_Scripts.lua from the Bonus Resources Expanded mod by Hammurabi1337, with contributions from Leugi/

print("EvenMoreResources_Functions.lua has loaded")
--=======================================================================================================================
-- INCLUDES
--=======================================================================================================================
include("HFF_SaveUtils.lua")
include("EvenMoreResources_Utilities.lua"); MY_MOD_NAME = "EvenMoreResources_Functions"
--=======================================================================================================================
-- GLOBALS
--=======================================================================================================================
------------------------------------------------------------------------------------------------------------------------
local g_tonumber = tonumber
--=======================================================================================================================
-- GAMES DEFINES
--=======================================================================================================================
------------------------------------------------------------------------------------------------------------------------
iResourceRice = GameInfoTypes["RESOURCE_RICE"]
iContinentRice = 2 -- Asia

iResourceMaize = GameInfoTypes["RESOURCE_MAIZE"]
iContinentMaize = 1 -- America

iResourceWheat = GameInfoTypes["RESOURCE_WHEAT"]

iImprovementFarm = GameInfoTypes["IMPROVEMENT_FARM"]
--=======================================================================================================================
-- CORE FUNCTIONS
--=======================================================================================================================
-- this one is called when a farm is placed on the map
function DoChangeContinent (iPlotX, iPlotY, iOwner, iImprovementOld, iImprovementNew, bPillaged) 
	if iImprovementNew == iImprovementFarm and iImprovementOld ~= iImprovementFarm then
		pPlot = Map.GetPlot(iPlotX, iPlotY)
		iContinentCurrent = pPlot:GetContinentArtType()
		if pPlot:GetResourceType() == iResourceRice and iContinentCurrent ~= iContinentRice then
			pPlot:SetContinentArtType(iContinentRice)
			save(pPlot, "OriginalContinent", iContinentCurrent)
		elseif pPlot:GetResourceType() == iResourceMaize and iContinentCurrent ~= iContinentMaize then
			pPlot:SetContinentArtType(iContinentMaize)
			save(pPlot, "OriginalContinent", iContinentCurrent)
		elseif (pPlot:GetResourceType() ~= iResourceWheat) and (iContinentCurrent == iContinentRice or iContinentCurrent == iContinentMaize) then
			pPlot:SetContinentArtType(iContinentCurrent + 2)
			save(pPlot, "OriginalContinent", iContinentCurrent)
		end
	end
end
GameEvents.TileImprovementChanged.Add(DoChangeContinent) -- note that for this hook to work, we need to enable EVENTS_TILE_IMPROVEMENTS in CustomModOptions.

-- this one is called when we remove a farm anywhere, to revert back to the original continent
function UndoChangeContinent (iPlotX, iPlotY, iOwner, iImprovementOld, iImprovementNew, bPillaged)
	pPlot = Map.GetPlot(iPlotX, iPlotY)
	if iImprovementOld == iImprovementFarm and iImprovementNew ~= iImprovementFarm and pPlot:GetResourceType() ~= iResourceWheat then
		local iContinentOriginal = g_tonumber(load(pPlot, "OriginalContinent"))
		if iContinentOriginal ~= nil and iContinentOriginal >= 0 and iContinentOriginal <= 4 then
			pPlot:SetContinentArtType(iContinentOriginal)
			save(pPlot, "OriginalContinent", nil)
		end
	end
end
GameEvents.TileImprovementChanged.Add(UndoChangeContinent) -- note that for this hook to work, we need to enable EVENTS_TILE_IMPROVEMENTS in CustomModOptions.

-- opens the save data, this is important for when loading a game while already in a game
Events.LoadScreenClose.Add(OpenSaveData)