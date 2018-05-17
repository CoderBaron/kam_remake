unit KM_AIArmyEvaluation;
{$I KaM_Remake.inc}
interface
uses
  KM_Defaults, KM_CommonClasses;

type
  TKMGroupEval = record
    HitPoints, Attack, AttackHorse, Defence, DefenceProjectiles: Single;
  end;

  TKMArmyEval = array[TKMGroupType] of TKMGroupEval;
  TKMGameEval = array[0 .. MAX_HANDS - 1] of TKMArmyEval;


  //This class evaluate self army relatively enemy armies
  TKMArmyEvaluation = class
  private
    fEvals: TKMGameEval; //Results of evaluation

    procedure EvaluatePower(aPlayer: TKMHandIndex; aConsiderHitChance: Boolean = False);
    function GetUnitEvaluation(aUT: TKMUnitType; aConsiderHitChance: Boolean = False): TKMGroupEval;
    function GetEvaluation(aPlayer: TKMHandIndex): TKMArmyEval;
    function GetAllianceStrength(aPlayer: TKMHandIndex; aAlliance: TKMAllianceType): TKMArmyEval;
  public
    constructor Create();
    destructor Destroy; override;
    procedure Save(SaveStream: TKMemoryStream);
    procedure Load(LoadStream: TKMemoryStream);

    property UnitEvaluation[aUT: TKMUnitType; aConsiderHitChance: Boolean]: TKMGroupEval read GetUnitEvaluation;
    property Evaluation[aPlayer: TKMHandIndex]: TKMArmyEval read GetEvaluation;
    property AllianceEvaluation[aPlayer: TKMHandIndex; aAlliance: TKMAllianceType]: TKMArmyEval read GetAllianceStrength;

    //function AttackForceChance(aOponent: TKMHandIndex; aGroups: TKMUnitGroupArray): Single;
    function CompareAllianceStrength(aPlayer, aOponent: TKMHandIndex): Single;
    procedure UpdateState(aTick: Cardinal);
  end;

const
  HIT_CHANCE_MODIFIER = 0.5;

implementation
uses
  Math,
  KM_Hand, KM_HandsCollection, KM_HandStats,
  KM_Resource, KM_ResUnits;


{ TKMArmyEvaluation }
constructor TKMArmyEvaluation.Create();
begin
  inherited Create;
end;


destructor TKMArmyEvaluation.Destroy;
begin

  inherited;
end;


procedure TKMArmyEvaluation.Save(SaveStream: TKMemoryStream);
begin
  SaveStream.WriteA('ArmyEvaluation');
  SaveStream.Write(fEvals, SizeOf(TKMGameEval));
end;


procedure TKMArmyEvaluation.Load(LoadStream: TKMemoryStream);
begin
  LoadStream.ReadAssert('ArmyEvaluation');
  LoadStream.Read(fEvals, SizeOf(TKMGameEval));
end;


function TKMArmyEvaluation.GetUnitEvaluation(aUT: TKMUnitType; aConsiderHitChance: Boolean = False): TKMGroupEval;
var
  US: TKMUnitSpec;
begin
  // Fill array with reference values
  US := gRes.Units[aUT];
  with Result do
  begin
    Hitpoints :=          US.Hitpoints;
    Attack :=             US.Attack;
    AttackHorse :=        US.AttackHorse;
    Defence :=            US.Defence;
    DefenceProjectiles := US.GetDefenceVsProjectiles(False);
    if aConsiderHitChance AND (UnitGroups[aUT] = gt_Ranged) then
      Attack := Attack * HIT_CHANCE_MODIFIER;
  end;
end;


function TKMArmyEvaluation.GetEvaluation(aPlayer: TKMHandIndex): TKMArmyEval;
begin
  Result := fEvals[aPlayer];
end;


function TKMArmyEvaluation.GetAllianceStrength(aPlayer: TKMHandIndex; aAlliance: TKMAllianceType): TKMArmyEval;
var
  PL: Integer;
  GT: TKMGroupType;
begin
  for GT := Low(TKMGroupType) to High(TKMGroupType) do
    with Result[GT] do
    begin
      Hitpoints := 0;
      Attack := 0;
      AttackHorse := 0;
      Defence := 0;
      DefenceProjectiles := 0;
    end;
  for PL := 0 to gHands.Count - 1 do
    if gHands[PL].Enabled AND (gHands[aPlayer].Alliances[PL] = aAlliance) then
      for GT := Low(TKMGroupType) to High(TKMGroupType) do
        with Result[GT] do
        begin
          Hitpoints := Hitpoints                   + fEvals[PL,GT].Hitpoints;
          Attack := Attack                         + fEvals[PL,GT].Attack;
          AttackHorse := AttackHorse               + fEvals[PL,GT].AttackHorse;
          Defence := Defence                       + fEvals[PL,GT].Defence;
          DefenceProjectiles := DefenceProjectiles + fEvals[PL,GT].DefenceProjectiles;
        end;
