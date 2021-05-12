unit Main;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, Codebot.System, Codebot.Graphics, Codebot.Graphics.Types,
  Codebot.Controls.Scrolling, Codebot.Controls.Extras,
  Codebot.Controls.Containers, Codebot.Controls.Buttons;

{ TMainForm }

type
  TMainForm = class(TForm)
    BoldButton: TThinButton;
    BitmapButton: TThinButton;
    ItalicButton: TThinButton;
    ImageStrip: TImageStrip;
    DrawList: TDrawList;
    PreviewLabel: TLabel;
    FontsLabel: TLabel;
    RenderBox: TRenderBox;
    SizingPanel: TSizingPanel;
    Timer: TTimer;
    procedure BitmapButtonClick(Sender: TObject);
    procedure DrawListDrawItem(Sender: TObject; Surface: ISurface;
      Index: Integer; Rect: TRectI; State: TDrawState);
    procedure DrawListSelectItem(Sender: TObject);
    procedure FontButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RenderBoxRender(Sender: TObject; Surface: ISurface);
    procedure TimerTimer(Sender: TObject);
  private
    FDpi: Integer;
    FBackground: IBrush;
    FSizeFont: IFont;
    FFontDraw: TFont;
    FFontSelect: TFont;
    FFontNames: StringArray;
    procedure RenderSamples(Surface: ISurface; Rect: TRectI);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  S: string;
begin
  FDpi := Screen.PixelsPerInch;
  FBackground := NewBrush(clWhite);
  FFontDraw := TFont.Create;
  FFontDraw.Assign(Font);
  FFontDraw.Color := clBlack;
  FFontSelect := TFont.Create;
  FFontSelect.Assign(Font);
  FFontSelect.Color := clBlack;
  FFontSelect.Size := 9;
  FSizeFont := NewFont(FFontSelect);
  FFontSelect.Size := 12;
  for S in Screen.Fonts do
    FFontNames.Push(S);
  DrawList.Count := FFontNames.Length;
  ClientWidth := DrawList.Left + DrawList.Width + 8;
  ClientHeight := DrawList.Top + DrawList.Height + 8;
  SizingPanel.Anchors := [akLeft, akTop, akRight, akBottom];
  BoldButton.Anchors := [akTop, akRight];
  ItalicButton.Anchors := [akTop, akRight];
  FontsLabel.Anchors := [akTop, akRight];
  DrawList.Anchors := [akTop, akRight, akBottom];
end;


procedure TMainForm.RenderSamples(Surface: ISurface; Rect: TRectI);
const
  Sample = 'A quick brown fox jumped over the lazy dog';
var
  F: IFont;
  I: Integer;
begin
  Surface.FillRect(FBackground, Rect);
  Rect.Inflate(-4, -4);
  Rect.Right := 10000;;
  FFontDraw.Name := FFontNames[DrawList.ItemIndex];
  if BoldButton.Down then
    FFontDraw.Style := [fsBold]
  else
    FFontDraw.Style := [];
  if ItalicButton.Down then
    FFontDraw.Style := FFontDraw.Style + [fsItalic];
  for I := 8 to 24 do
  begin
    FFontDraw.Height := Round((FDpi / -72) * I);
    F := NewFont(FFontDraw);
    Rect.Height := Round(Surface.TextHeight(F, 'Wg', 100) + 2);
    Rect.Right := 30;
    Surface.TextOut(FSizeFont, IntToStr(I) + 'pt', Rect, drRight);
    Rect.Right := 10000;;
    Rect.Left := Rect.Left + 34;
    Surface.TextOut(F, Sample, Rect, drLeft);
    Rect.Left := Rect.Left - 34;
    Rect.Top := Rect.Bottom;
  end;
end;

procedure TMainForm.RenderBoxRender(Sender: TObject; Surface: ISurface);
var
  Bitmap: IBitmap;
  Rect: TRectI;
begin
  Rect := RenderBox.ClientRect;
  if BitmapButton.Down then
  begin
    Bitmap := NewBitmap(Rect.Width, Rect.Height);
    RenderSamples(Bitmap.Surface, Rect);
    Bitmap.Surface.CopyTo(Rect, Surface, Rect);
  end
  else
  begin
    RenderSamples(Surface, Rect);
  end;
end;

procedure TMainForm.DrawListDrawItem(Sender: TObject; Surface: ISurface;
  Index: Integer; Rect: TRectI; State: TDrawState);
begin
  if dsSelected in State then
    DrawRectState(Surface, Rect, State)
  else
    Surface.FillRect(FBackground, Rect);
  Rect.Inflate(-4, 0);
  FFontSelect.Name := FFontNames[Index];
  Surface.TextOut(NewFont(FFontSelect), FFontNames[Index], Rect, drLeft);
end;

procedure TMainForm.BitmapButtonClick(Sender: TObject);
var
  Button: TThinButton absolute Sender;
begin
  Button.Down := not Button.Down;
  RenderBox.Invalidate;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  RenderBox.Invalidate;
end;

procedure TMainForm.DrawListSelectItem(Sender: TObject);
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TMainForm.FontButtonClick(Sender: TObject);
var
  Button: TThinButton absolute Sender;
begin
  Button.Down := not Button.Down;
  RenderBox.Invalidate;
end;

end.

