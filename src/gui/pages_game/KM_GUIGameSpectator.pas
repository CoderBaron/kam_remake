unit KM_GUIGameSpectator;
{$I KaM_Remake.inc}
interface
{
������
�������
������
�������
������ �������
��������
������
������������
���������
�����
������./���.
}
uses
  {$IFDEF MSWindows} Windows, {$ENDIF}
  {$IFDEF Unix} LCLIntf, LCLType, {$ENDIF}
  Classes, Math, StrUtils, SysUtils,
  KM_Controls, KM_HandsCollection, KM_Defaults, KromOGLUtils, KM_Hand, KM_Units,
  KM_ResWares, KM_ResHouses, KM_Pics, KM_CommonTypes, KM_Points, KM_Houses;

const
  GUI_SPECTATOR_ITEM_WIDTH = 28;
  GUI_SPECTATOR_ITEM_HEIGHT = 34;
  GUI_SPECTATOR_ITEM_SPLITE_H = 4;
  GUI_SPECTATOR_ITEM_SPLITE_V = 4;
  GUI_SPECTATOR_ITEM_TEAM = 16;

  GUI_SPECTATOR_HEADER_HEIGHT = 14;

  GUI_SPECTATOR_HEADER_FLAG = 1164;
  GUI_SPECTATOR_HEADER_FLAG_FRAME = 5;


type
//  TKMGUIGameSpectatorPageTypes = (
//    gsptNothing = 0,
//    gsptResources = 1,
//    gsptBuildings = 2,
//    gsptProduction = 3,
//    gsptArmy = 4,
//    gsptPopulation = 5,
//    gsptLosses = 6
//  );

  TKMGUIGameSpectatorItem = class(TKMControl)
  private
    FHandIndex: Integer;
    FImageID: Word;
    FValue: String;
    FAdditionalValue: String;
    FProgress: Single;
    FTag: Integer;
  public
    constructor Create(aParent: TKMPanel; ATag: Integer; AImageID: Word; AHint: String; AHandIndex: Integer);
    property Tag: Integer read FTag;
    property Value: String read FValue write FValue;
    property AdditionalValue: String read FAdditionalValue write FAdditionalValue;
    property Progress: Single read FProgress write FProgress;
    procedure Paint; override;
  end;

  TKMGUIGameSpectatorItemLine = class;
  TKMGUIGameSpectatorItemLineClass = class of TKMGUIGameSpectatorItemLine;

  TKMGUIGameSpectatorItemLine = class(TKMPanel)
  protected
    FOnJumpToPlayer: TIntegerEvent;
    FHandIndex: Integer;
    FAnimStep: Cardinal;
    FItems: array of TKMGUIGameSpectatorItem;
    procedure DoubleClicked(Sender: TObject);
  protected
    function CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem; virtual; abstract;
    function GetTagCount: Integer; virtual; abstract;
    function GetTag(AIndex: Integer): Integer; virtual; abstract;
    function GetValue(AHandIndex: Integer; ATag: Integer): String; virtual; abstract;
    function GetAdditionalValue(AHandIndex: Integer; ATag: Integer): String; virtual;
    function GetProgress(AHandIndex: Integer; ATag: Integer): Single; virtual;
  public
    constructor Create(aParent: TKMPanel; AHandIndex: Integer; aOnJumpToPlayer: TIntegerEvent);
    procedure UpdateState(aTickCount: Cardinal); override;
    procedure Paint; override;
    property HandIndex: Integer read FHandIndex;
  end;

  ///

  TKMGUIGameSpectatorItemLineResources = class(TKMGUIGameSpectatorItemLine)
  protected
    function CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem; override;
    function GetTagCount: Integer; override;
    function GetTag(AIndex: Integer): Integer; override;
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  // Buildings

  TKMGUIGameSpectatorItemLineCustomBuildings = class(TKMGUIGameSpectatorItemLine)
  protected
    function CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem; override;
    function GetTagCount: Integer; override;
    function GetTag(AIndex: Integer): Integer; override;
  end;

  TKMGUIGameSpectatorItemLineBuild = class(TKMGUIGameSpectatorItemLineCustomBuildings)
  protected
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
    function GetProgress(AHandIndex: Integer; ATag: Integer): Single; override;
  end;

  TKMGUIGameSpectatorItemLineBuildings = class(TKMGUIGameSpectatorItemLineCustomBuildings)
  protected
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
    function GetAdditionalValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  // Units

  TKMGUIGameSpectatorItemLinePopulation = class(TKMGUIGameSpectatorItemLine)
  protected
    function CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem; override;
    function GetTagCount: Integer; override;
    function GetTag(AIndex: Integer): Integer; override;
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  TKMGUIGameSpectatorItemLineArmy = class(TKMGUIGameSpectatorItemLine)
  protected
    function CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem; override;
    function GetTagCount: Integer; override;
    function GetTag(AIndex: Integer): Integer; override;
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  TKMGUIGameSpectatorItemLineArmyTotal = class(TKMGUIGameSpectatorItemLineArmy)
  protected
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  TKMGUIGameSpectatorItemLineArmyKilling = class(TKMGUIGameSpectatorItemLineArmy)
  protected
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  TKMGUIGameSpectatorItemLineArmyLost = class(TKMGUIGameSpectatorItemLineArmy)
  protected
    function GetValue(AHandIndex: Integer; ATag: Integer): String; override;
  end;

  ///

  TKMGUIGameSpectator = class
  private
    FDropBoxPanel: TKMPanel;
    FDropBox: TKMDropList;
    FLastIndex: Integer;

    FOnJumpToPlayer: TIntegerEvent;

    FLines: array of array[0..MAX_LOBBY_PLAYERS] of TKMGUIGameSpectatorItemLine;

    procedure AddLineType(AIndex: Integer; ALineClass: TKMGUIGameSpectatorItemLineClass);
    procedure ChangePage(Sender: TObject);
  public
    constructor Create(aParent: TKMPanel; aOnJumpToPlayer: TIntegerEvent);
  end;

