unit CompressUtils;

interface

uses
  SysUtils, Classes, LibTar, BZip2, StrMatch, SciZipFile;

const
  FILE_TYPE_BZIP2 = 0;
  FILE_TYPE_ZIP   = 1;

{extract functions}
function ExtractFile(const SrcFileName, DestFileName: String): Boolean;
function ExtractBzip2File(const FileName: String; Stream: TStream): Boolean; overload;
function ExtractBzip2File(FileStream, Stream: TStream): Boolean; overload;
function ExtractTarFile(Source, OutFile: TStream): Boolean;

{ search match file }
function FindTarFile(const FindName, Source: String; OutFile: TStream): Boolean; overload;
function FindTarFile(const FindName: String; Source, OutFile: TStream): Boolean; overload;
{no extract/search only}
function FindedTarFile(const FindName: String; Source: TStream): Boolean;

function FindZipFile(const FindName: String; Source: TZipFile; OutFile: TStream): Boolean;
{no extract/search only}
function FindedZipFile(const FindName: String; Source: TZipFile): Boolean;

implementation

function ConvertSlashes(Path: String): String;
var
  i: Integer;
begin
  Result := Path;
  for i := 1 to Length(Result) do
      if Result[i] = '/' then
          Result[i] := '\';
end;

function ExtractFile(const SrcFileName, DestFileName: String): Boolean;
var
  Tp: Integer;
  Src: TFileStream;
  Dest: TFileStream;
  Zp: TZipFile;
  Ft: array[0..2] of Char;
begin
  Result := False;
  try
    Src := TFileStream.Create(SrcFileName, fmOpenRead + fmShareDenyWrite);
  except
    Exit;
  end;
  Ft[2] := #0;
  Src.Read(Ft, 2);
  if Ft = 'BZ' then
    Tp := FILE_TYPE_BZIP2
  else if String(Ft) = 'PK' then
    Tp := FILE_TYPE_ZIP
  else
  begin
    Src.Free;
    Exit;
  end;

  Src.Position := 0;
  case Tp of
    FILE_TYPE_BZIP2:
    begin
      try
        Dest := TFileStream.Create(ChangeFileExt(DestFileName, '.tar'), fmCreate);
      except
        Src.Free;
        Exit;
      end;
      Result := ExtractBzip2File(Src, Dest);
      if Result then
      begin
        Dest.Position := 0;
        Src.Free;
        Src := Dest;
        try
          Dest := TFileStream.Create(DestFileName, fmCreate);
        except
          Src.Free;
          Exit;
        end;
        if not ExtractTarFile(Src, Dest) then
        begin
          Src.Free;
          Dest.Free;
          Exit;
        end;
      end;
      Dest.Free;
      Src.Free;
      Result := True;
      DeleteFile(ChangeFileExt(DestFileName, '.tar'));
      Exit;
    end;
    FILE_TYPE_ZIP:
    begin
      try
        Dest := TFileStream.Create(DestFileName, fmCreate);
      except
        Src.Free;
        Exit;
      end;
      Zp := TZipFile.Create;
      Zp.LoadFromStream(Src);
      if not Zp.ExtractFile(Dest) then
      begin
        Zp.Free;
        Src.Free;
        Dest.Free;
        Exit;
      end;
      Zp.Free;
      Dest.Free;
    end;
  else
    Src.Free;
    Exit;
  end;
  Src.Free;
  Result := True;
end;

function ExtractTarFile(Source, OutFile: TStream): Boolean;
var
  TA        : TTarArchive;
  DirRec    : TTarDirRec;
begin
  Result := False;
  try
    TA := TTarArchive.Create(Source);
    TA.Reset;
    if TA.FindNext(DirRec) then
      TA.ReadFile(OutFile);
    TA.Free;
  except
    Exit;
  end;
  Result := True;
end;

function ExtractBzip2File(const FileName: String; Stream: TStream): Boolean;
var
  Source: TFileStream;
begin
  Result := False;
  try
    Source := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  except
    Exit;
  end;
  Result := ExtractBzip2File(Source, Stream);
end;

function ExtractBzip2File(FileStream, Stream: TStream): Boolean;
const
  BufferSize = 65536;
var
  Count: Integer;
  Decomp: TBZDecompressionStream;
  Buffer: array[0..BufferSize - 1] of Byte;
begin
  Result := False;
  try
    Decomp := TBZDecompressionStream.Create(FileStream);
    while True do
    begin
      Count := Decomp.Read(Buffer, BufferSize);
      if Count <> 0 then Stream.WriteBuffer(Buffer, Count) else Break;
    end;
    Decomp.Free;
  except
    Exit;
  end;
  Result := True;
end;

function FindTarFile(const FindName, Source: String; OutFile: TStream): Boolean;
var
  TA        : TTarArchive;
  DirRec    : TTarDirRec;
  S: String;
begin
  Result := False;
  try
    TA := TTarArchive.Create(Source);
    TA.Reset;
    while TA.FindNext(DirRec) do
    begin
      S := ConvertSlashes(DirRec.Name);
      if (DirRec.FileType = ftDirectory) then Continue;
      if FileNameMatch(FindName, S) then
      begin
        TA.ReadFile(OutFile);
        TA.Free;
        Result := True;
        Exit;
      end;
    end;
    TA.Free;
  except
  end;
end;

function FindTarFile(const FindName: String; Source, OutFile: TStream): Boolean;
var
  TA        : TTarArchive;
  DirRec    : TTarDirRec;
  S: String;
begin
  Result := False;
  try
    TA := TTarArchive.Create(Source);
    TA.Reset;
    while TA.FindNext(DirRec) do
    begin
      S := ConvertSlashes(DirRec.Name);
      if (DirRec.FileType = ftDirectory) then Continue;
      if FileNameMatch(FindName, S) then
      begin
        TA.ReadFile(OutFile);
        TA.Free;
        Result := True;
        Exit;
      end;
    end;
    TA.Free;
  except
  end;
end;

function FindedTarFile(const FindName: String; Source: TStream): Boolean;
var
  TA        : TTarArchive;
  DirRec    : TTarDirRec;
  S: String;
begin
  Result := False;
  try
    TA := TTarArchive.Create(Source);
    TA.Reset;
    while TA.FindNext(DirRec) do
    begin
      S := ConvertSlashes(DirRec.Name);
      if (DirRec.FileType = ftDirectory) then Continue;
      if FileNameMatch(FindName, S) then
      begin
        TA.Free;
        Result := True;
        Exit;
      end;
    end;
    TA.Free;
  except
  end;
end;

function FindZipFile(const FindName: String; Source: TZipFile; OutFile: TStream): Boolean;
var
  I: Integer;
  Ss: TStringStream;
  S: String;
begin
  Result := False;
  for I := 0 to Pred(Source.Count) do
  begin
    S := ConvertSlashes(Source.Name[I]);
    if FileNameMatch(FindName, S) then
    begin
      Result := True;
      Ss := TStringStream.Create(Source.Data[i]);
      OutFile.CopyFrom(Ss, Ss.Size);
      Ss.Free;
      Exit;
    end;
  end;
end;

function FindedZipFile(const FindName: String; Source: TZipFile): Boolean;
var
  I: Integer;
  S: String;
begin
  Result := False;
  for I := 0 to Pred(Source.Count) do
  begin
    S := ConvertSlashes(Source.Name[I]);
    if FileNameMatch(FindName, S) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

end.
