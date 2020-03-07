--===========================================================================================================
-- Scripts for Rice and Maize Farms:
-- ---------------------------------
-- What these scripts do is workaround the fact we can't add Crop textures in any way (we can add them but there's no way of referencing the new ones)
-- In order to do this, we are changing all plots that are of America and Asia continents. Except for those with our required resources.
-- The plots with our required resources are assigned the correct continent (America for Maize, Asia for Rice)
--
-- The script also puts a temporary dummy improvement once the farm has been created, and then it reverts back to a farm.
-- This is because otherwise the resource model is still visible (feel free to put a false on HideResourceModel)
--============================================================================================================
--============================================================================================================
-- To use simply change these resource definitions
-------------------------------
print("Rice and Maize scripts executing")

iRiceResource = GameInfoTypes["RESOURCE_RICE"]
iRiceContinent = 2 -- Asia

iMaizeResource = GameInfoTypes["RESOURCE_MAIZE"]
iMaizeContinent = 1 -- America

iWheatResource = GameInfoTypes["RESOURCE_WHEAT"]

iFarm = GameInfoTypes["IMPROVEMENT_FARM"]

-- this one is called when we finish a farm
function DoChangeContinent (playerID, plotX, plotY, improvementID) 
	if improvementID == iFarm then
		plot = Map.GetPlot(plotX, plotY)
		iCurrentContinent = plot:GetContinentArtType()
		if plot:GetResourceType() == iRiceResource then
			plot:SetContinentArtType(iRiceContinent)
		elseif plot:GetResourceType() == iMaizeResource then
			plot:SetContinentArtType(iMaizeContinent)
		elseif (plot:GetResourceType() ~= iWheatResource) and (iCurrentContinent == iRiceContinent or iCurrentContinent == iMaizeContinent) then
			plot:SetContinentArtType(iCurrentContinent + 2)
		end
	end
end

GameEvents.BuildFinished.Add(DoChangeContinent)

-- this one is called when we remove a farm anywhere, to revert back to the original continent
--[[function UndoChangeContinent (iPlotX, iPlotY, iOwner, iOldImprovement, iNewImprovement, bPillaged)
	if iOldImprovement == iFarm and iNewImprovement ~= iFarm then
		plot = Map.GetPlot(plotX, plotY)
		if plot:GetResourceType() ~= iRiceResource and plot:GetResourceType() ~= iMaizeResource and plot:GetResourceType() ~= iWheatResource then
			plot:SetContinentArtType(plot:GetContinentArtType() - 2)
		end
	end
end

GameEvents.TileImprovementChanged.Add(UndoChangeContinent)]] -- note that for this hook to work, we need to enable EVENTS_TILE_IMPROVEMENTS in CustomModOptions.