implementation

uses
  KM_RenderUI, KM_ResFonts, KM_Resource, KM_ResTexts;

{ TKMGUIGameSpectatorItem }
constructor TKMGUIGameSpectatorItem.Create(aParent: TKMPanel; ATag: Integer; AImageID: Word; AHint: String; AHandIndex: Integer);
begin
  inherited Create(aParent, 0, 0, GUI_SPECTATOR_ITEM_WIDTH, GUI_SPECTATOR_ITEM_HEIGHT);
  FTag := ATag;
  Hint := AHint;
  FHandIndex := AHandIndex;
  FImageID := AImageID;
  FValue := '';
  FAdditionalValue := '';
  FProgress := -1;
end;

procedure TKMGUIGameSpectatorItem.Paint;
begin
  inherited;

  TKMRenderUI.WriteBevel(AbsLeft, AbsTop, Width, Height);
  TKMRenderUI.WritePicture(AbsLeft + 2, AbsTop, Width - 4, Height - 4, [], rxGui, FImageID, True, gHands[FHandIndex].FlagColor);

  if FProgress >= 0 then
    TKMRenderUI.WritePercentBar(AbsLeft, AbsTop + Height - 6, Width, 6, FProgress, 0);

  TKMRenderUI.WriteText(AbsLeft, AbsTop + Height - 16, Width, FValue, fnt_Grey, taCenter, $FFFFFFFF);
  if FAdditionalValue <> '' then
    TKMRenderUI.WriteText(AbsLeft - 2, AbsTop - 2, Width, FAdditionalValue, fnt_Grey, taRight, $FFFFFFFF);
end;

{ TKMGUIGameSpectatorItemLine }
constructor TKMGUIGameSpectatorItemLine.Create(aParent: TKMPanel; AHandIndex: Integer; aOnJumpToPlayer: TIntegerEvent);
var
  i: Integer;
begin
  inherited Create(aParent, aParent.Width, 32 + AHandIndex * (GUI_SPECTATOR_ITEM_HEIGHT + GUI_SPECTATOR_ITEM_SPLITE_V), 0, GUI_SPECTATOR_ITEM_HEIGHT + GUI_SPECTATOR_HEADER_HEIGHT + GUI_SPECTATOR_ITEM_SPLITE_V);
  fOnJumpToPlayer := aOnJumpToPlayer;
  OnDoubleClick := DoubleClicked;
  Anchors := [anTop, anRight];
  FAnimStep := 0;
  Focusable := false;
  FHandIndex := AHandIndex;
  SetLength(fItems, GetTagCount);
  for i := 0 to GetTagCount - 1 do
  begin
    fItems[i] := CreateItem(AHandIndex, GetTag(i));
    fItems[i].OnDoubleClick := DoubleClicked;
  end;
end;

