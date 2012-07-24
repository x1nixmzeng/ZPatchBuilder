program ZPatchBuilder;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ZPBForm},
  ZPatch in 'ZPatch.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ZPatchBuilder';
  Application.CreateForm(TZPBForm, ZPBForm);
  Application.Run;
end.
