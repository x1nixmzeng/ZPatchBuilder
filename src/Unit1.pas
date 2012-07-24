{
  zpatchbuilder
  x1nixmzeng (September 2010)

  This build is missing the self-check code
}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ZPatch, ExtCtrls;

type
  TZPBForm = class(TForm)
    lbLog: TListBox;
    btnPatch: TButton;
    gbBuildInfo: TGroupBox;
    gbProgress: TGroupBox;
    pbProgress: TProgressBar;
    lblProgText: TLabel;
    lblProgress: TLabel;
    cbUseKey: TCheckBox;
    lblKey: TLabel;
    edKey: TEdit;
    lblKeyHint: TLabel;
    edBlacklist: TEdit;
    lblBlacklist: TLabel;
    procedure btnPatchClick(Sender: TObject);
    procedure cbUseKeyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ZPBForm: TZPBForm;

const
  TABCHR : char = #9;

implementation

{$R *.dfm}

procedure Alert(str : string);
begin
  MessageBoxA(ZPBForm.Handle, PChar(str), 'ZPatchBuilder', MB_OK or MB_ICONASTERISK);
end;

procedure BuildPatchlist(Patchlist: TStringList; Patchfolder: string; blist:tstringlist);
var
  SR: TSearchRec;
  DirList: TStringList;

  IsFound: Boolean;

  doadd : boolean;
  i,j: integer;
begin

  if Patchfolder[length(Patchfolder)] <> '\' then
    Patchfolder := Patchfolder + '\';

  IsFound := FindFirst(Patchfolder+'*.*', faAnyFile-faDirectory, SR) = 0;
  while IsFound do begin

    doadd := true;

    for j:=0 to blist.Count-1 do
      if blist.Strings[j] = lowercase(sr.Name) then doadd := false;

    if doadd then
      Patchlist.Add(Patchfolder+SR.Name);

    IsFound := FindNext(SR) = 0;
  end;
  FindClose(SR);

  // Build a list of subdirectories
  DirList := TStringList.Create;
  IsFound := FindFirst(Patchfolder+'*.*', faAnyFile, SR) = 0;
  while IsFound do begin
    if ((SR.Attr and faDirectory) <> 0) and
         (SR.Name[1] <> '.') then
      DirList.Add(Patchfolder + SR.Name);
    IsFound := FindNext(SR) = 0;
  end;
  FindClose(SR);

  // Scan the list of subdirectories
  for i := 0 to DirList.Count - 1 do
    BuildPatchlist(Patchlist, DirList[i], blist);

  DirList.Free;

end;



procedure TZPBForm.btnPatchClick(Sender: TObject);
var
  tsl : tstringlist;
  i,j : integer;

  PNode : ZPatchNode;

  tstr, cd : string;

  patchout,
  blacklist : tstringlist;

  // Name the patch file as the xml expects it
  //
  function Naming(dir,fil:string) : string;
  var i : integer;
  begin
    result := '.' + copy(fil, length(dir)+1, length(fil)-length(dir));

    for i := 0 to length(result)-1 do
      if result[i] = '\' then result[i] := '/';
  end;

begin

 // Attempt to set the MRS encryption key
 if cbUseKey.checked then
 begin

   try
     i := strtoint(edKey.text);
     if (i < 1 ) or (i > 100) then
     begin
       alert('Lambda keys are between 1 and 100!');
       exit;
     end;

     zpatch.SetLambda(i);

   except
     alert('Lambda keys are between 1 and 100!');
     exit;
   end;

 end
 else
   zpatch.SetLambda(zpatch.NO_KEY); 

 btnPatch.Enabled := False;

 // Create the blacklist
 blacklist := TStringList.Create;
 blacklist.Delimiter := ',';
 blacklist.DelimitedText := edBlacklist.Text;

 // Add the name of this program (typically zpatchbuilder.exe)
 blacklist.Add(extractfilename(paramstr(0)));

 // Convert to lowercase
 for j:=0 to blacklist.Count-1 do
   blacklist.Strings[j] := lowercase(blacklist.strings[j]);

 tsl := TStringList.Create;

 cd := GetCurrentDir();

 // Find all files to patch
 BuildPatchlist(tsl, cd, blacklist);

 lbLog.Clear;
 pbProgress.Position := 0;
 pbProgress.Max := tsl.Count;

 // Output XML file
 patchout := TStringList.Create;

 // Write XML headers
 patchout.Add('<?xml version="1.0"?>');
 patchout.Add('<XML>');
 patchout.Add('<PATCHINFO>');

 for i := 0 to tsl.Count -1 do
 begin

   fillchar(PNode, sizeof(ZPatchNode), #0);
   PNode.FileName := tsl.Strings[i];

   lblProgText.Caption := inttostr(i+1)+ ' / ' + inttostr(tsl.Count);

   tstr := Naming(cd, PNode.FileName);

   lbLog.Items.Add(tstr + '... ');
   application.ProcessMessages;
   PNode.Success := False;
   ZPatch.Checksum( PNode );

   if PNode.Success then
   begin
     lbLog.Items.Strings[i] := lbLog.Items.Strings[i] + 'done';

     patchout.Add(TABCHR + '<PATCHNODE file="' + tstr + '">');
     patchout.Add(TABCHR + TABCHR + '<SIZE>' + inttostr(PNode.FileSize) + '</SIZE>');
     patchout.Add(TABCHR + TABCHR + '<CHECKSUM>' + inttostr(PNode.Checksum) + '</CHECKSUM>');
     patchout.Add(TABCHR + '</PATCHNODE>');

   end
   else
     lbLog.Items.Strings[i] := lbLog.Items.Strings[i] + 'failed';

   lbLog.Selected[i] := True;

   pbProgress.Position := i+1;

   application.ProcessMessages;

 end;

 // Write XML footers
 patchout.Add('</PATCHINFO>');
 patchout.Add('</XML>'); 

 // Finally, save this data
 patchout.SaveToFile('patch.xml');

 blacklist.Free;
 patchout.Free;
 tsl.Free;

 btnPatch.Enabled := True;
end;

procedure TZPBForm.cbUseKeyClick(Sender: TObject);
begin

  // Toggle between states when the checkbox is changed
  lblKey.Enabled    := cbUseKey.Checked;
  lblKeyHint.Enabled:= cbUseKey.Checked;
  edKey.Enabled     := cbUseKey.Checked;

end;

end.
