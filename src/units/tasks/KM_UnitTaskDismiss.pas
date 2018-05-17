unit KM_UnitTaskDismiss;
{$I KaM_Remake.inc}
interface
uses
  Classes, SysUtils,
  KM_Defaults, KM_Units, KM_Houses, KM_Points, KM_CommonClasses;


type
  TKMTaskDismiss = class(TKMUnitTask)
  private
    fSchool: TKMHouse;
  protected
    procedure InitDefaultAction; override;
  public
    constructor Create(aUnit: TKMUnit);
    constructor Load(LoadStream: TKMemoryStream); override;
    destructor Destroy; override;
    procedure SyncLoad; override;
    procedure Save(SaveStream: TKMemoryStream); override;
    function ShouldBeCancelled: Boolean;
    function CouldBeCancelled: Boolean; override;

    property School: TKMHouse read fSchool;
    function FindNewSchool: TKMHouse;

    function Execute: TKMTaskResult; override;
  end;


implementation
uses
  KM_ResHouses, KM_HandsCollection, KM_UnitActionAbandonWalk, KM_Hand;


{ TTaskDismiss }
constructor TKMTaskDismiss.Create(aUnit: TKMUnit);
begin
  inherited;

  fTaskName := utn_Dismiss;
  FindNewSchool;
end;


constructor TKMTaskDismiss.Load(LoadStream: TKMemoryStream);
begin
  inherited;
  LoadStream.Read(fSchool, 4);
end;


destructor TKMTaskDismiss.Destroy;
begin
  gHands.CleanUpHousePointer(fSchool);

  inherited;
end;


function TKMTaskDismiss.ShouldBeCancelled: Boolean;
begin
  Result := (fSchool = nil) or fSchool.IsDestroyed;
end;


function TKMTaskDismiss.CouldBeCancelled: Boolean;
begin
  Result := fPhase <= 1; //Allow cancel dismiss only while walking to the school point below entrance
end;


procedure TKMTaskDismiss.Save(SaveStream: TKMemoryStream);
begin
  inherited;
  if fSchool <> nil then
    SaveStream.Write(fSchool.UID) //Store ID, then substitute it with reference on SyncLoad
  else
    SaveStream.Write(Integer(0));
end;


procedure TKMTaskDismiss.SyncLoad;
begin
  inherited;
  fSchool := gHands[fUnit.Owner].Houses.GetHouseByUID(Cardinal(fSchool));
end;


function TKMTaskDismiss.FindNewSchool: TKMHouse;
var
  S: TKMHouse;
begin
  fSchool := nil;

  S := gHands[fUnit.Owner].FindHouse(htSchool, fUnit.GetPosition);

  if (S <> nil) and fUnit.CanWalkTo(fUnit.GetPosition, S.PointBelowEntrance, tpWalk, 0) then
    fSchool := S.GetHousePointer;

  Result := fSchool;
end;


procedure TKMTaskDismiss.InitDefaultAction;
begin
  //Do nothing here, as we have to continue old action, until it could be interrupted
end;


function TKMTaskDismiss.Execute: TKMTaskResult;
begin
  Result := tr_TaskContinues;

  if (fSchool = nil) or fSchool.IsDestroyed then
  begin
    Result := tr_TaskDone;
    Exit;
  end;

  with fUnit do
    case fPhase of
      0:  SetActionWalkToSpot(fSchool.PointBelowEntrance);
      1:  SetActionGoIn(ua_Walk, gd_GoInside, fSchool);
      2:  fUnit.Kill(PLAYER_NONE, False, False); //Silently kill unit
      else Result := tr_TaskDone;
    end;

  Inc(fPhase);
end;


end.

