unit Main;
{$I ..\..\KaM_Remake.inc}
interface
uses
  Windows, Classes, ComCtrls, Controls, Dialogs, ExtDlgs, ExtCtrls, Forms,
  Graphics, Mask, Math, Spin, StdCtrls, SysUtils, KM_Points,
  KM_Defaults, KM_Campaigns, KM_Pics, KM_ResSpritesEdit, KromUtils, inifiles,
  Vcl.ToolWin, System.ImageList, Vcl.ImgList,
  System.Actions, Vcl.ActnList, Vcl.Menus, RenderPanel, Vcl.Imaging.jpeg;

type
  TTreeChapter = class(TTreeNode)
  public
    PictureMapIndex: Byte;
    Video: array[TMissionVideoTypes] of UnicodeString;
    constructor Create(AOwner: TTreeNodes); override;
  end;

  TTreeChapterItem = class(TTreeNode)
  public
    Rect: TRect;
  end;

  TTreeChapterMission = class(TTreeChapterItem)
  public
    Number: Integer;
    TextPos: TBriefingCorner;
    Video: array[TMissionVideoTypes] of UnicodeString;
    constructor Create(AOwner: TTreeNodes); override;
  end;

  TTreeChapterNode = class(TTreeChapterItem)
  public
    constructor Create(AOwner: TTreeNodes); override;
  end;

  TMainForm = class(TForm)
    StatusBar1: TStatusBar;
    ScrollBox1: TScrollBox;
    ActionList: TActionList;
    aOpen: TAction;
    aNew: TAction;
    aSave: TAction;
    ImageList: TImageList;
    aPictureMaps: TAction;
    pLeft: TPanel;
    tvList: TTreeView;
    pmMap: TPopupMenu;
    Addlevel1: TMenuItem;
    AddNode1: TMenuItem;
    aAddMission: TAction;
    aAddNode: TAction;
    pTop: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    aSettings: TAction;
    IconList: TImageList;
    MissionBox: TGroupBox;
    Panel1: TPanel;
    cbShowNodeNumbers: TCheckBox;
    cbShowBriefingPage: TCheckBox;
    BriefingPositionPanel: TPanel;
    cbMissionBriefingPos: TComboBox;
    VideoBeforePanel: TPanel;
    VideoAfterPanel: TPanel;
    edtMissionVideoAfter: TEdit;
    edtMissionVideoBefore: TEdit;
    Splitter: TSplitter;
    aAddChapter: TAction;
    AddChapter1: TMenuItem;
    ImgBackground: TImage;
    imgBlackFlag: TImage;
    ImgBriefing: TImage;
    imgNode: TImage;
    imgRedFlag: TImage;
    ToolBar2: TToolBar;
    ToolButton4: TToolButton;
    N1: TMenuItem;
    aDelete: TAction;
    New1: TMenuItem;
    pmList: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    N2: TMenuItem;
    Zoom111: TMenuItem;
    aResetZoom: TAction;
    ChapterBox: TGroupBox;
    Panel2: TPanel;
    cbChapterPictureMap: TComboBox;
    Panel3: TPanel;
    edtChapterVideoBefore: TEdit;
    Panel4: TPanel;
    edtChapterVideoAfter: TEdit;
    bPictureMap: TButton;
    dlgOpenCampaign: TFileOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure tvListChange(Sender: TObject; Node: TTreeNode);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure aNewExecute(Sender: TObject);
    procedure aOpenExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure aPictureMapsExecute(Sender: TObject);
    procedure aAddMissionExecute(Sender: TObject);
    procedure aAddNodeExecute(Sender: TObject);
    procedure aSettingsExecute(Sender: TObject);
    procedure tvListCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure aAddChapterExecute(Sender: TObject);
    procedure tvListDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tvListDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure pmMapPopup(Sender: TObject);
    procedure cbShowBriefingPageClick(Sender: TObject);
    procedure cbShowNodeNumbersClick(Sender: TObject);
    procedure cbMissionBriefingPosChange(Sender: TObject);
    procedure aDeleteExecute(Sender: TObject);
    procedure aResetZoomExecute(Sender: TObject);
    procedure cbChapterPictureMapChange(Sender: TObject);
    procedure edtChapterVideoBeforeChange(Sender: TObject);
    procedure edtChapterVideoAfterChange(Sender: TObject);
    procedure edtMissionVideoBeforeChange(Sender: TObject);
    procedure edtMissionVideoAfterChange(Sender: TObject);
  private
    FRender: TRenderPanel;
    fExePath: string;
    fCampaignsPath: string;
    fSprites: TKMSpritePackEdit;

    fUpdating: Boolean;
    FTreeItemCreate: TTreeNodeClass;
    fSelectedChapter: TTreeChapter;
    fSelectedMission: TTreeChapterMission;
    fSelectedNode: TTreeChapterNode;

    procedure LoadCmp(aDirName : String);

    function DlgQuestionShow(aCaption, aMsg: string): boolean;

    function GetCharset(aLang: string): TFontCharset;
    procedure LoadCampaignName(aFileName, aLocale: string);
    procedure SaveCampaignName(aFileName: string);
    procedure CreateDefaultLocaleLibxTemplate(aFileName: string);
    procedure CampaignToList;
    procedure ListToCampaign;
    procedure UpdatePictureMaps;
  public
    procedure FlagEnter(Sender: TObject);
    procedure NodeEnter(Sender: TObject);

    procedure FlagNodeLeave(Sender: TObject);

    procedure UpdateCaption;
    function CopyNode(ANode: TTreeChapterItem): TTreeChapterItem;
    procedure UpdateList;
    procedure UpdateBox;

    property Sprites: TKMSpritePackEdit read fSprites;
    property SelectedChapter: TTreeChapter read fSelectedChapter;
    property SelectedMission: TTreeChapterMission read fSelectedMission;
    property SelectedNode: TTreeChapterNode read fSelectedNode;
  end;

