unit Breakpoint;

interface

uses
  Windows, Controls, Classes, SysUtils, SynEditEx;

type
  TBreakpoint = class
  private
    FIndex: Integer;
    FLine: Integer;
    FValid: Boolean;
    FEnable: Boolean;
    FFileName: string;
  public
    constructor Create;
    procedure Assign(Value: TBreakpoint);
    property Index: Integer read FIndex write FIndex;
    property Line: Integer read FLine write FLine;
    property Valid: Boolean read FValid write FValid;
    property Enable: Boolean read FEnable write FEnable;
    property FileName: string read FFileName write FFileName;
  end;

  TBreakpointList = class
  private
    FList: TList;
    FImageList: TImageList;
    FImageIndex: Integer;
    FInvalidIndex: Integer;
    function GetBreakpointIndex(Line: Integer): Integer;
    procedure SetImageList(Value: TImageList);
    procedure SetImageIndex(Value: Integer);
    function Get(Index: Integer): TBreakpoint;
    function GetCount: Integer;
    function GetInsertIndex(Line: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Value: TBreakpointList);
    function MoveBy(LineFrom, aCount: Integer): Integer;
    function HasBreakpoint(Line: Integer): Boolean;
    procedure DrawBreakpoint(Editor: TSynEditEx; Line, X, Y: Integer);
    function ToogleBreakpoint(Line: Integer): Boolean;
    function GetBreakpoint(Line: Integer): TBreakpoint;
    property Count: Integer read GetCount;
    property Items[Index: integer]: TBreakpoint read Get;
    property ImageList: TImageList read FImageList write SetImageList;
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property InvalidIndex: Integer read FInvalidIndex write FInvalidIndex;
  end;

implementation

{TBreakpoint}

procedure TBreakpoint.Assign(Value: TBreakpoint);
begin
  FIndex := Value.FIndex;
  FLine := Value.FLine;
  FValid := Value.FValid;
  FEnable := Value.FEnable;
  FFileName := Value.FFileName;
end;

constructor TBreakpoint.Create;
begin
  inherited Create;
  FLine := 0;
  FValid := True;
  FEnable := True;
end;

{TBreakpointList}

function TBreakpointList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TBreakpointList.Get(Index: Integer): TBreakpoint;
begin
  Result := TBreakpoint(FList.Items[Index]);
end;

function TBreakpointList.GetInsertIndex(Line: Integer): Integer;
var
  I, J: Integer;
  Breakpoint: TBreakpoint;
begin
  I := 0;
  Result := 0;
  J := FList.Count - 1;
  // binary search
  while I <= J do
  begin
    Result := (I + J) div 2;
    Breakpoint := TBreakpoint(FList.Items[Result]);
    if Line > Breakpoint.Line then
    begin
      I := Result + 1;
      Inc(Result);
    end
    else if Line < Breakpoint.Line then
    begin
      J := Result - 1;
      if I <= J then
        Dec(Result);
    end
    else
      Exit;
  end;
  if Result < 0 then
    Result := 0;
end;

function TBreakpointList.GetBreakpointIndex(Line: Integer): Integer;
var
  I: Integer;
  Breakpoint: TBreakpoint;
begin
  Result := -1;
  I := GetInsertIndex(Line);
  if I >= FList.Count then
    Exit;
  Breakpoint := TBreakpoint(FList.Items[I]);
  if Breakpoint.Line = Line then
    Result := I;
end;

procedure TBreakpointList.SetImageList(Value: TImageList);
begin
  if Value <> FImageList then
  begin
    FImageList := Value;
  end;
end;

procedure TBreakpointList.SetImageIndex(Value: Integer);
begin
  if Value <> FImageIndex then
  begin
    FImageIndex := Value;
    if FInvalidIndex = -1 then
      FInvalidIndex := FImageIndex + 1;
  end;
end;

constructor TBreakpointList.Create;
begin
  inherited Create;
  FList := TList.Create;
  FImageIndex := -1;
  FInvalidIndex := -1;
end;

destructor TBreakpointList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TBreakpointList.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TBreakpoint(FList.Items[I]).Free;
  FList.Clear;
end;

function TBreakpointList.HasBreakpoint(Line: Integer): Boolean;
begin
  Result := GetBreakpointIndex(Line) <> -1;
end;

procedure TBreakpointList.DrawBreakpoint(Editor: TSynEditEx; Line, X, Y: Integer);
var
  Breakpoint: TBreakpoint;
  Index, DrawIndex: Integer;
begin
  Index := GetBreakpointIndex(Line);
  if Index < 0 then
    Exit;
  Breakpoint := TBreakpoint(FList.Items[Index]);
  if not Assigned(FImageList) or not Assigned(Editor) then
    Exit;
  DrawIndex := FImageIndex;
  if not Breakpoint.Valid then
    DrawIndex := FInvalidIndex;
  FImageList.Draw(Editor.Canvas, X, Y, DrawIndex, Breakpoint.Enable);
end;

function TBreakpointList.ToogleBreakpoint(Line: Integer): Boolean;
var
  I: Integer;
  Breakpoint: TBreakpoint;
begin
  I := GetInsertIndex(Line);
  if (I < FList.Count) and (Items[I].Line = Line) then
  begin
    Items[I].Free;
    FList.Delete(I);
    Result := False;
    Exit;
  end;
  Breakpoint := TBreakpoint.Create;
  Breakpoint.Line := Line;
  FList.Insert(I, Breakpoint);
  Result := True;
end;

function TBreakpointList.GetBreakpoint(Line: Integer): TBreakpoint;
var
  Index: Integer;
begin
  Index := GetBreakpointIndex(Line);
  if Index < 0 then
  begin
    Result := nil;
    Exit;
  end;
  Result := TBreakpoint(FList.Items[Index]);
end;

procedure TBreakpointList.Assign(Value: TBreakpointList);
var
  I: Integer;
  bp: TBreakpoint;
begin
  FImageList := Value.FImageList;
  FImageIndex := Value.FImageIndex;
  FInvalidIndex := Value.FInvalidIndex;
  Clear;
  for I := 0 to Value.Count - 1 do
  begin
    bp := TBreakpoint.Create;
    bp.Assign(Value.Items[I]);
    FList.Add(bp);
  end;
end;

function TBreakpointList.MoveBy(LineFrom, aCount: Integer): Integer;
var
  I: Integer;
  Breakpoint: TBreakpoint;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
  begin
    Breakpoint := TBreakpoint(FList.Items[I]);
    if Breakpoint.Line < LineFrom then
      Continue;
    Breakpoint.Line := Breakpoint.Line + aCount;
    Inc(Result);
  end;
end;

end.
