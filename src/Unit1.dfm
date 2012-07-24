object ZPBForm: TZPBForm
  Left = 724
  Top = 195
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'ZPatchBuilder'
  ClientHeight = 482
  ClientWidth = 319
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object gbBuildInfo: TGroupBox
    Left = 16
    Top = 16
    Width = 289
    Height = 345
    Caption = 'Build Patch'
    TabOrder = 0
    object lblKey: TLabel
      Left = 40
      Top = 60
      Width = 22
      Height = 13
      Caption = 'Key:'
      Enabled = False
    end
    object lblKeyHint: TLabel
      Left = 128
      Top = 60
      Width = 36
      Height = 13
      Caption = '(1-100)'
      Enabled = False
    end
    object lblBlacklist: TLabel
      Left = 16
      Top = 96
      Width = 37
      Height = 13
      Hint = 'Files not included in the patch file'
      Caption = 'Blacklist'
      ParentShowHint = False
      ShowHint = True
    end
    object btnPatch: TButton
      Left = 16
      Top = 152
      Width = 257
      Height = 25
      Caption = 'Make Patch File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnPatchClick
    end
    object lbLog: TListBox
      Left = 16
      Top = 192
      Width = 257
      Height = 129
      ItemHeight = 13
      TabOrder = 1
    end
    object cbUseKey: TCheckBox
      Left = 16
      Top = 32
      Width = 257
      Height = 17
      Hint = 'Select this option to use a custom Lambda key'
      Caption = 'Custom MRS encryption key'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = cbUseKeyClick
    end
    object edKey: TEdit
      Left = 80
      Top = 56
      Width = 41
      Height = 21
      Enabled = False
      TabOrder = 3
      Text = '0'
    end
    object edBlacklist: TEdit
      Left = 16
      Top = 120
      Width = 257
      Height = 21
      TabOrder = 4
      Text = 
        'patch.xml,config.xml,lastchar.dat,crosshair.png,crosshair_pick.p' +
        'ng,thumbs.db,mlog.txt,profile.txt,test.txt'
    end
  end
  object gbProgress: TGroupBox
    Left = 16
    Top = 376
    Width = 281
    Height = 89
    Caption = 'Patch Progress'
    TabOrder = 1
    object lblProgText: TLabel
      Left = 88
      Top = 56
      Width = 8
      Height = 13
      Caption = '--'
    end
    object lblProgress: TLabel
      Left = 16
      Top = 56
      Width = 42
      Height = 13
      Caption = 'Progress'
    end
    object pbProgress: TProgressBar
      Left = 16
      Top = 24
      Width = 249
      Height = 16
      Max = 1
      Smooth = True
      Step = 1
      TabOrder = 0
    end
  end
end