procedure TKMGUIGameSpectatorItemLine.DoubleClicked(Sender: TObject);
begin
  if Assigned(fOnJumpToPlayer) then
    fOnJumpToPlayer(FHandIndex);
end;

procedure TKMGUIGameSpectatorItemLine.UpdateState(aTickCount: Cardinal);
var
  i, Position, Count: Integer;
  Str: UnicodeString;
begin
  inherited;
  if not Visible then
    Exit;

  Inc(FAnimStep);

  Count := 0;
  for i := 0 to GetTagCount - 1 do
  begin
    fItems[i].Value := GetValue(FHandIndex, GetTag(i));
    fItems[i].AdditionalValue := GetAdditionalValue(FHandIndex, GetTag(i));
    fItems[i].Progress := GetProgress(FHandIndex, GetTag(i));
    fItems[i].Visible := (fItems[i].Value <> '') or (fItems[i].AdditionalValue <> '') or (fItems[i].Progress >= 0);
    if fItems[i].Visible then
      Inc(Count);
  end;

  Str := IfThen(gHands[FHandIndex].OwnerNikname <> '', gHands[FHandIndex].OwnerNikname, gHands[FHandIndex].OwnerName);
  Width := Max(Count * (GUI_SPECTATOR_ITEM_WIDTH + GUI_SPECTATOR_ITEM_SPLITE_H) + GUI_SPECTATOR_ITEM_SPLITE_H, gRes.Fonts[fnt_Grey].GetTextSize(Str).X + 32 + 4);
  Left := Parent.Width - Width;

  Position := Width - GUI_SPECTATOR_ITEM_SPLITE_H - GUI_SPECTATOR_ITEM_WIDTH;
  for i := 0 to GetTagCount - 1 do
    if fItems[i].Visible then
    begin
      fItems[i].Top := GUI_SPECTATOR_HEADER_HEIGHT;
      fItems[i].Left := Position;
      Dec(Position, GUI_SPECTATOR_ITEM_WIDTH + GUI_SPECTATOR_ITEM_SPLITE_H);
    end;
end;

function TKMGUIGameSpectatorItemLine.GetAdditionalValue(AHandIndex: Integer; ATag: Integer): String;
begin
  Result := '';
end;

function TKMGUIGameSpectatorItemLine.GetProgress(AHandIndex: Integer; ATag: Integer): Single;
begin
  Result := -1;
end;

procedure TKMGUIGameSpectatorItemLine.Paint;
var
  Str: UnicodeString;
  ID: Integer;
begin
  TKMRenderUI.WriteBevel(AbsLeft, AbsTop, Width, Height);
  inherited;
  Str := IfThen(gHands[FHandIndex].OwnerNikname <> '', gHands[FHandIndex].OwnerNikname, gHands[FHandIndex].OwnerName);
  TKMRenderUI.WriteText(AbsLeft, AbsTop, Width - 32, Str, fnt_Grey, taRight, $FFFFFFFF);

  ID := GUI_SPECTATOR_HEADER_FLAG + FAnimStep mod GUI_SPECTATOR_HEADER_FLAG_FRAME;
  TKMRenderUI.WritePicture(AbsLeft + Width - 32, AbsTop, 32, GUI_SPECTATOR_HEADER_HEIGHT, [], rxHouses, ID, True, gHands[FHandIndex].FlagColor);
end;

{ TKMGUIGameSpectatorItemLineResources }
function TKMGUIGameSpectatorItemLineResources.CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem;
begin
  Result := TKMGUIGameSpectatorItem.Create(Self, ATag, gRes.Wares[TKMWareType(ATag)].GUIIcon, gRes.Wares[TKmWareType(ATag)].Title, FHandIndex);
  Result.Visible := False;
end;

function TKMGUIGameSpectatorItemLineResources.GetTagCount: Integer;
begin
  Result := Integer(WARE_MAX) - Integer(WARE_MIN) + 1;
end;

function TKMGUIGameSpectatorItemLineResources.GetTag(AIndex: Integer): Integer;
begin
  Result := Integer(WARE_MIN) + AIndex;
end;

