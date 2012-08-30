unit UFrmWizard;

interface

uses
    Windows, Messages, StdCtrls, ExtCtrls, RichEditViewer, Classes, SysUtils,
    Controls, Forms, UInstaller, LoadImage;

const
  WM_UPDATESTEP = WM_USER + $0110;

type
  TPageWizard = (pwProj, pwOpt);
  TFrmWizard = class(TForm)
    PanelFra: TPanel;
    PainelBtns: TPanel;
    BtnNext: TButton;
    BtnCan: TButton;
    BtnBack: TButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnCanClick(Sender: TObject);
    procedure BtnBackClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    Step: Byte;
    Prompt, Done: Boolean;
    StepCtrl: array[0..6] of Byte;
  end;

var
  FrmWizard: TFrmWizard;
  Installer: TInstaller;

function MyExitWindows(RebootParam: Longword): Boolean;

implementation

uses UFraWelcome, UFraSteps, UFraAgrmt, UFraFnsh, UFraDesc, UFraPrgs,
  UFraReadMe;

{$R *.dfm}
{$R resources.RES}

procedure TFrmWizard.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) and (StepCtrl[Step] < 4) then
  begin
    Key := #0;
    Close;
  end;
end;

procedure TFrmWizard.FormCreate(Sender: TObject);
var
  I: Integer;
  Lsc: String;
  Rs: TResourceStream;
  Ms: TMemoryStream;
begin
  Ms := TMemoryStream.Create;
  Caption := Format('%s Installation', [Installer.Name]);
  Done := False; 
  for I:= 0 to 6 do StepCtrl[I] := I;
  Screen.Cursors[crHandPoint] := LoadCursor(0, IDC_HAND);
  Prompt := True;
  FraWelc := TFraWelc.Create(Self);
  FraWelc.LblMsg.Caption :=
    Format('Welcome to the %s Package Installation Wizard', [Installer.Name]);
  FraWelc.TextHelp.Caption :=
    Format('This wizard will guide you through the instalation of %s.',
    [Installer.Name]);
  FraSteps := TFraSteps.Create(Self);
  if Installer.TarFileExist(Installer.Picture, Ms) then
  begin
    LoadImageFromStream(FraSteps.PkgImage.Picture, Ms);
    Ms.Clear;
  end;

  if Installer.TarFileExist(Installer.Logo, Ms) then
  begin
    LoadImageFromStream(FraWelc.ImageLogo.Picture, Ms);
    Ms.Clear;
  end;

  I := 1;
  FraReadMe := TFraReadMe.Create(Self);
  if Installer.TarFileExist(Installer.Readme, Ms) then
  begin
    Ms.Position := 0;
    FraReadMe.TextReadMe.Lines.LoadFromStream(Ms);
    StepCtrl[I] := 1;
    Inc(I);
    Ms.Clear;
  end;
  
  FraAgrmt := TFraAgrmt.Create(Self);
  if (Length(Trim(Installer.License)) > 0) then
  begin
    Lsc := UpperCase(Installer.License);
    if (Pos('USE{', Lsc) > 0) then
    begin
      Lsc := Copy(Lsc, 5, Length(Lsc) - 5);
      Rs := TResourceStream.Create(HInstance, Lsc, RT_RCDATA);
      Rs.Position := 0;
      FraAgrmt.TextLicense.Lines.LoadFromStream(Rs);
      Rs.Free;
      StepCtrl[I] := 2;
      Inc(I);
    end
    else
      if Installer.TarFileExist(Installer.License, Ms) then
      begin
        Ms.Position := 0;
        FraAgrmt.TextLicense.Lines.LoadFromStream(Ms);
        StepCtrl[I] := 2;
        Inc(I);
        Ms.Clear;
      end;
  end;
  FraAgrmt.TextAnswer.Caption :=
    Format('If you accept the terms of the agreement, click I Agree to conti' +
    'nue. You must accept the agreement to install %s.',
    [Installer.Name]);
  FraDesc := TFraDesc.Create(Self);
  StepCtrl[I] := 3;
  Inc(I);
  FraDesc.Init;
  FraPrgs := TFraPrgs.Create(Self);
  StepCtrl[I] := 4;
  Inc(I);
  FraFnsh := TFraFnsh.Create(Self);
  FraFnsh.ChbShow.Checked := Installer.ShowPkgManager;
  Prompt := Installer.AbortAlert;
  StepCtrl[I] := 5;
  Inc(I);

  if (Pos('Use{Logo}', Installer.EndLogo) > 0) or
     (Length(Trim(Installer.EndLogo)) = 0) then
    FraFnsh.Imagem.Picture := FraWelc.ImageLogo.Picture
  else if Installer.TarFileExist(Installer.EndLogo, Ms) then
  begin
    LoadImageFromStream(FraFnsh.Imagem.Picture, Ms);
    Ms.Clear;
  end
  else
    FraFnsh.Imagem.Picture := FraWelc.ImageLogo.Picture;

  FraWelc.Parent := PanelFra;
  //done
  StepCtrl[I] := 6;
  Step := 0;
  Ms.Free;
