unit UUtils;

interface

{$I Falcon.inc}

uses
  Windows, Forms, SysUtils, Messages, Classes, XMLDoc, XMLIntf, ComCtrls,
  ShlObj, IniFiles;

const
  FALCON_URL_UPDATE = 'https://downloads.sourceforge.net/project/falconcpp/' +
    'Update/Update.xml';
  CSIDL_PROGRAM_FILES = $0026;
  {$EXTERNALSYM PBS_MARQUEE}
  PBS_MARQUEE = $0008;
  {$EXTERNALSYM PBM_SETMARQUEE}
  PBM_SETMARQUEE = WM_USER+10;
  CSIDL_COMMON_APPDATA = $0023;
  MAX_STR_FRM_UPD = 25;
  CONST_STR_FRM_UPD: array[1..MAX_STR_FRM_UPD] of string = (
    'Application Update',
    'Looking for updates',
    '&Update',
    'Falcon C++ is open, do you want to close it?',
    'Update failed',
    'Conection problem.',
    'Upgrade completed successfully.',
    'Upgrade completed',
    'Download failed: try again.',
    'Download error',
    'Downloading 0%...',
    'Connecting...',
    'Downloading...',
    'Locating new version of the Falcon C++...',
    'Changes:',
    'XML Format error',
    'No update available',
    'This version is newer than the repository',
    'Installed version is already the newest version',
    'Update available',
    'New version available: %s',
    '&Close',
    '&Ok',
    '&Cancel',
    'Installing...'
  );

type

  TVersion = packed record
    Major: Word;
    Minor: Word;
    Release: Word;
    Build: Word;
  end;

function GetFileVersionA(FileName: String): TVersion;
function ParseVersion(Version: String): TVersion;
function CompareVersion(Ver1, Ver2: TVersion): Integer;
function VersionToStr(Version: TVersion): String;
procedure LoadLang;
function IsSecureUpdate: Boolean;
function CanUpdate(UpdateXML: String): Boolean;
function BringUpApp(const ClassName: string): Boolean;
procedure RunSecureUpdater;
function ForceForegroundWindow(hwnd: THandle): Boolean;
procedure SetProgsType(PrgsBar: TProgressBar; Infinity: Boolean);
function GetLangFileName: String;
procedure WriteIniFile(Const Section, Ident, Value: String);
function ReadIniFile(Section, Ident, Default: String): String;
function GetFalconDir: String;

var
  STR_FRM_UPD: array[1..MAX_STR_FRM_UPD] of String;
  FalconVersion: TVersion;
  ConfigPath, AppRoot: String;

implementation

uses UFrmUpdate, Registry, ShellAPI, SystemUtils, UnicodeUtils;

Function GetFileVersionA(FileName: String): TVersion;
type
  PFFI = ^vs_FixedFileInfo;
var
  F       : PFFI;
  Handle  : Dword;
  Len     : Longint;
  Data    : Pchar;
  Buffer  : Pointer;
  Tamanho : Dword;
  Parquivo: Pchar;
begin
  Result.Major:= 0;
  Result.Minor:= 0;
  Result.Release:= 0;
  Result.Build:= 0;
  Parquivo := StrAlloc(Length(FileName) + 1);
  StrPcopy(Parquivo, FileName);
  Len := GetFileVersionInfoSize(Parquivo, Handle);
  if Len > 0 then
  begin
    Data:=StrAlloc(Len+1);
    if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
    begin
      VerQueryValue(Data, '',Buffer,Tamanho);
      F := PFFI(Buffer);
      Result.Major:= HiWord(F^.dwFileVersionMs);
      Result.Minor:= LoWord(F^.dwFileVersionMs);
      Result.Release:= HiWord(F^.dwFileVersionLs);
      Result.Build:= Loword(F^.dwFileVersionLs);
    end;
    StrDispose(Data);
  end;
  StrDispose(Parquivo);
end;

function GetLine(Str: String; Index: Integer): String;
var
  Line: String;
  I: Integer;
