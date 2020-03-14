object FormPerfLogs: TFormPerfLogs
  Left = 227
  Top = 108
  Align = alClient
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'PerfLog'
  ClientHeight = 389
  ClientWidth = 280
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 104
    Top = 144
    Width = 125
    Height = 13
    Caption = 'Filled in dynamically on init'
    Visible = False
  end
  object Label2: TLabel
    Left = 95
    Top = 8
    Width = 67
    Height = 13
    Caption = 'Frame budget'
  end
  object cbStackedGFX: TCheckBox
    Left = 8
    Top = 24
    Width = 81
    Height = 17
    Caption = 'Stacked GFX'
    TabOrder = 0
    OnClick = DoChange
  end
  object seFrameBudget: TSpinEdit
    Left = 95
    Top = 27
    Width = 73
    Height = 22
    MaxValue = 100
    MinValue = 2
    TabOrder = 1
    Value = 5
    OnChange = DoChange
  end
  object cbStackedCPU: TCheckBox
    Left = 8
    Top = 8
    Width = 81
    Height = 17
    Caption = 'Stacked CPU'
    TabOrder = 2
    OnClick = DoChange
  end
  object cbSmoothLines: TCheckBox
    Left = 184
    Top = 8
    Width = 81
    Height = 17
    Caption = 'Smooth lines'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = DoChange
  end
end