end;

procedure SetFrameParent(Next: TFrame; Panel: TPanel);
var
  I: Integer;
begin
  SendMessage(Next.Handle, WM_UPDATESTEP, 0, 0);
  Next.Parent := Panel;
  for I:= Pred(Panel.ControlCount) downto 0 do
    if (Panel.Controls[I] <> Next) then
      Panel.Controls[I].Parent := nil;
end;

procedure TFrmWizard.BtnNextClick(Sender: TObject);
var
  I: Integer;
begin
  Inc(Step);
  case StepCtrl[Step] of
    1: //*********** README Text *************//
    begin
      SetFrameParent(FraReadMe, FraSteps.PanelStep);
      SetFrameParent(FraSteps, PanelFra);
      BtnNext.Caption := 'Next >';
      BtnBack.Show;
    end;
    2: //*********** Licence Agreement *************//
    begin
      SetFrameParent(FraAgrmt, FraSteps.PanelStep);
      SetFrameParent(FraSteps, PanelFra);
      BtnNext.Caption := 'I &Agree';
      BtnBack.Show;
    end;
    3: //*********** Description *************//
    begin
      SetFrameParent(FraDesc, FraSteps.PanelStep);
      SetFrameParent(FraSteps, PanelFra);
      BtnNext.Caption := 'Install';
      BtnBack.Show;
    end;
    4: //*********** Progress *************//
    begin
      Prompt := False;
      SetFrameParent(FraPrgs, FraSteps.PanelStep);
      EnableMenuItem(GetSystemMenu(Handle, False),
        SC_CLOSE, MF_DISABLED);
      BtnNext.Caption := 'Next >';
      BtnBack.Show;
      BtnBack.Enabled := False;
      BtnNext.Enabled := False;
      BtnCan.Enabled := False;
      Installer.Install(FraPrgs.Progress);
    end;
    5: //*********** Finish *************//
    begin
      SetFrameParent(FraFnsh, PanelFra);
      BtnNext.Enabled := True;
      BtnNext.SetFocus;
      BtnNext.Caption := 'Finish';
      BtnBack.Show;
      if FindWindow('TFrmPkgMan', nil) <> 0 then
        FraFnsh.ChbShow.Checked := False;
    end;
    6:
    begin
      Done := True;
      if Installer.Reboot then
      begin
        I := MessageBox(Handle, 'Want to restart the system?',
               'Falcon C++ Installation Wizard',
               MB_ICONWARNING+MB_YESNOCANCEL+MB_DEFBUTTON2);
        if I = IDYES then
          MyExitWindows(EWX_REBOOT)
        else if FraFnsh.ChbShow.Checked then
          Execute(Application.ExeName);
      end
      else if FraFnsh.ChbShow.Checked then
        Execute(Application.ExeName);
      Close;
    end;
  end;
end;

procedure TFrmWizard.BtnCanClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmWizard.BtnBackClick(Sender: TObject);
begin
  Dec(Step);
  case StepCtrl[Step] of
    0: //*********** Welcome *************//
    begin
      SetFrameParent(FraWelc, PanelFra);
      BtnNext.Caption := 'Next >';
      BtnBack.Hide;
    end;
    1: //*********** README *************//
    begin
      SetFrameParent(FraReadMe, FraSteps.PanelStep);
      BtnNext.Caption := 'Next >';
    end;
    2: //*********** Agreement *************//
    begin
      SetFrameParent(FraAgrmt, FraSteps.PanelStep);
      BtnNext.Caption := 'I &Agree';
    end;
  end;
end;

procedure TFrmWizard.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Res: Integer;
begin
  if Prompt then
  begin
    Res := MessageBox(Handle, Pchar(
      Format('Are you sure you want to quit %s Installation?', [Installer.Name])),
             PChar(Caption), MB_ICONEXCLAMATION + MB_YESNO);
    if (Res = mrNo) then Action := caNone;
  end;
  if not (Action = caNone) and not Done then
    Installer.Clear;
end;

function MyExitWindows(RebootParam: Longword): Boolean;
var
	TTokenHd: THandle;
	TTokenPvg: TTokenPrivileges;
	cbtpPrevious: DWORD;
	rTTokenPvg: TTokenPrivileges;
	pcbtpPreviousRequired: DWORD;
	tpResult: Boolean;
const
	SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
	if Win32Platform = VER_PLATFORM_WIN32_NT then
	begin
		tpResult := OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TTokenHd);
		if tpResult then
		begin
			tpResult := LookupPrivilegeValue(nil, SE_SHUTDOWN_NAME, TTokenPvg.Privileges[0].Luid);
			TTokenPvg.PrivilegeCount := 1;
			TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
			cbtpPrevious := SizeOf(rTTokenPvg);
			pcbtpPreviousRequired := 0;
			if tpResult then
				Windows.AdjustTokenPrivileges(TTokenHd, False, TTokenPvg, cbtpPrevious, rTTokenPvg, pcbtpPreviousRequired);
		end;
	end;
	Result := ExitWindowsEx(RebootParam, 0);
end;

end.