begin
  Line := '';
  I := 0;
  while (Pos(#13, Str) > 0) do
  begin
    Line := Copy(Str, 1, Pos(#13, Str) - 1);
    Delete(Str, 1, Pos(#13, Str));
    if (I = Index) then
    begin
      Result := Line;
      Exit;
    end;
    Inc(I);
  end;
  if (I = Index) then Line := Str;
  Result := Line;
end;

function CountLine(Str: String): Integer;
begin
  Result := 0;
  while (Pos(#13, Str) > 0) do
  begin
    Delete(Str, 1, Pos(#13, Str));
    Inc(Result);
  end;
  if Length(Str) > 0 then Inc(Result);
end;

function GetTypes(afmt: String): String;
var
  I: Integer;
  Symb: array[0..1] of Char;
  Res: String;
begin
  Res := '';
  for I:= 1 to Length(afmt) do
    if (I < Length(afmt)) then
    begin
      Symb[0] := afmt[I];
      Symb[1] := afmt[I + 1];
      if CompareStr(Symb, '%s') = 0 then Res := Res + 's';
      if CompareStr(Symb, '%c') = 0 then Res := Res + 'c';
      if CompareStr(Symb, '%d') = 0 then Res := Res + 'd';
      if CompareStr(Symb, '%f') = 0 then Res := Res + 'f';
    end;
  Result := Res;
end;

function sscanf(const fmt, src: String; const params: array of Pointer): Boolean;
var
  Consts, Values: String;
  Temp, Str, Types: String;
  I: Integer;
  //results
  StrResPtr: PString;
  CharResPtr: PChar;
  IntResPtr: PInteger;
  FloatResPtr: PExtended;
begin
  Temp := fmt;
  Result := False;
  if (Length(fmt) < 2) or (Length(src) = 0) then Exit;
  Types := GetTypes(fmt);
  for I:= 1 to Length(types) do
    Temp := StringReplace(Temp, '%' + types[I], #13, [rfReplaceAll]);
  if Temp[Length(Temp)] = #13 then Delete(Temp, Length(Temp), 1);
  if Temp[1] = #13 then Delete(Temp, 1, 1);
  Consts := Temp;
  Temp := src;
  for I:= 0 to Pred(CountLine(Consts)) do
  begin
    Str := GetLine(Consts, I);
    if (Pos(Str, Temp) > 0) then
      Temp := StringReplace(Temp, Str, #13, [])
    else
      Exit;
  end;
  Values := Temp;
  if (CountLine(Values) <> Length(Types)) then Exit;
  for I:= 0 to High(params) do
  begin
    case Types[I + 1] of
      's':
      begin
        StrResPtr := params[I];
        StrResPtr^ := GetLine(Values, I);
      end;
      'c':
      begin
        CharResPtr := params[I];
        CharResPtr^ := GetLine(Values, I)[1];
      end;
      'd':
      begin
        IntResPtr := params[I];
        IntResPtr^ := StrToIntDef(GetLine(Values, I), 0);
      end;
      'f':
      begin
        FloatResPtr := params[I];
        FloatResPtr^ := StrToFloatDef(GetLine(Values, I), 0);
      end;
    end;
  end;
  Result := True;
end;

function ParseVersion(Version: String): TVersion;
var
  v1, v2, v3, v4: Integer;
begin
  if sscanf('%d.%d.%d.%d', Version, [@v1, @v2, @v3, @v4]) then
  begin
    Result.Major := v1;
    Result.Minor := v2;
    Result.Release := v3;
    Result.Build := v4;
  end
  else
  begin
    Result.Major := 0;
    Result.Minor := 0;
    Result.Release := 0;
    Result.Build := 0;
  end;
end;

function VersionToStr(Version: TVersion): String;
begin
  Result := Format('%d.%d.%d.%d', [
            Version.Major,
            Version.Minor,
            Version.Release,
            Version.Build
            ]);
end;

function CompareVersion(Ver1, Ver2: TVersion): Integer;

  procedure ExitFunction(Value: Integer);
  begin
    Result := Value;
    Exit;
  end;

begin
  if Ver1.Major > Ver2.Major then
    ExitFunction(1)
  else
  begin
    if Ver1.Major < Ver2.Major then
      ExitFunction(-1)
    else
      if Ver1.Minor > Ver2.Minor then
        ExitFunction(1)
      else
      begin
        if Ver1.Minor < Ver2.Minor then
          ExitFunction(-1)
        else
          if Ver1.Release > Ver2.Release then
            ExitFunction(1)
          else
          begin
            if Ver1.Release < Ver2.Release then
              ExitFunction(-1)
            else
              if Ver1.Build > Ver2.Build then
                ExitFunction(1)
              else
              begin
                if Ver1.Build < Ver2.Build then
                  ExitFunction(-1)
                else
                  ExitFunction(0);
              end;
          end;
      end;
  end;
end;

function CanUpdate(UpdateXML: String): Boolean;
var
  XMLDoc: TXMLDocument;
  Node, FalconNode: IXMLNode;
  SiteVersion: TVersion;
begin
  Result := False;
  if not FileExists(UpdateXML) then Exit;
  XMLDoc := TXMLDocument.Create(FrmUpdate);
  try
    XMLDoc.LoadFromFile(UpdateXML);
  except
    //XMLDoc.Free;
    Exit;
  end;
  XMLDoc.Options := XMLDoc.Options + [doNodeAutoIndent];
  XMLDoc.NodeIndentStr := '    ';

  //tag FalconCPP
  FalconNode := XMLDoc.ChildNodes.FindNode('FalconCPP');
  Node := FalconNode.ChildNodes.FindNode('Core');
  SiteVersion := ParseVersion(Node.Attributes['Version']);
  if (CompareVersion(SiteVersion, FalconVersion) = 1) then
    Result := True;
  //XMLDoc.Free;
end;

procedure LoadLang;
var
  LangFile: String;
  I: Integer;
  ini: TMemIniFile;

  function ReadStr(const Ident: Integer; const Default: String): String;
  begin
    Result := ini.ReadString('FALCON', IntToStr(Ident), Default);
  end;

var
  Lines: TStrings;
begin
  LangFile := GetLangFileName;
  if FileExists(LangFile) then
  begin
    Lines := TStringList.Create;
    ini := TMemIniFile.Create('');
    try
      LoadFileEx(LangFile, Lines);
      TMemIniFile(ini).SetStrings(Lines);
    except
    end;
    Lines.Free;
    for I := 1 to 25 do//4001 - 4021
      STR_FRM_UPD[I] := ReadStr(I + 4000, CONST_STR_FRM_UPD[I]);
    ini.Free;
  end
  else
    for I := 1 to MAX_STR_FRM_UPD do//4001 - 4020
      STR_FRM_UPD[I] := CONST_STR_FRM_UPD[I];//default english
end;

function BringUpApp(const ClassName: string): Boolean;
var
  Handle, AppHandle: HWND;
begin
  Result := False;
  AppHandle := FindWindow(PChar(ClassName), nil);
  if AppHandle <> 0 then
  begin
    Handle := GetWindowLong(AppHandle, GWL_HWNDPARENT);
    ForceForegroundWindow(AppHandle);
    if IsIconic(Handle) then
      ShowWindow(Handle, SW_RESTORE);
    Result := True;
  end;
end;

procedure RunSecureUpdater;
var
  I: Integer;
  ExeRunUpdater, params, RunTempDir: string;
begin
  RunTempDir := GetTempDirectory + '~falcon_updater.tmp\';
  ExeRunUpdater := RunTempDir + ExtractFileName(Application.ExeName);
  if FileExists(ExeRunUpdater) then
    DeleteFile(ExeRunUpdater);
  if not DirectoryExists(RunTempDir) and not CreateDir(RunTempDir) then
    Exit;
  if not CopyFile(PChar(Application.ExeName), PChar(ExeRunUpdater), FALSE) and
    BringUpApp('TFrmUpdate') then
    Exit;
  params := '';
  for I := 1 to ParamCount do
  begin
    if Pos(' ', ParamStr(I)) > 0 then
      params := params + ' "' + ParamStr(I) + '"'
    else
      params := params + ' ' + ParamStr(I);
  end;
  params := params + ' --path "' + AppRoot + '"';
  ShellExecute(0, 'open', PChar(ExeRunUpdater), PChar(params),
      PChar(ExtractFilePath(RunTempDir)), SW_SHOW);
end;

function ForceForegroundWindow(hwnd: THandle): Boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegroundThreadID: DWORD;
  ThisThreadID: DWORD;
  timeout: DWORD;
begin
  if IsIconic(hwnd) then
    ShowWindow(hwnd, SW_RESTORE);

  if GetForegroundWindow = hwnd then
    Result := True
  else
  begin
    // Windows 98/2000 doesn't want to foreground a window when some other
    // window has keyboard focus

    if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4)) or
      ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
      ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
      (Win32MinorVersion > 0)))) then
    begin
      // Code from Karl E. Peterson, www.mvps.org/vb/sample.htm
      // Converted to Delphi by Ray Lischner
      // Published in The Delphi Magazine 55, page 16

      Result := False;
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
      ThisThreadID := GetWindowThreadPRocessId(hwnd, nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, True) then
      begin
        BringWindowToTop(hwnd); // IE 5.5 related hack
        SetForegroundWindow(hwnd);
        AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
        Result := (GetForegroundWindow = hwnd);
      end;
      if not Result then
      begin
        // Code by Daniel P. Stasinski
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0),
          SPIF_SENDCHANGE);
        BringWindowToTop(hwnd); // IE 5.5 related hack
        SetForegroundWindow(hWnd);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
      end;
    end
    else
    begin
      BringWindowToTop(hwnd); // IE 5.5 related hack
      SetForegroundWindow(hwnd);
    end;

    Result := (GetForegroundWindow = hwnd);
  end;
end; { ForceForegroundWindow }

procedure ProgressbarSetMarqueue(Progressbar: TProgressBar);
begin
  Progressbar.Position := 0;
  SetWindowLong(Progressbar.Handle, GWL_STYLE,
    GetWindowLong(Progressbar.Handle, GWL_STYLE) or PBS_MARQUEE);
  SendMessage(Progressbar.Handle, PBM_SETMARQUEE, 1, 0);
end;

procedure ProgressbarSetNormal(Progressbar: TProgressBar);
begin
  SetWindowLong(Progressbar.Handle, GWL_STYLE,
    GetWindowLong(Progressbar.Handle, GWL_STYLE) and not PBS_MARQUEE);
  SendMessage(Progressbar.Handle, PBM_SETMARQUEE, 0, 0);
end;

procedure SetProgsType(PrgsBar: TProgressBar; Infinity: Boolean);
begin
  if Infinity then
    ProgressbarSetMarqueue(PrgsBar)
  else
    ProgressbarSetNormal(PrgsBar);
end;

function GetFalconDirFromParams: String;
var
  I, FoundIndex: Integer;
begin
  Result := '';
  FoundIndex := -1;
  for I := 1 to ParamCount do
  begin
    if CompareText('--path', ParamStr(I)) = 0 then
    begin
      FoundIndex := I;
      Break;
    end;
  end;
  if FoundIndex < 0 then
    Exit;
  for I := (FoundIndex + 1) to ParamCount do
  begin
    if DirectoryExists(ParamStr(I)) then
    begin
      Result := IncludeTrailingPathDelimiter(ParamStr(I));
      Break;
    end;
  end;
end;

function IsSecureUpdate: Boolean;
begin
  Result := GetFalconDirFromParams <> '';
end;

function GetFalconInstallDir: String;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  if Reg.KeyExists('Software\Falcon') then
  begin
    Reg.OpenKeyReadOnly('Software\Falcon');
    if Reg.ValueExists('') then
      Result := Reg.ReadString('');
    if Result <> '' then
      Result := IncludeTrailingPathDelimiter(Result);
  end
  else if Reg.KeyExists('Software\Microsoft\Windows\CurrentVersion\Uninstall\Falcon') then
  begin
    Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Uninstall\Falcon');
    if Reg.ValueExists('UninstallString') then
      Result := Reg.ReadString('UninstallString');
    Result := ExtractFilePath(Result);
  end;
end;

function GetFalconDir: String;
begin
  Result := GetFalconDirFromParams;
  if DirectoryExists(Result) then
    Exit;
  Result := ExtractFilePath(Application.ExeName);
end;

procedure WriteIniFile(Const Section, Ident, Value: String);
var
  ini:TIniFile;
begin
  ini := TIniFile.Create(ConfigPath + 'Config.ini');
  ini.WriteString(Section, Ident, Value);
  ini.Free;
end;

function ReadIniFile(Section, Ident, Default: String): String;
var
  ini:TIniFile;
begin
  ini := TIniFile.Create(ConfigPath + 'Config.ini');
  Result := ini.ReadString(Section, Ident, Default);
  ini.Free;
end;

function GetLangFileName: String;
var
  I: Integer;
  Files: TStrings;
  ID, UserLangID: Integer;
  LangFileName, AlterConfIni, LangDir, UsersDefDir: String;
  ini: TCustomIniFile;
  Lines: TStrings;
begin
  Result := '';
  ini := TIniFile.Create(ConfigPath + 'Config.ini');
  AlterConfIni := ini.ReadString('EnvironmentOptions', 'ConfigurationFile', '');
  AlterConfIni := ExpandRelativeFileName(AppRoot, AlterConfIni);
  if ini.ReadBool('EnvironmentOptions', 'AlternativeConfFile', False) and
    FileExists(AlterConfIni) then
  begin
    ini.Free;
    ini := TIniFile.Create(AlterConfIni);
  end;
  UserLangID := ini.ReadInteger('EnvironmentOptions', 'LanguageID', GetSystemDefaultLangID);
  UsersDefDir := ini.ReadString('EnvironmentOptions', 'UsersDefDir',
    AppRoot);
  UsersDefDir := ExpandRelativePath(AppRoot, UsersDefDir);
  if not DirectoryExists(UsersDefDir) then
    UsersDefDir := AppRoot;
  LangDir := ini.ReadString('EnvironmentOptions', 'LanguageDir', UsersDefDir + 'Lang\');
  LangDir := ExpandRelativePath(UsersDefDir, LangDir);
  if not DirectoryExists(LangDir) then
    LangDir := UsersDefDir + 'Lang\';
  ini.Free;
  Files := TStringList.Create;
  FindFiles(LangDir + '*.lng', Files);
  Lines := TStringList.Create;
  for I:= 0 to Pred(Files.Count) do
  begin
    LangFileName := LangDir + Files.Strings[I];
    ini := TMemIniFile.Create('');
    try
      LoadFileEx(LangFileName, Lines);
      TMemIniFile(ini).SetStrings(Lines);
    except
    end;
    ID := ini.ReadInteger('FALCON', 'LangID', 0);
    if ID = UserLangID then
    begin
      Result := LangFileName;
      ini.Free;
      Break;
    end;
    ini.Free;
  end;
  Lines.Free;
  Files.Free;
end;

end.