end;


//function TKMArmyEvaluation.AttackForceChance(aOponent: TKMHandIndex; aGroups: TKMUnitGroupArray): Single;
//var
//
//begin
//  EnemyEval := Evaluation[aOponent];
//end;


// Approximate way how to compute strength of 2 alliances
function TKMArmyEvaluation.CompareAllianceStrength(aPlayer, aOponent: TKMHandIndex): Single;
type
  TKMGroupStrengthArray = array[TKMGroupType] of Single;
  function CalculateStrength(aEval: TKMArmyEval): TKMGroupStrengthArray;
  const
    DEF_COEFICIENT = 100; // Increase weight of defence
  var
    GT: TKMGroupType;
  begin
    for GT := Low(TKMGroupType) to High(TKMGroupType) do
      with aEval[GT] do
      begin
        Result[GT] := Attack * Hitpoints * Defence;
        //if (GT = gt_AntiHorse) then
        //  Resutl[GT] := Result[GT] * AttackHorse;
      end;
  end;
var
  Sum, Diff: Single;
  GT: TKMGroupType;
  AllyEval, EnemyEval: TKMArmyEval;
  AllyArmy, EnemyArmy: TKMGroupStrengthArray;
begin
  AllyEval := GetAllianceStrength(aPlayer, at_Ally);
  EnemyEval := GetAllianceStrength(aOponent, at_Ally);
  AllyArmy := CalculateStrength(AllyEval);
  EnemyArmy := CalculateStrength(EnemyEval);
  Sum := 0;
  Diff := 0;
  for GT := Low(TKMGroupType) to High(TKMGroupType) do
  begin
    Sum := Sum + AllyArmy[GT] + EnemyArmy[GT];
    Diff := Diff + AllyArmy[GT] - EnemyArmy[GT];
  end;
  Result := Diff / Max(1,Sum); // => number in <-1,1> ... positive = we have advantage and vice versa
end;


// Actualize power of specific player
//
// Equation of combat:
//
//   Close combat
//                    Attack (+ AttackHorse) (+ DirModifier)   -> DirModifier is not considered in ArmyEvaluation
//     Probability = ---------------------------------------
//                                 Defence
//
//   Ranged units
//     HitProbability = 1 - Distance;  Distance in <0,1>       -> Hit probability is considered as a decreasing of attack by HIT_CHANCE_MODIFIER
//                         Attack
//     Probability = --------------------
//                    DefenceProjectiles
//
// Probability > random number => decrease hitpoint; 0 hitpoints = unit is dead
procedure TKMArmyEvaluation.EvaluatePower(aPlayer: TKMHandIndex; aConsiderHitChance: Boolean = False);
var
  Stats: TKMHandStats;
  Qty: Integer;
  US: TKMUnitSpec;
  UT: TKMUnitType;
  GT: TKMGroupType;
begin
  Stats := gHands[aPlayer].Stats;

  // Clear array
  for GT := Low(TKMGroupType) to High(TKMGroupType)  do
    with fEvals[aPlayer,GT] do
    begin
      Hitpoints := 0;
      Attack := 0;
      AttackHorse := 0;
      Defence := 0;
      DefenceProjectiles := 0;
    end;
  // Fill array with reference values
  for UT := WARRIOR_MIN to WARRIOR_MAX do
  begin
    Qty := Stats.GetUnitQty(UT);
    US := gRes.Units[UT];
    GT := UnitGroups[UT];
    with fEvals[aPlayer,GT] do
    begin
      Hitpoints := Hitpoints + Qty * US.HitPoints;
      Attack := Attack + Qty * US.Attack;
      AttackHorse := AttackHorse + Qty * US.AttackHorse;
      Defence := Defence + Qty * US.Defence;
      DefenceProjectiles := DefenceProjectiles + Qty * US.GetDefenceVsProjectiles(False); // True = IsBolt -> calculation without bolts
    end;
  end;
  if aConsiderHitChance then
    with fEvals[aPlayer,gt_Ranged] do
      Attack := Attack * HIT_CHANCE_MODIFIER;
end;


procedure TKMArmyEvaluation.UpdateState(aTick: Cardinal);
var
  PL: TKMHandIndex;
begin
  PL := aTick mod gHands.Count;
  if gHands[PL].Enabled then
    EvaluatePower(PL, True);
end;


end.
