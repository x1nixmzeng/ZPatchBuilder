{
  zpatchbuilder
  x1nixmzeng (September 2010)

  Checksum functionality

  Thanks to TheivingSix and aluigi                 
}
unit ZPatch;

interface

uses Windows, Classes, SysUtils;

const
  NO_KEY = $0;

type
  ZPatchNode = record
    Success  : Boolean;   // Marks successful checksum
    FileName : String;    // Path to file
    Checksum : LongWord;  // When successful, the patch file checksum
    FileSize : Longword;  // When successful, the size of the patch file
  end;

  procedure Checksum(var PatchNode : ZPatchNode);
  procedure SetLambda(key:byte);
  function GetLambda : byte;

implementation

var
  MRSBYTE : byte = NO_KEY;

// Set the encryption byte
//
procedure SetLambda(key:byte);
begin
  MRSBYTE := key;
end;

// Get the encryption byte
//
function GetLambda : byte;
begin
  result := MRSBYTE;
end;

// Decryption routine with space to patch the assembly 
//
procedure Decrypt(var InByte: Byte; Key: Byte = NO_KEY); overload;
var
  bAL, bDl : Byte;
begin
  if Key = NO_KEY then
  begin
    bAL := InByte;
    bDl := bAL;
    bDl := bDl shr 3;
    bAL := bAL shl 5;
    bDl := bDl or bAL;
    InByte := not bDl;
    asm nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop; end;
  end else
  begin
    InByte := InByte - Key;
    asm nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop;nop; end;
  end;
end;

// MRS checksum (I think this uses code by ThievingSix)
//
procedure ResourceChecksum(var PatchNode : ZPatchNode);
var
  FStream : TFileStream;
  i,
  j,
  tmp     : LongWord;

  MRSVER : array[1..4] of byte;
  EoCDR : array[1..22] of byte;

  TotalFiles : word;
  CDPosition    : longword;

  CDFH : array[1..46] of byte;

  fnlen, exlen,
  cmtlen       : word;

begin

  try
    FStream := TFileStream.Create(PatchNode.FileName, 0);
  except
    PatchNode.Success := False;
    Exit;
  end;
  
  PatchNode.FileSize := FStream.Size;
  PatchNode.Checksum := 0;

  // Check MRS header
  FStream.Read(MRSVER, 4);

  for i:=1 to 4 do decrypt(MRSVER[i],MRSBYTE);

  if (MRSVER[1]<>byte('P')) or
     (MRSVER[2]<>byte('K')) or
     (MRSVER[3]<>$3) or
     (MRSVER[4]<>$4) then
  begin
    PatchNode.Success := False;
    FStream.Free;
    Exit;
  end;

  // Skip to the end of central directory record
  FStream.Position := FStream.Size - 22;
  
  FillChar(EoCDR, 22, #0);
  FStream.Read(EoCDR, 22);

  for i:=1 to 22 do decrypt(EoCDR[i],MRSBYTE);

  TotalFiles := (EoCDR[11] * $1)
              + (EoCDR[12] * $100);

  CDPosition := (EoCDR[17] * $1)
              + (EoCDR[18] * $100)
              + (EoCDR[19] * $10000)
              + (EoCDR[20] * $1000000);


  // Skip to central directory record
  FStream.Position := CDPosition;

  for j:=1 to TotalFiles do
  begin

    fillchar(CDFH, 46, #0);
    FStream.Read(CDFH, 46);

    for i:=1 to 46 do decrypt(CDFH[i],MRSBYTE);

    // CRC checksum for this file entry
    tmp    := (CDFH[17] * $1)
            + (CDFH[18] * $100)
            + (CDFH[19] * $10000)
            + (CDFH[20] * $1000000);

    fnlen  := (CDFH[29] * $1)
            + (CDFH[30] * $100);

    exlen  := (CDFH[31] * $1)
            + (CDFH[32] * $100);

    cmtlen := (CDFH[33] * $1)
            + (CDFH[34] * $100);

    Inc(PatchNode.Checksum, tmp);

    FStream.Seek(fnlen + exLen + cmtLen, soCurrent);

  end;

  PatchNode.Success := True;
  FStream.Free;

end;

// Non-MRS file checksum (aluigi)
//
procedure BinaryChecksum(var PatchNode : ZPatchNode);
var
  FStream : TFileStream;
  tmp,
  i       : LongWord;
begin

  try
    FStream := TFileStream.Create(PatchNode.FileName, 0);
  except
    PatchNode.Success := False;
    Exit;
  end;

  PatchNode.FileSize := FStream.Size;
  PatchNode.Checksum := PatchNode.FileSize;
  PatchNode.Success  := True;

  for i := 1 to (PatchNode.FileSize div 4) do
  begin
    FStream.Read(tmp, 4);
    Inc(PatchNode.Checksum, tmp);
  end;

  if (PatchNode.FileSize mod 4) <> 0 then
  begin
    tmp := 0;
    FStream.Read(tmp, (PatchNode.FileSize mod 4));
    Inc(PatchNode.Checksum, tmp);
  end;

  FStream.Free;

end;

// Checksum file 
//
procedure Checksum(var PatchNode : ZPatchNode);
begin

  PatchNode.FileSize := 0;
  PatchNode.Checksum := 0;

  if lowercase(extractfileext(PatchNode.FileName)) = '.mrs' then
    ResourceChecksum(PatchNode)
  else
    BinaryChecksum(PatchNode);

end;

end.
