unit KM_DevPerfLogTypes;
{$I KaM_Remake.inc}
interface

type
  TPerfSectionDev = (
    psNone,
    psGameTick,
      psHands,
        psUnits,
        psDelivery,
        psWalkConnect,
      psGameFOW,
      psPathfinding,
      psHungarian,
      psAIFields,
      psAI,
        psAICityAdv,
        psAIArmyAdv,
        psAICityCls,
        psAIArmyCls,
      psTerrain,
      psTerrainFinder,
      psScripting,
      psUpdateVBO,
    psFrameFullC,                 // Full render frame as seen by gMain
    psFrameFullG,                 // Full render frame on GPU (doublecheck TKMPerfLogGFXStack)
      psFrameGame,                // Frame of the Gameplay without GUI
        psFrameTerrain,
          psFrameTerrainBase,
            psFrameTiles,
            psFrameWater,
            psFrameTilesLayers,
            psFrameOverlays,
            psFrameLighting,
            psFrameShadows,
        psFrameHands,
        psFrameRenderList,
        psFrameFOW,
      psFrameGui                  // Frame of the Gameplay GUI
  );
  TPerfSectionSet = set of TPerfSectionDev;

  function GetSectionName(aSection: TPerfSectionDev): string;

const
  LOW_PERF_SECTION = TPerfSectionDev(1);

implementation
uses
  TypInfo;


function GetSectionName(aSection: TPerfSectionDev): string;
begin
  Result := GetEnumName(TypeInfo(TPerfSectionDev), Integer(aSection));
  Result := Copy(Result, 3, Length(Result) - 2);
end;


end.