function TKMGUIGameSpectatorItemLineResources.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetWareBalance(TKMWareType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;

{ TKMGUIGameSpectatorItemLineCustomBuildings }
function TKMGUIGameSpectatorItemLineCustomBuildings.CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem;
begin
  Result := TKMGUIGameSpectatorItem.Create(Self, ATag, gRes.Houses[TKMHouseType(ATag)].GUIIcon, gRes.Houses[TKMHouseType(ATag)].HouseName, FHandIndex);
  Result.Visible := False;
end;

function TKMGUIGameSpectatorItemLineCustomBuildings.GetTagCount: Integer;
begin
  Result := Integer(HOUSE_MAX) - Integer(HOUSE_MIN) + 1;
end;

function TKMGUIGameSpectatorItemLineCustomBuildings.GetTag(AIndex: Integer): Integer;
begin
  Result := Integer(HOUSE_MIN) + AIndex;
end;

{ TKMGUIGameSpectatorItemLineBuild }
function TKMGUIGameSpectatorItemLineBuild.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetHouseWip(TKMHouseType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;

function TKMGUIGameSpectatorItemLineBuild.GetProgress(AHandIndex: Integer; ATag: Integer): Single;
var
  i: Integer;
  House, HouseProgress: TKMHouse;
  HouseType: TKMHouseType;
begin
  Result := inherited;
  if GetValue(AHandIndex, ATag) = '' then
    Exit;

  HouseType := TKMHouseType(ATag);
  HouseProgress := nil;
  for i := 0 to gHands[AHandIndex].Houses.Count - 1 do
  begin
    House := gHands[AHandIndex].Houses[i];
    if (House.HouseType = HouseType) and (House.BuildingState in [hbs_Wood, hbs_Stone]) and (not Assigned(HouseProgress) or (House.BuildingProgress > HouseProgress.BuildingProgress)) then
      HouseProgress := House;
  end;

  if Assigned(HouseProgress) then
    Result := HouseProgress.BuildingProgress / HouseProgress.MaxHealth;
end;

{ TKMGUIGameSpectatorItemLineBuildings }
function TKMGUIGameSpectatorItemLineBuildings.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetHouseQty(TKMHouseType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;

function TKMGUIGameSpectatorItemLineBuildings.GetAdditionalValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetHouseWip(TKMHouseType(ATag));
  Result := IfThen(Value > 0, '+' + IntToStr(Value), '');
end;

{ TKMGUIGameSpectatorItemLinePopulation }
function TKMGUIGameSpectatorItemLinePopulation.CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem;
begin
  Result := TKMGUIGameSpectatorItem.Create(Self, ATag, gRes.Units[TKMUnitType(ATag)].GUIIcon, gRes.Units[TKMUnitType(ATag)].GUIName, FHandIndex);
end;

function TKMGUIGameSpectatorItemLinePopulation.GetTagCount: Integer;
begin
  Result := Integer(CITIZEN_MAX) - Integer(CITIZEN_MIN) + 1;
end;

function TKMGUIGameSpectatorItemLinePopulation.GetTag(AIndex: Integer): Integer;
begin
  Result := Integer(CITIZEN_MIN) + AIndex;
end;

function TKMGUIGameSpectatorItemLinePopulation.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetUnitQty(TKMUnitType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;

{ TKMGUIGameSpectatorItemLineArmy }
function TKMGUIGameSpectatorItemLineArmy.CreateItem(AHandIndex: Integer; ATag: Integer): TKMGUIGameSpectatorItem;
begin
  Result := TKMGUIGameSpectatorItem.Create(Self, ATag, gRes.Units[TKMUnitType(ATag)].GUIIcon, gRes.Units[TKMUnitType(ATag)].GUIName, FHandIndex);
end;

function TKMGUIGameSpectatorItemLineArmy.GetTagCount: Integer;
begin
  Result := Integer(WARRIOR_MAX) - Integer(WARRIOR_MIN) + 1;
end;

function TKMGUIGameSpectatorItemLineArmy.GetTag(AIndex: Integer): Integer;
begin
  Result := Integer(WARRIOR_MIN) + AIndex;
end;

function TKMGUIGameSpectatorItemLineArmy.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetUnitQty(TKMUnitType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;


{ TKMGUIGameSpectatorItemLineArmyTotal }
function TKMGUIGameSpectatorItemLineArmyTotal.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetWarriorsTotal(TKMUnitType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;


{ TKMGUIGameSpectatorItemLineArmyKilling }
function TKMGUIGameSpectatorItemLineArmyKilling.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetUnitKilledQty(TKMUnitType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;

{ TKMGUIGameSpectatorItemLineArmyLost }
function TKMGUIGameSpectatorItemLineArmyLost.GetValue(AHandIndex: Integer; ATag: Integer): String;
var
  Value: Integer;
begin
  Value := gHands[AHandIndex].Stats.GetUnitLostQty(TKMUnitType(ATag));
  Result := IfThen(Value > 0, IntToStr(Value), '');
end;

{ TKMGUIGameSpectator }
constructor TKMGUIGameSpectator.Create(aParent: TKMPanel; aOnJumpToPlayer: TIntegerEvent);
const
  DROPBOX_W = 270;
begin
  inherited Create;

  fOnJumpToPlayer := aOnJumpToPlayer;

  FDropBoxPanel := TKMPanel.Create(aParent, aParent.Width - DROPBOX_W - 10, 0, DROPBOX_W + 10, 30);
  FDropBoxPanel.Anchors := [anTop, anRight];
  //FDropBoxPanel.Focusable := false;
  FDropBoxPanel.Show;

  FLastIndex := 0;

  SetLength(FLines, 9);

  AddLineType(0, nil);
  AddLineType(1, TKMGUIGameSpectatorItemLineResources);
  AddLineType(2, TKMGUIGameSpectatorItemLineBuildings);
  AddLineType(3, TKMGUIGameSpectatorItemLineBuild);
  AddLineType(4, TKMGUIGameSpectatorItemLinePopulation);
  AddLineType(5, TKMGUIGameSpectatorItemLineArmy);
  AddLineType(6, TKMGUIGameSpectatorItemLineArmyTotal);
  AddLineType(7, TKMGUIGameSpectatorItemLineArmyKilling);
  AddLineType(8, TKMGUIGameSpectatorItemLineArmyLost);

  FDropBox := TKMDropList.Create(FDropBoxPanel, 5, 5, DROPBOX_W, 20, fnt_Metal, '', bsGame);
  FDropBox.OnChange := ChangePage;

  FDropBox.Add(gResTexts[TX_WORD_NONE]);
  FDropBox.Add(gResTexts[TX_WORD_RESOURCES]);
  FDropBox.Add(gResTexts[TX_WORD_HOUSES]);
  FDropBox.Add(gResTexts[TX_WORD_CONSTRUCTING]);
  FDropBox.Add(gResTexts[TX_WORD_CITIZENS]);
  FDropBox.Add(gResTexts[TX_WORD_ARMY] + ' - ' + gResTexts[TX_RESULTS_ARMY_INSTANTANEOUS]);
  FDropBox.Add(gResTexts[TX_WORD_ARMY] + ' - ' + gResTexts[TX_RESULTS_ARMY_TOTAL_EQUIPPED]);
  FDropBox.Add(gResTexts[TX_WORD_ARMY] + ' - ' + gResTexts[TX_RESULTS_ARMY_DEFEATED]);
  FDropBox.Add(gResTexts[TX_WORD_ARMY] + ' - ' + gResTexts[TX_RESULTS_ARMY_LOST]);

  FDropBox.ItemIndex := 0;
end;

procedure TKMGUIGameSpectator.AddLineType(AIndex: Integer; ALineClass: TKMGUIGameSpectatorItemLineClass);
var
  i: Integer;
begin
  if ALineClass <> nil then
    for i := 0 to MAX_LOBBY_PLAYERS - 1 do
    begin
      FLines[AIndex, i] := ALineClass.Create(FDropBoxPanel.Parent, i, fOnJumpToPlayer);
      FLines[AIndex, i].Visible := False;
    end;
end;

procedure TKMGUIGameSpectator.ChangePage(Sender: TObject);
var
  I, J: Integer;
  Teams: TKMByteSetArray;
  Position: Integer;
  NonTeamHands: set of Byte;
begin
  for I := 0 to MAX_LOBBY_PLAYERS - 1 do
    if Assigned(FLines[FLastIndex, I]) then
      FLines[FLastIndex, I].Visible := False;

  FLastIndex := FDropBox.ItemIndex;

  Position := 32;
  Teams := gHands.GetFullTeams;

  for I := Low(Teams) to High(Teams) do
  begin
    for J in Teams[I] do
    begin
      if Assigned(FLines[FLastIndex, J]) then
      begin
        FLines[FLastIndex, J].Top := Position;
        FLines[FLastIndex, J].Visible := True;
      end;
      Position := Position + GUI_SPECTATOR_ITEM_HEIGHT + GUI_SPECTATOR_ITEM_SPLITE_V * 2 + GUI_SPECTATOR_HEADER_HEIGHT;
    end;
    Position := Position + GUI_SPECTATOR_ITEM_TEAM;
  end;
end;

end.
