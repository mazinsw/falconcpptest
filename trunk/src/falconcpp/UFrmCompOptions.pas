unit UFrmCompOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls;

type
  TFrmCompOptions = class(TForm)
    PageControl1: TPageControl;
    BtnOk: TButton;
    BtnCancel: TButton;
    BtnApply: TButton;
    TSCompiler: TTabSheet;
    TSDirectories: TTabSheet;
    TSPrograms: TTabSheet;
    TSDebugger: TTabSheet;
    ComboBoxCompilerConfig: TComboBoxEx;
    LabelLang: TLabel;
    BtnSave: TSpeedButton;
    BtnDel: TSpeedButton;
    PageControl2: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    LabelUserDefDir: TLabel;
    BtnChooseCompilerPath: TSpeedButton;
    ComboBoxCompilerPath: TComboBox;
    ListView1: TListView;
    GroupBox1: TGroupBox;
    LabelCompilerVersion: TLabel;
    LabelCompilerName: TLabel;
    LabelMakeVersion: TLabel;
    TabSheet3: TTabSheet;
    ListView2: TListView;
    LabelCompilerStatus: TLabel;
    Bevel2: TBevel;
    LabelMakeStatus: TLabel;
    GroupBox2: TGroupBox;
    LabelDebugName: TLabel;
    LabelDebugVersion: TLabel;
    LabelDebugStatus: TLabel;
    LabelMakeName: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxCompilerPathSelect(Sender: TObject);
  private
    { Private declarations }
    Loading: Boolean;
    procedure OptionsChange;
  public
    { Public declarations }
    procedure UpdateLangNow;
    procedure Load;
    procedure CheckCompiler;
    procedure FillCompilerList;
  end;

var
  FrmCompOptions: TFrmCompOptions;

implementation

uses UFrmMain, ULanguages, ExecWait, UUtils, UConfig;

{$R *.dfm}

procedure TFrmCompOptions.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) then
  begin
    Key := #0;
    Close;
  end;
end;

procedure TFrmCompOptions.OptionsChange;
begin
  if Loading then Exit;
  BtnApply.Enabled := True;
end;

procedure TFrmCompOptions.Load;
begin
//  
end;

procedure TFrmCompOptions.UpdateLangNow;
begin
//
end;

procedure TFrmCompOptions.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmCompOptions.FormDestroy(Sender: TObject);
begin
  FrmCompOptions := nil;
end;

procedure TFrmCompOptions.BtnOkClick(Sender: TObject);
begin
  if BtnApply.Enabled then
    BtnApply.Click;
  Close;
end;

procedure TFrmCompOptions.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCompOptions.BtnApplyClick(Sender: TObject);
var
  newPath: String;
  Index: Integer;
  NeedRestartApp: Boolean;
begin
  BtnApply.Enabled := False;
  with FrmFalconMain.Config.Compiler do
  begin
    NeedRestartApp := False;
    Index := ComboBoxCompilerPath.ItemIndex;
    if Index >= 0 then
    begin
      newPath := ComboBoxCompilerPath.Items.Strings[Index];
      newPath := ExcludeTrailingPathDelimiter(newPath);
      if (CompareText(newPath, Path) <> 0) and
        FileExists(newPath + '\bin\gcc.exe') then
      begin
        Path := newPath;
        if (ExecutorGetStdOut.ExecWait(Path +
          '\bin\gcc.exe', '--version', Path + '\bin\',
          newPath) = 0) then
        begin
          GetNameAndVersion(newPath, newPath, Version);
          WriteIniFile('Packages', 'NewInstalled', '-1');
        end;
        NeedRestartApp := True;
      end;
    end;
    if NeedRestartApp then
      MessageBox(Handle, PChar(STR_FRM_ENV_OPT[35]), 'Falcon C++',
        MB_ICONINFORMATION);
  end;
end;

procedure TFrmCompOptions.CheckCompiler;
var
  exitCode: Integer;
  stdout, path, aName, aVersion: String;
begin
  if ComboBoxCompilerPath.ItemIndex < 0 then
    Exit;
  path := ComboBoxCompilerPath.Items.Strings[ComboBoxCompilerPath.ItemIndex];
  path := IncludeTrailingPathDelimiter(path);
  exitCode := ExecutorGetStdOut.ExecWait(path + 'bin\gcc.exe', '--version',
    path + 'bin\', stdout);
  if exitCode = 0 then
  begin
    GetNameAndVersion(stdout, aName, aVersion);
    LabelCompilerName.Caption := aName;
    LabelCompilerVersion.Caption := aVersion;
    LabelCompilerStatus.Caption := 'Working';
    LabelCompilerStatus.Font.Color := clGreen;
  end
  else
  begin
    LabelCompilerName.Caption := '-';
    LabelCompilerVersion.Caption := '-';
    LabelCompilerStatus.Caption := 'Error';
    LabelCompilerStatus.Font.Color := clRed;
  end;
  exitCode := ExecutorGetStdOut.ExecWait(path + '\bin\gdb.exe', '--version',
    path + '\bin\', stdout);
  if exitCode = 0 then
  begin
    GetNameAndVersion(stdout, aName, aVersion);
    LabelDebugName.Caption := aName;
    LabelDebugVersion.Caption := aVersion;
    LabelDebugStatus.Caption := 'Working';
    LabelDebugStatus.Font.Color := clGreen;
  end
  else
  begin
    LabelDebugName.Caption := '-';
    LabelDebugVersion.Caption := '-';
    LabelDebugStatus.Caption := 'Error';
    LabelDebugStatus.Font.Color := clRed;
  end;
  exitCode := ExecutorGetStdOut.ExecWait(path + '\bin\mingw32-make.exe',
    '--version', path + '\bin\', stdout);
  if exitCode = 0 then
  begin
    GetNameAndVersion(stdout, aName, aVersion);
    LabelMakeName.Caption := aName;
    LabelMakeVersion.Caption := aVersion;
    LabelMakeStatus.Caption := 'Working';
    LabelMakeStatus.Font.Color := clGreen;
  end
  else
  begin
    LabelMakeName.Caption := '-';
    LabelMakeVersion.Caption := '-';
    LabelMakeStatus.Caption := 'Error';
    LabelMakeStatus.Font.Color := clRed;
  end;
end;

procedure TFrmCompOptions.FillCompilerList;
var
  path: String;
begin
  ComboBoxCompilerPath.Clear;
  //find compilers
  SearchCompilers(ComboBoxCompilerPath.Items, path);
  ComboBoxCompilerPath.ItemIndex :=
    ComboBoxCompilerPath.Items.IndexOf(FrmFalconMain.Config.Compiler.Path);
end;

procedure TFrmCompOptions.FormCreate(Sender: TObject);
begin
  FillCompilerList;
  CheckCompiler;
end;

procedure TFrmCompOptions.ComboBoxCompilerPathSelect(Sender: TObject);
begin
  OptionsChange;
  CheckCompiler;
end;

end.