var
  MainForm: TMainForm;
  C: TKMCampaign;
  Locale: String;

implementation

{$R *.dfm}

uses
  uCampaignSettings, PictureMaps;

{ TTreeMap }

constructor TTreeChapter.Create(AOwner: TTreeNodes);
begin
  inherited;
  ImageIndex := 0;
  SelectedIndex := 0;
  PictureMapIndex := 0;
  Video[mvBefore] := '';
  Video[mvAfter] := '';
end;

{ TTreeItemMission }

constructor TTreeChapterMission.Create(AOwner: TTreeNodes);
begin
  inherited;
  ImageIndex := 1;
  SelectedIndex := 1;
  TextPos := bcBottomLeft;
  Rect := Classes.Rect(0, 0, 0, 0);
  Video[mvBefore] := '';
  Video[mvAfter] := '';
end;

{ TTreeItemNode }

constructor TTreeChapterNode.Create(AOwner: TTreeNodes);
begin
  inherited;
  Rect := Classes.Rect(0, 0, 0, 0);
  ImageIndex := 3;
  SelectedIndex := 3;
end;

{ TForm1 }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True; //Makes images drag around smoothly
  ScrollBox1.DoubleBuffered := True;

  fExePath := ExtractFilePath(ParamStr(0));
  fCampaignsPath := ExpandFileName(fExePath + '..\..\Campaigns\');

  Locale := 'eng';

  C := TKMCampaign.Create;

  fSelectedChapter := nil;
  fSelectedMission := nil;
  fSelectedNode := nil;

  imgNode.Canvas.Font.Name := 'Verdana';
  imgNode.Canvas.Font.Style := [fsBold];
  imgNode.Canvas.Font.Size := 5;
  imgNode.Canvas.Font.Color := clWhite;

  imgBlackFlag.Canvas.Font.Name := 'Verdana';
  imgBlackFlag.Canvas.Font.Style := [fsBold];
  imgBlackFlag.Canvas.Font.Size := 8;
  imgBlackFlag.Canvas.Font.Color := clWhite;

  imgRedFlag.Canvas.Font.Name := 'Verdana';
  imgRedFlag.Canvas.Font.Style := [fsBold];
  imgRedFlag.Canvas.Font.Size := 8;
  imgRedFlag.Canvas.Font.Color := clWhite;

  fSprites := TKMSpritePackEdit.Create(rxCustom, nil);

  if FileExists(ParamStr(1)) then
    LoadCmp(ParamStr(1));
  UpdateCaption;

  FRender := TRenderPanel.Create(Self, tvList);
  FRender.PopupMenu := pmMap;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fSprites.Free;
end;

procedure TMainForm.aAddChapterExecute(Sender: TObject);
var
  Node: TTreeNode;
begin
  FTreeItemCreate := TTreeChapter;
  Node := tvList.Items.AddChild(nil, Format('Chapter %d', [tvList.Items.Count + 1]));
  Node.Selected := True;
end;

procedure TMainForm.LoadCmp(aDirName : String);
var
  I: Integer;
begin
  C.LoadFromDir(aDirName);

  fSprites.Free;
  fSprites := TKMSpritePackEdit.Create(rxCustom, nil);
  if FileExists(aDirName + '\images.rxx') then
    fSprites.LoadFromRXXFile(aDirName + '\images.rxx')
  else
    ShowMessage('Campaign background image (images.rxx) could not be found');
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not (ActiveControl is TEdit) then
  begin
    if Key = VK_DELETE then
    begin
      tvList.Selected.Delete;
      UpdateList;
      FRender.Repaint;
    end
    else
      FRender.KeyDown(Key, Shift);
  end;
  //StatusBar1.Panels[1].Text := 'Position ' + IntToStr(Img.Left) + 'x' + IntToStr(Img.Top);
end;

procedure TMainForm.FlagEnter(Sender: TObject);
begin
  StatusBar1.Panels[2].Text := 'Map #' + IntToStr(TImage(Sender).Tag + 1);
end;

procedure TMainForm.NodeEnter(Sender: TObject);
begin
  StatusBar1.Panels[2].Text := 'Node #' + IntToStr(TImage(Sender).Tag + 1);
end;


procedure TMainForm.FlagNodeLeave(Sender: TObject);
begin
  StatusBar1.Panels[2].Text := '';
end;


procedure TMainForm.pmMapPopup(Sender: TObject);
begin
  aAddMission.Enabled := Assigned(fSelectedChapter);
  aAddNode.Enabled := Assigned(fSelectedMission);
  aDelete.Enabled := Assigned(tvList.Selected);
end;

function TMainForm.GetCharset(aLang: string): TFontCharset;
begin
  if Pos(aLang, 'bel,rus,bul,ukr') <> 0 then
    Result := RUSSIAN_CHARSET
  else if Pos(aLang, 'pol,hun,cze,svk,rom') <> 0 then
    Result := EASTEUROPE_CHARSET
  else if Pos(aLang, 'tur') <> 0 then
    Result := TURKISH_CHARSET
  else if Pos(aLang, 'lit,lat') <> 0 then
    Result := BALTIC_CHARSET
  else if Pos(aLang, 'eng,spa,ita,nor,chn,dut,est,ptb,fre,ger,jpn,swe') <> 0 then
    Result := ANSI_CHARSET
  else
    Result := DEFAULT_CHARSET;
end;


procedure TMainForm.LoadCampaignName(aFileName, aLocale: string);
var
  LibxFile: TStringList;
  I : Integer;
  VarText : String;
  VarIndex: Integer;
begin
  if not FileExists(Format(aFileName, [aLocale])) then Exit;
  LibxFile := TStringList.Create;
  LibxFile.LoadFromFile(Format(aFileName, [aLocale]));

  for I := 0 to LibxFile.Count - 1 do
  begin
    VarText := LibxFile.Strings[I];
    VarIndex := Pos('0:', VarText);
    if VarIndex > 0 then
    begin
      C.FullName := Copy(VarText, VarIndex + 2, Length(VarText));
      Break;
    end;
  end;
  LibxFile.Free;
end;


procedure TMainForm.SaveCampaignName(aFileName: string);
var
  LibxFile: TStringList;
  I: Integer;
begin
  LibxFile := TStringList.Create;
  LibxFile.LoadFromFile(aFileName);
  for I := 0 to LibxFile.Count - 1 do
    if Pos('0:', LibxFile.Strings[I]) > 0 then
    begin
      LibxFile.Strings[I] := '0:' + C.FullName;//fCampaignSettings.edtName.Text;
      Break;
    end;
  LibxFile.SaveToFile(aFileName);
  LibxFile.Free;
end;


procedure TMainForm.CreateDefaultLocaleLibxTemplate(aFileName: string);
var
  LibxFile: TextFile;
  I: Integer;
begin
  AssignFile(LibxFile, aFileName);
  try
    ReWrite(LibxFile);

    Writeln(LibxFile, '');
    Writeln(LibxFile, 'MaxID:' + IntToStr(C.MapCount + 9) + EolW);
    Writeln(LibxFile, '0:' + C.FullName);
    Writeln(LibxFile, '1:Mission %d');
    Writeln(LibxFile, '2:Campaign description');
    for I := 0 to C.MapCount-1 do
      Writeln(LibxFile, IntToStr(10 + I) + ':Mission description ' + IntToStr(I + 1));
  finally
    CloseFile(LibxFile);
  end;
end;

function TMainForm.DlgQuestionShow(aCaption, aMsg: string): boolean;
var
  VarBool: boolean;
begin
  VarBool := false;
  {$IFDEF MSWindows}
  if MessageBox(Handle, PChar(aCaption), PChar(aMsg), MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2) = ID_YES then
    VarBool := true
  else
    VarBool := false;
  {$ENDIF}
  {$IFDEF Unix}
  if MessageDlg(aCaption, aMsg, mtConfirmation, [mbYes, mbNo], 0, mbNo) = mrYes then
    VarBool := true
  else
    VarBool := false;
  {$ENDIF}
  Result := VarBool;
end;

procedure TMainForm.edtChapterVideoAfterChange(Sender: TObject);
begin
  if Assigned(SelectedChapter) then
    SelectedChapter.Video[mvAfter] := edtChapterVideoAfter.Text;
end;

procedure TMainForm.edtChapterVideoBeforeChange(Sender: TObject);
begin
  if Assigned(SelectedChapter) then
    SelectedChapter.Video[mvBefore] := edtChapterVideoBefore.Text;
end;

procedure TMainForm.edtMissionVideoAfterChange(Sender: TObject);
begin
  if Assigned(SelectedMission) then
    SelectedMission.Video[mvAfter] := edtMissionVideoAfter.Text;
end;

procedure TMainForm.edtMissionVideoBeforeChange(Sender: TObject);
begin
  if Assigned(SelectedMission) then
    SelectedMission.Video[mvBefore] := edtMissionVideoBefore.Text;
end;

procedure TMainForm.aAddMissionExecute(Sender: TObject);
var
  Node: TTreeChapterMission;
  Position: TPoint;
begin
  FTreeItemCreate := TTreeChapterMission;
  Node := tvList.Items.AddChild(fSelectedChapter, 'Mission') as TTreeChapterMission;
  Node.Selected := True;
  Position := Point(
    EnsureRange(FRender.MouseCameraPosition.X, 0, 1024 - imgRedFlag.Width),
    EnsureRange(FRender.MouseCameraPosition.Y, 0, 768 - imgRedFlag.Height)
  );
  Node.Rect := Rect(Position.X, Position.Y, Position.X + imgRedFlag.Width, Position.Y + imgRedFlag.Height);
  UpdateList;
  FRender.Repaint;
end;

procedure TMainForm.aAddNodeExecute(Sender: TObject);
var
  Node: TTreeChapterNode;
  Position: TPoint;
begin
  if fUpdating then
    Exit;

  FTreeItemCreate := TTreeChapterNode;
  Node := tvList.Items.AddChild(fSelectedMission, 'Node %d') as TTreeChapterNode;
  Node.Selected := True;
  Position := Point(
    EnsureRange(FRender.MouseCameraPosition.X, 0, 1024 - imgNode.Width),
    EnsureRange(FRender.MouseCameraPosition.Y, 0, 768 - imgNode.Height)
  );
  Node.Rect := Rect(Position.X, Position.Y, Position.X + imgNode.Width, Position.Y + imgNode.Height);
  UpdateList;
  FRender.Repaint;
end;

procedure TMainForm.aDeleteExecute(Sender: TObject);
begin
  if Assigned(tvList.Selected) then
    tvList.Selected.Delete;
end;

procedure TMainForm.aNewExecute(Sender: TObject);
var
  I: Integer;
begin
  if DlgQuestionShow('Unsaved data will be lost. Are you sure?', Self.Caption) then
  begin
    C.Free;
    fSprites.Free;

    C := TKMCampaign.Create;
    fSprites := TKMSpritePackEdit.Create(rxCustom, nil);
    //fSelectedMap := -1;

    //for I := 0 to Length(imgNodes) - 1 do
    //  imgNodes[I].Visible := False;
    UpdateCaption;
  end;
end;

procedure TMainForm.aOpenExecute(Sender: TObject);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(fExePath + '..\..\KaM_Remake_Settings.ini');
  Locale := Ini.ReadString('Game', 'Locale', 'eng');
  Ini.Free;

  if DirectoryExists(fCampaignsPath) then
    dlgOpenCampaign.DefaultFolder := fCampaignsPath
  else
    dlgOpenCampaign.DefaultFolder := fExePath;

  dlgOpenCampaign.FileName := dlgOpenCampaign.DefaultFolder;

  if not dlgOpenCampaign.Execute then
    Exit;

  LoadCmp(dlgOpenCampaign.FileName);

  LoadCampaignName(dlgOpenCampaign.FileName + '\' + TEMPLATE_LIBX_FILE_TEXT, Locale);
  if Length(C.FullName) = 0 then
    LoadCampaignName(dlgOpenCampaign.FileName + '\' + TEMPLATE_LIBX_FILE_TEXT , 'eng');
  UpdateCaption;
  CampaignToList;
  UpdateList;
  FRender.RefreshBackground;
  FRender.Repaint;
end;

procedure TMainForm.aPictureMapsExecute(Sender: TObject);
var
  fPictureMaps: TfPictureMaps;
begin
  fPictureMaps := TfPictureMaps.Create(nil);
  try
    fPictureMaps.ShowModal;
    UpdatePictureMaps;
    FRender.RefreshBackground;
  finally
    fPictureMaps.Free;
  end;
end;

procedure TMainForm.aResetZoomExecute(Sender: TObject);
begin
  FRender.ResetZoom;
end;

procedure TMainForm.aSaveExecute(Sender: TObject);
begin
  ListToCampaign;
  if C.MapCount < 2 then
  begin
    ShowMessage('Campaign must have at least 2 missions');
    Exit;
  end;

  if Length(Trim(C.CampName)) <> 3 then
  begin
    ShowMessage('Campaign short title must be 3 characters');
    Exit;
  end;

  dlgOpenCampaign.DefaultFolder := dlgOpenCampaign.FileName;
  dlgOpenCampaign.FileName := dlgOpenCampaign.DefaultFolder;

  if not dlgOpenCampaign.Execute then
    Exit;

  C.SaveToDir(dlgOpenCampaign.FileName);
  fSprites.SaveToRXXFile(dlgOpenCampaign.FileName + '\' + 'images.rxx');

  if FileExists(dlgOpenCampaign.FileName + '\' + Format(TEMPLATE_LIBX_FILE_TEXT, [Locale])) then
    SaveCampaignName(dlgOpenCampaign.FileName + '\' + Format(TEMPLATE_LIBX_FILE_TEXT, [Locale]))
  else
    CreateDefaultLocaleLibxTemplate(dlgOpenCampaign.FileName + '\' + Format(TEMPLATE_LIBX_FILE_TEXT, [Locale]));
end;

procedure TMainForm.aSettingsExecute(Sender: TObject);
var
  formSettings: TfCampaignSettings;
  cmp: TKMCampaignId;
begin
  if fUpdating then
    Exit;
  formSettings := TfCampaignSettings.Create(Self);
  try
    formSettings.edtName.Font.Charset := GetCharset(Locale);
    formSettings.edtName.Text := C.FullName;
    formSettings.edtShortName.Text := StringReplace(C.CampName, #0, '', [rfReplaceAll, rfIgnoreCase]);
    formSettings.UpDownNodeAnimation.Position := C.NodeAnimation;

    if formSettings.ShowModal = mrOk then
    begin
      C.FullName := formSettings.edtName.Text;
      cmp[0] := Ord(formSettings.edtShortName.Text[1]);
      cmp[1] := Ord(formSettings.edtShortName.Text[2]);
      cmp[2] := Ord(formSettings.edtShortName.Text[3]);
      C.CampaignId := cmp;
      C.NodeAnimation := formSettings.UpDownNodeAnimation.Position;
      UpdateCaption;
    end;
  finally
    formSettings.Free;
  end;
end;


procedure TMainForm.UpdateCaption;
begin
  Caption := 'Campaign Build (' + GAME_REVISION + ') ' + StringReplace(C.CampName, #0, '_', [rfReplaceAll, rfIgnoreCase]) + ' - ' + C.FullName;
end;

function TMainForm.CopyNode(ANode: TTreeChapterItem): TTreeChapterItem;
begin
  if ANode is TTreeChapterMission then
    FTreeItemCreate := TTreeChapterMission
  else
    if ANode is TTreeChapterNode then
      FTreeItemCreate := TTreeChapterNode
    else
      Exit(ANode);

  Result := tvList.Items.AddChild(ANode.Parent, 'New node') as TTreeChapterItem;
  Result.Rect := ANode.Rect;
  if ANode.GetNextSibling <> nil then
    Result.MoveTo(ANode.getNextSibling, naInsert)
  else
    Result.MoveTo(ANode, naAdd);
  UpdateList;
end;

procedure TMainForm.CampaignToList;
var
  I, K, J: Integer;
  N, S: TTreeNode;
  VideoType: TMissionVideoTypes;
begin
  fUpdating := True;
  tvList.Items.BeginUpdate;
  try
    tvList.Items.Clear;

    for J := 0 to High(C.Chapters) do
    begin
      FTreeItemCreate := TTreeChapter;
      fSelectedChapter := tvList.Items.AddChild(nil, Format('Chapter %d', [J + 1])) as TTreeChapter;
      fSelectedChapter.PictureMapIndex := C.Chapters[J].PictureMapIndex;
      for VideoType := Low(TMissionVideoTypes) to High(TMissionVideoTypes) do
        fSelectedChapter.Video[VideoType] := C.Chapters[J].Video[VideoType];

      for I := 0 to C.Chapters[J].MapCount - 1 do
      begin
        FTreeItemCreate := TTreeChapterMission;
        fSelectedMission := tvList.Items.AddChild(fSelectedChapter, Format('Mission %d', [I + 1])) as TTreeChapterMission;
        fSelectedMission.TextPos := C.Chapters[J].Maps[I].TextPos;
        fSelectedMission.Rect := Rect(C.Chapters[J].Maps[I].Flag.X, C.Chapters[J].Maps[I].Flag.Y,
          C.Chapters[J].Maps[I].Flag.X + imgRedFlag.Width, C.Chapters[J].Maps[I].Flag.Y + imgRedFlag.Height);

        for VideoType := Low(TMissionVideoTypes) to High(TMissionVideoTypes) do
          fSelectedMission.Video[VideoType] := C.Chapters[J].Maps[I].Video[VideoType];

        for K := 0 to C.Chapters[J].Maps[I].NodeCount - 1 do
        begin
          FTreeItemCreate := TTreeChapterNode;
          fSelectedNode := tvList.Items.AddChild(fSelectedMission, Format('node %d', [K + 1])) as TTreeChapterNode;
          fSelectedNode.Rect := Rect(C.Chapters[J].Maps[I].Nodes[K].X, C.Chapters[J].Maps[I].Nodes[K].Y,
            C.Chapters[J].Maps[I].Nodes[K].X + imgNode.Width, C.Chapters[J].Maps[I].Nodes[K].Y + imgNode.Height);
        end;
      end;
    end;
  finally
    tvList.Items.EndUpdate;
    UpdateList;
    fUpdating := False;
  end;
end;

procedure TMainForm.cbChapterPictureMapChange(Sender: TObject);
begin
  if Assigned(SelectedChapter) then
  begin
    SelectedChapter.PictureMapIndex := cbChapterPictureMap.ItemIndex + 1;
    FRender.RefreshBackground(SelectedChapter.PictureMapIndex);
    FRender.Repaint;
  end;
end;

procedure TMainForm.cbMissionBriefingPosChange(Sender: TObject);
begin
  if Assigned(SelectedMission) then
  begin
    SelectedMission.TextPos := TBriefingCorner(cbMissionBriefingPos.ItemIndex);
    FRender.Repaint;
  end;
end;

procedure TMainForm.cbShowBriefingPageClick(Sender: TObject);
begin
  FRender.Repaint;
end;

procedure TMainForm.cbShowNodeNumbersClick(Sender: TObject);
begin
  FRender.Repaint;
end;

procedure TMainForm.UpdateList;
var
  i, n, MissionNumber, NodeNumber: Integer;
  Passed: Boolean;
  node: TTreeNode;
begin
  Passed := Assigned(tvList.Selected);
  tvList.Items.BeginUpdate;
  try
    MissionNumber := 1;
    node := tvList.Items.GetFirstNode;
    while node <> nil do
    begin
      node.Text := Format('Chapter %d', [node.Index + 1]);
      if (node = SelectedChapter) and not Assigned(SelectedMission) then
        Passed := False;

      for i := 0 to node.Count - 1 do
      begin
        node[i].Text := Format('Mission %d', [MissionNumber]);
        (node[i] as TTreeChapterMission).Number := MissionNumber;
        node[i].ImageIndex := IfThen(Passed, 1, 2);
        node[i].SelectedIndex := node[i].ImageIndex;
        if node[i] = SelectedMission then
          Passed := False;

        Inc(MissionNumber);
        for n := 0 to node[i].Count - 1 do
        begin
          node[i][n].Text := Format('Node %d', [node[i][n].Index + 1]);
          node[i][n].ImageIndex := IfThen(node[i] = fSelectedMission, 3, 4);
          node[i][n].SelectedIndex := node[i][n].ImageIndex;
        end;
      end;
      node := node.GetNextSibling;
    end;
  finally
    tvList.Items.EndUpdate;
  end;
end;

procedure TMainForm.ListToCampaign;
var
  i, k: Integer;
  ChapterCount: Byte;
  node: TTreeNode;
  VideoType: TMissionVideoTypes;
begin
  fUpdating := True;
  try
    ChapterCount := 0;
    node := tvList.Items.GetFirstNode;
    while node <> nil do
    begin
      Inc(ChapterCount);
      node := node.GetNextSibling;
    end;

    SetLength(C.Chapters, ChapterCount);
    node := tvList.Items.GetFirstNode;
    while node <> nil do
    begin
      C.Chapters[node.Index].PictureMapIndex := (node as TTreeChapter).PictureMapIndex;
      C.Chapters[node.Index].MapCount := node.Count;
      for VideoType := Low(TMissionVideoTypes) to High(TMissionVideoTypes) do
        C.Chapters[node.Index].Video[VideoType] := (node as TTreeChapter).Video[VideoType];

      SetLength(C.Chapters[node.Index].Maps, node.Count);
      for i := 0 to node.Count - 1 do
      begin
        C.Chapters[node.Index].Maps[i].Flag := KMPointW(
          (node[i] as TTreeChapterMission).Rect.Left,
          (node[i] as TTreeChapterMission).Rect.Top
        );
        C.Chapters[node.Index].Maps[i].TextPos := (node[i] as TTreeChapterMission).TextPos;
        for VideoType := Low(TMissionVideoTypes) to High(TMissionVideoTypes) do
          C.Chapters[node.Index].Maps[i].Video[VideoType] := (node[i] as TTreeChapterMission).Video[VideoType];

        C.Chapters[node.Index].Maps[i].NodeCount := node[i].Count;
        for k := 0 to node[i].Count - 1 do
          C.Chapters[node.Index].Maps[i].Nodes[k] := KMPointW(
            (node[i][k] as TTreeChapterNode).Rect.Left,
            (node[i][k] as TTreeChapterNode).Rect.Top
          );
      end;
      node := node.GetNextSibling;
    end;

  finally
    fUpdating := False;
  end;
end;

procedure TMainForm.tvListChange(Sender: TObject; Node: TTreeNode);
begin
  if fUpdating then
    Exit;

  fSelectedChapter := nil;
  fSelectedMission := nil;
  fSelectedNode := nil;

  case Node.Level of
    0: begin
      fSelectedChapter := Node as TTreeChapter;
    end;
    1: begin
        fSelectedChapter := Node.Parent as TTreeChapter;
        fSelectedMission := Node as TTreeChapterMission;
      end;
    2: begin
        fSelectedChapter := Node.Parent.Parent as TTreeChapter;
        fSelectedMission := Node.Parent as TTreeChapterMission;
        fSelectedNode := Node as TTreeChapterNode;
      end;
  end;
  UpdateList;
  UpdateBox;
  if Assigned(SelectedChapter) then
    FRender.RefreshBackground(SelectedChapter.PictureMapIndex)
  else
    FRender.RefreshBackground(0);
  FRender.Repaint;
end;

procedure TMainForm.UpdatePictureMaps;
var
  i, Index: Integer;
begin
  if not Assigned(fSelectedChapter) then
    Exit;

  cbChapterPictureMap.Items.BeginUpdate;
  try
    cbChapterPictureMap.Clear;
    for i := 0 to fSprites.RXData.Count - 1 do
      cbChapterPictureMap.Items.Add(IntToStr(i + 1));
    cbChapterPictureMap.ItemIndex := IfThen(fSelectedChapter.PictureMapIndex <= cbChapterPictureMap.Items.Count, fSelectedChapter.PictureMapIndex - 1, 0);
  finally
    cbChapterPictureMap.Items.EndUpdate;
  end;
end;

procedure TMainForm.UpdateBox;
begin
  MissionBox.Visible := Assigned(fSelectedMission);
  ChapterBox.Visible := not MissionBox.Visible and Assigned(fSelectedChapter);
  if ChapterBox.Visible then
  begin
    ChapterBox.Caption := fSelectedChapter.Text;
    UpdatePictureMaps;
    edtChapterVideoBefore.Text := fSelectedChapter.Video[mvBefore];
    edtChapterVideoAfter.Text := fSelectedChapter.Video[mvAfter];
  end
  else
    if MissionBox.Visible then
    begin
      MissionBox.Caption := fSelectedMission.Text;

      edtMissionVideoBefore.Text := fSelectedMission.Video[mvBefore];
      edtMissionVideoAfter.Text := fSelectedMission.Video[mvAfter];
    end;
end;

procedure TMainForm.tvListCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := FTreeItemCreate;
end;

procedure TMainForm.tvListDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  AnItem: TTreeNode;
  Rect: TRect;
begin
  if tvList.Selected = nil then
    Exit;

  AnItem := tvList.GetNodeAt(X, Y);
  if Assigned(AnItem) then
  begin
    if AnItem.Level = tvList.Selected.Level then
    begin
      Rect := AnItem.DisplayRect(False);
      if Y > Rect.Top + Rect.Height div 2 then
      begin
        if AnItem.GetNextSibling <> nil then
          tvList.Selected.MoveTo(AnItem.getNextSibling, naInsert)
        else
          tvList.Selected.MoveTo(AnItem, naAdd);
      end
      else
        tvList.Selected.MoveTo(AnItem, naInsert);
    end
    else
      if AnItem.Level = tvList.Selected.Level - 1 then
        tvList.Selected.MoveTo(AnItem, naAddChild);
  end;
  UpdateList;
  tvList.Repaint;
end;

procedure TMainForm.tvListDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  Node, SelNode : TTreeNode;
  Rect: TRect;
  Position: Integer;
begin
  Node := tvList.GetNodeAt(x, y);
  SelNode := tvList.Selected;
  Accept := (Sender = Source) and ((Node <> nil) and ((Node.Level = SelNode.Level) or (Node.Level = SelNode.Level - 1)));
  if Accept and (Node.Level = SelNode.Level) then
  begin
    tvList.Repaint;
    Rect := Node.DisplayRect(False);

    if Y > Rect.Top + Rect.Height div 2 then
      Position := Rect.Bottom
    else
      Position := Rect.Top;
    tvList.Canvas.Pen.Color := clHighlight;
    tvList.Canvas.MoveTo(Rect.Left + 8, Position);
    tvList.Canvas.LineTo(Rect.Right - 8, Position);
  end;
end;

end.
