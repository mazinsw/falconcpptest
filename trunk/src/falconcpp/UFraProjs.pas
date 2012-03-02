unit UFraProjs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzTabs, StdCtrls, ExtCtrls, ImgList, ComCtrls;

type
  TFraProjs = class(TFrame)
    PanelControls: TPanel;
    GrBoxDesc: TGroupBox;
    PageControl: TRzPageControl;
    ImageList: TImageList;
    MemoDesc: TMemo;
    ImageProj: TImage;
    MemoCap: TMemo;
    Panel1: TPanel;
    LblWidz: TLabel;
    Panel2: TPanel;
    Bevel1: TBevel;
    procedure ProjectListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    function GetListViewOfSheet(SheetCaption: String): TListView;
    procedure PageControlPageChange(Sender: TObject);
    procedure ProjectListDblClick(Sender: TObject);
    procedure ProjectListMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    LastItemIndex: Integer;
  end;

var
  FraProjs: TFraProjs;

implementation

uses UFrmNew, UTemplates, UFileProperty;

{$R *.dfm}

function TFraProjs.GetListViewOfSheet(SheetCaption: String): TListView;
var
  I: Integer;
  NewPage: TProjectsSheet;
begin
  for I:= 0 to Pred(PageControl.PageCount) do
  begin
    if (PageControl.Pages[I].Caption = SheetCaption) then
    begin
      Result := TProjectsSheet(PageControl.Pages[I]).ListView;
      Exit;
    end;
  end;
  NewPage := TProjectsSheet.Create(PageControl);
  NewPage.Caption := SheetCaption;
  NewPage.ListView.LargeImages := ImageList;
  NewPage.ListView.FlatScrollBars := True;
  NewPage.ListView.OnSelectItem := ProjectListSelectItem;
  NewPage.ListView.OnDblClick := ProjectListDblClick;
  NewPage.ListView.OnMouseMove := ProjectListMouseMove;
  NewPage.PageControl := PageControl;
  Result := NewPage.ListView;
end;

procedure TFraProjs.ProjectListSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Assigned(FrmNewProj) then
  begin
    if Assigned(Item) then
    begin
      Item.ListView.Scroll(0, Item.Top - (Item.ListView.Height div 2));
      FrmNewProj.ProjTemp := TTemplate(Item.Data);
      MemoDesc.Text := TTemplate(Item.Data).Description;
      MemoCap.Text := TTemplate(Item.Data).Caption;
      LastItemIndex := Item.Index;
      if Assigned(TTemplate(Item.Data).Icon) then
        ImageProj.Picture.Icon := TTemplate(Item.Data).Icon
      else
        ImageProj.Picture.Icon.LoadFromStream(
          TResourceStream.Create(HInstance, 'ICONFAL', RT_RCDATA));
      FrmNewProj.BtnProx.Enabled := Selected;
      if (FrmNewProj.Page = pwProj) then
        FrmNewProj.BtnFnsh.Enabled := Selected;
    end;
  end;
end;

procedure TFraProjs.PageControlPageChange(Sender: TObject);
var
  Tmplt: TTemplate;
  ListV: TListView;
begin
  if Assigned(FrmNewProj) and Assigned(PageControl.ActivePage) then
  begin
    ListV := TProjectsSheet(PageControl.ActivePage).ListView;
    if not (ListV.SelCount > 0) then
    begin
      ImageProj.Picture := nil;
      LastItemIndex := -1;
      MemoCap.Clear;
      MemoDesc.Clear;
    end
    else
    begin
      Tmplt := TTemplate(ListV.Selected.Data);
      MemoCap.Text := Tmplt.Caption;
      MemoDesc.Text := Tmplt.Description;
      LastItemIndex := ListV.Selected.Index;
      if Assigned(Tmplt.Icon) then
        ImageProj.Picture.Icon := Tmplt.Icon
      else
        ImageProj.Picture.Icon.LoadFromStream(
          TResourceStream.Create(HInstance, 'ICONFAL', RT_RCDATA));
    end;
    FrmNewProj.BtnProx.Enabled := (ListV.SelCount > 0);
    FrmNewProj.BtnFnsh.Enabled := (ListV.SelCount > 0);
  end;
end;

procedure TFraProjs.ProjectListDblClick(Sender: TObject);
var
  Item: TListItem;
  MPos: TPoint;
begin
  GetCursorPos(MPos);
  MPos := TListView(Sender).ScreenToClient(MPos);
  Item := TListView(Sender).GetItemAt(MPos.X, MPos.Y);
  if Assigned(Item) then
  begin
    FrmNewProj.ProjTemp := TTemplate(Item.Data);
    FrmNewProj.BtnFnsh.Click;
  end;
end;

procedure TFraProjs.ProjectListMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
  Tmplt: TTemplate;
  ListV: TListView;
begin
  if not Assigned(Sender) then Exit;
  if (Sender is TListView) then
    Item := TListView(Sender).GetItemAt(X, Y)
  else
    Item := nil;
  if Assigned(Item) then
  begin
    if (LastItemIndex <> Item.Index) then
    begin
      Tmplt := TTemplate(Item.Data);
      MemoCap.Text := Tmplt.Caption;
      MemoDesc.Text := Tmplt.Description;
      LastItemIndex := Item.Index;
      if Assigned(Tmplt.Icon) then
        ImageProj.Picture.Icon := Tmplt.Icon
      else
        ImageProj.Picture.Icon.LoadFromStream(
          TResourceStream.Create(HInstance, 'ICONFAL', RT_RCDATA));
    end;
  end
  else
  begin
    if (Sender is TListView) then
    begin
      ListV := TListView(Sender);
      if not (ListV.SelCount > 0) then
      begin
        ImageProj.Picture := nil;
        LastItemIndex := -1;
        MemoCap.Clear;
        MemoDesc.Clear;
      end
      else
      begin
        if (LastItemIndex <> ListV.Selected.Index) then
        begin
          Tmplt := TTemplate(ListV.Selected.Data);
          MemoCap.Text := Tmplt.Caption;
          MemoDesc.Text := Tmplt.Description;
          LastItemIndex := ListV.Selected.Index;
          if Assigned(Tmplt.Icon) then
            ImageProj.Picture.Icon := Tmplt.Icon
          else
            ImageProj.Picture.Icon.LoadFromStream(
               TResourceStream.Create(HInstance, 'ICONFAL', RT_RCDATA));
        end;
      end;
    end
    else
    begin
      if not Assigned(PageControl.ActivePage) then Exit;
      ListV := TProjectsSheet(PageControl.ActivePage).ListView;
      if not (ListV.SelCount > 0) then
      begin
        ImageProj.Picture := nil;
        LastItemIndex := -1;
        MemoCap.Clear;
        MemoDesc.Clear;
      end
      else
        if (LastItemIndex <> ListV.Selected.Index) then
        begin
          Tmplt := TTemplate(ListV.Selected.Data);
          MemoCap.Text := Tmplt.Caption;
          MemoDesc.Text := Tmplt.Description;
          LastItemIndex := ListV.Selected.Index;
          if Assigned(Tmplt.Icon) then
            ImageProj.Picture.Icon := Tmplt.Icon
          else
            ImageProj.Picture.Icon.LoadFromStream(
              TResourceStream.Create(HInstance, 'ICONFAL', RT_RCDATA));
        end;
    end;
  end;
end;

end.