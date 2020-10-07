unit wincon;

{$mode delphi}

interface

uses sysutils;

type

  EConsoleException = class(Exception);

  TCellLocation = record
    Column: Integer;
    Row: Integer;
  end;

  TColorPaletteIndex = 0..$f;

  TCellColorAttribute = record
    public
      Foreground: TColorPaletteIndex;
      Background: TColorPaletteIndex;
  end;

  TCellColorAttributes = array of TCellColorAttribute;

  TCharacterCell = record
    Character: WideChar;
    Colors: TCellColorAttribute;
  end;

  TCharacterCells = array of TCharacterCell;

  TCursorSize = 1..100;

  TCursor = record
    private
      FSize: TCursorSize;
      FVisible: Boolean;
      function GetLocation: TCellLocation;
      procedure SetLocation(Value: TCellLocation);
      function GetSize: TCursorSize;
      procedure SetSize(Value: TCursorSize);
      function GetVisible: Boolean;
      procedure SetVisible(Value: Boolean);

      procedure GetCursorInfo;
      procedure SetCursorInfo;

    public
      Handle: THandle;
      property Location: TCellLocation read GetLocation write SetLocation;
      property Size: TCursorSize read GetSize write SetSize;
      property Visible: Boolean read GetVisible write SetVisible;
  end;

  TAreaSize = record
    Height: Integer;
    Width: Integer;
  end;

  TArea = record
    public
      Location: TCellLocation;
      Size: TAreaSize;
  end;

  TColor = packed record
    R: Byte;
    G: Byte;
    B: Byte;
    X: Byte;
  end;

  TColorPalette = array [0..$f] of TColor;

  TFont = record
    Size: TAreaSize;
    FaceName: WideString;
  end;

  TScreenBuffer = record
    private
      FCursor: TCursor;
      FViewport: TArea;
      FFont: TFont;
      FTextColors: TCellColorAttribute;
      FSize: TAreaSize;

      FColorPalette: TColorPalette;

      function GetColorPalette(Index: TColorPaletteIndex): TColor;
      procedure SetColorPalette(Index: TColorPaletteIndex; aColor: TColor);

      function GetForeground: TColorPaletteIndex;
      procedure SetForeground(Value: TColorPaletteIndex);
      function GetBackground: TColorPaletteIndex;
      procedure SetBackground(Value: TColorPaletteIndex);
      function GetSize: TAreaSize;
      function GetCursor: TCursor;
      function GetVTP: Boolean;
      procedure SetVTP(Value: Boolean);

      function GetFont: TFont;
      procedure SetFont(Value: TFont);
    public
      Handle: THandle;

      property Size: TAreaSize read GetSize;

      property Cursor: TCursor read GetCursor;

      property ColorPalette[Index: TColorPaletteIndex]: TColor read GetColorPalette write SetColorPalette;

      property Foreground: TColorPaletteIndex read GetForeground write SetForeground;
      property Background: TColorPaletteIndex read GetBackground write SetBackground;

      property Font: TFont read GetFont write SetFont;

      procedure GetInfo;
      procedure SetInfo;

      property VirtualTerminalProcessing: Boolean read GetVTP write SetVTP;

      function GetCharactersAt(aLocation: TCellLocation; Count: Integer = 1): WideString;
      procedure SetCharactersAt(Characters: WideString; aLocation: TCellLocation; Count: Integer = -1);

      function GetAttributesAt(aLocation: TCellLocation; Count: Integer = 1): TCellColorAttributes;
      procedure SetAttributesAt(Attributes: TCellColorAttributes; aLocation: TCellLocation; Count: Integer = -1);

      procedure SetAttributeAt(Attribute: TCellColorAttribute; aLocation: TCellLocation; Count: Integer = 1);
      procedure SetCharacterAt(Character: WideChar; aLocation: TCellLocation; Count: Integer = 1);

      procedure CopyAreaTo(Area: TArea; aBuffer: TScreenBuffer; aLocation: TCellLocation);
      procedure ScrollArea(ScrollArea: TArea; aLocation: TCellLocation; ClippingArea: TArea; Filler: TCharacterCell);

      procedure Write(Characters: WideString);
  end;

  TScreenBuffers = record
    private
      FBuffers: array of TScreenBuffer;
      FBufferNames: array of String;

      function GetBuffer(aName: String): TScreenBuffer;
      function GetCount: Integer;

    public
      procedure Add(aName: String);
      procedure AddUsingHandle(aName: String; aHandle: THandle);

      property Buffers[aName: String]: TScreenBuffer read GetBuffer; default;
      property Count: Integer read GetCount;
  end;

  TInputEventType = (ietNone, ietSelection, ietMouse, ietKey, ietWindow);

  TMouseEventType = (metNone, metMouseMoved, metButtonState, metSecondClick, metWheelState);

  TInputActivationState = (iasNone, iasPressed, iasReleased);

  TResizeEventType = (retNone, retResize);

  TMouseButton = (cmbRight, cmbLeft1, cmbLeft2, cmbLeft3, cmbLeft4);
  TMouseButtons = set of TMouseButton;

  TMouseWheelDirection = (wdNone, wdForward, wdBackward, wdLeft, wdRight);

  TControlKeys = record
    private
      function GetCtrl: Boolean;
      function GetAlt: Boolean;
    public
      CapsLock: Boolean;
      ScrollLock: Boolean;
      NumLock: Boolean;

      Enhanced: Boolean;

      LeftAlt: Boolean;
      RightAlt: Boolean;
      LeftCtrl: Boolean;
      RightCtrl: Boolean;
      LeftShift: Boolean;
      RightShift: Boolean;

      Shift: Boolean;
      property Ctrl: Boolean read GetCtrl;
      property Alt: Boolean read GetAlt;
  end;

  TMouseEvent = record
    EventType: TMouseEventType;
    Location: TCellLocation;
    ButtonState: TInputActivationState;
    ClickedButtons: TMouseButtons;
    ControlKeys: TControlKeys;
    WheelDirection: TMouseWheelDirection;
    WheelState: TInputActivationState;
    WheelDistance: SmallInt;
  end;

  TVolumeKey = (cvkNone, cvkMute, cvkDown, cvkUp);
  TMediaKey = (cmkNone, cmkNext, cmkPrev, cmkStop, cmkPlayPause);
  TKeySide = (cksNone, cksLeft, cksRight);

  TKeyEvent = record
    EventType: TInputActivationState;
    Repetitions: Integer;
    KeyCode: Integer;
    ScanCode: Integer;
    Char: WideChar;
    ControlKeys: TControlKeys;
    VolumeKey: TVolumeKey;
    MediaKey: TMediaKey;
    WindowsKey: TKeySide;
    MenuKey: TKeySide;
  end;

  TResizeEvent = record
    EventType: TResizeEventType;
    NewSize: TAreaSize;
  end;

  TSelection = record
    MousePressed: Boolean;
    Selecting: Boolean;
    Selected: Boolean;
    InProgress: Boolean;
    Empty: Boolean;
    Area: TArea;
    Anchor: TCellLocation;
  end;

  TConsoleInput = record
    private
      function GetNextEventType: TInputEventType;
      function GetNextMouseEventType: TMouseEventType;
      function GetNextKeyEventType: TInputActivationState;
    public
      Handle: THandle;

      property NextEventType: TInputEventType read GetNextEventType;
      property NextMouseEventType: TMouseEventType read GetNextMouseEventType;
      property NextKeyEventType: TInputActivationState read GetNextKeyEventType;

      function ConsumeMouseEvent: TMouseEvent;
      function ConsumeKeyEvent: TKeyEvent;
      function ConsumeResizeEvent: TResizeEvent;

      function WaitForEvent(Millis: Integer): TInputEventType;
      procedure DiscardEvents;
  end;

  TConsole = record
    private
      FBuffers: TScreenBuffers;
      FInput: TConsoleInput;
      function GetBuffer(BufferName: WideString): TScreenBuffer;
      function GetTitle: WideString;
      procedure SetTitle(Value: WideString);
      function GetInputCodePage: LongWord;
      procedure SetInputCodePage(Value: LongWord);
      function GetOutputCodePage: LongWord;
      procedure SetOutputCodePage(Value: LongWord);

      procedure Init;
      procedure Done;

    public
      property Buffers[BufferName: WideString]: TScreenBuffer read GetBuffer;

      procedure AddBuffer(aName: WideString);
      procedure SetActiveBuffer(Value: WideString);

      property Title: WideString read GetTitle write SetTitle;

      property Input: TConsoleInput read FInput;

      property InputCodePage: LongWord read GetInputCodePage write SetInputCodePage;
      property OutputCodePage: LongWord read GetOutputCodePage write SetOutputCodePage;
  end;

var

  StdInputHandle: THandle;
  StdOutputHandle: THandle;

  Console: TConsole;

function Location(aX, aY: Integer): TCellLocation;
function Size(aHeight, aWidth: Integer): TAreaSize;
function Font(aFaceName: WideString; aHeight: Integer; aWidth: Integer = 0): TFont;
function Color(aR, aG, aB: Byte): TColor;

implementation

uses windows, strutils;

type

  TWords = array of Word;

{TColor}

function Color(aR, aG, aB: Byte): TColor;
begin

  with Result do begin
    R := aR;
    G := aG;
    B := aB;
  end;
end;

{TCellLocation}

function Location(aX, aY: Integer): TCellLocation;
begin
  with Result do begin
    Column := aX;
    Row := aY;
  end;
end;

{TSize}

function Size(aHeight, aWidth: Integer): TAreaSize;
begin
  with Result do begin
    Height := aHeight;
    Width := aWidth;
  end;
end;

{TFont}

function Font(aFaceName: WideString; aHeight: Integer; aWidth: Integer = 0): TFont;
begin
  Result.FaceName := aFaceName;
  Result.Size := Size(aHeight, aWidth);
end;

{TCursor}

procedure TCursor.GetCursorInfo;
var
  info: CONSOLE_CURSOR_INFO;
begin
  GetConsoleCursorInfo(Handle, info);
  with info do begin
    FSize := dwSize;
    FVisible := bVisible;
  end;
end;

procedure TCursor.SetCursorInfo;
var
  info: CONSOLE_CURSOR_INFO;
begin
  with info do begin
    dwSize := FSize;
    bVisible := FVisible;
  end;
  SetConsoleCursorInfo(Handle, info);
end;

function TCursor.GetSize: TCursorSize;
begin
  GetCursorInfo;
  Result := FSize;
end;

procedure TCursor.SetSize(Value: TCursorSize);
begin
  FSize := Value;
  SetCursorInfo;
end;

function CoordToLocation(Value: COORD): TCellLocation;
begin
  with Result do begin
    Column := Value.X;
    Row := Value.Y;
  end;
end;

function GetScreenBufferInfo(Handle: THandle): CONSOLE_SCREEN_BUFFER_INFOEX;
begin
  Result.cbSize := SizeOf(CONSOLE_SCREEN_BUFFER_INFOEX);
  GetConsoleScreenBufferInfoEx(Handle, @Result);
end;

function TCursor.GetLocation: TCellLocation;
begin
  Result := CoordToLocation(GetScreenBufferInfo(Handle).dwCursorPosition);
end;

procedure TCursor.SetLocation(Value: TCellLocation);
var
  dwCursorPosition: COORD;
begin
  with dwCursorPosition do begin
    X := Value.Column;
    Y := Value.Row;
  end;
  SetConsoleCursorPosition(Handle, dwCursorPosition);
end;

function TCursor.GetVisible: Boolean;
begin
  GetCursorInfo;
  Result := FVisible;
end;

procedure TCursor.SetVisible(Value: Boolean);
begin
  FVisible := Value;
  SetCursorInfo;
end;

{TScreenBuffer}

function CoordToSize(Value: COORD): TAreaSize;
begin
  with Result do begin
    Width := Value.X;
    Height := Value.Y;
  end;
end;

function WordToAttribute(Value: Word): TCellColorAttribute;
begin
  Value := Value and $FF;
  with Result do begin
    Foreground := Value and $F;
    Background := (Value and $F0) shr 4;
  end;
end;

function DWordToColor(Value: DWord): TColor;
begin
  with Result do begin
    R := Value and $FF;
    Value := Value shr 8;
    G := Value and $FF;
    Value := Value shr 8;
    B := Value and $FF;
  end;
end;

function SmallRectToArea(sr: SMALL_RECT): TArea;
begin
  with Result.Location do begin
    Row := sr.Top;
    Column := sr.Left;
  end;
  with Result.Size do begin
    Height := sr.Bottom - sr.Top;
    Width := sr.Right - sr.Left;
  end;
end;

procedure TScreenBuffer.GetInfo;
var
  i: Integer;
begin
  with GetScreenBufferInfo(Handle) do begin
    FSize := CoordToSize(dwSize);
    FTextColors := WordToAttribute(wAttributes);
    FViewport := SmallRectToArea(srWindow);
    for i := 0 to $F do begin
      FColorPalette[i] := DWordToColor(ColorTable[i]);
    end;
  end;
end;

function SizeToCoord(Value: TAreaSize): COORD;
begin
  with Result do begin
    X := Value.Width;
    Y := Value.Height;
  end;
end;

function AttributeToWord(Value: TCellColorAttribute): Word;
begin
  with Value do
    Result := Foreground or (Background shl 4);
end;

function AreaToSmallRect(A: TArea): SMALL_RECT;
begin
  with Result do begin
    Top := A.Location.Row;
    Left := A.Location.Column;
    Bottom := Top + A.Size.Height;
    Right := Left + A.Size.Width;
  end;
end;

function ColorToDword(Value: TColor): DWord;
begin
  with Value do begin
    Result := R + (G shl 8) + (B shl 16);
  end;
end;

procedure TScreenBuffer.SetInfo;
var
  info: CONSOLE_SCREEN_BUFFER_INFOEX;
  i: Integer;
begin
  info.cbSize := SizeOf(CONSOLE_SCREEN_BUFFER_INFOEX);
  GetConsoleScreenBufferInfoEx(Handle, @info);
  with info do begin
    dwSize := SizeToCoord(FSize);
    { wAttributes se setea con SetConsoleAttributes }
    srWindow := AreaToSmallRect(FViewport);
    for i := 0 to $f do begin
     ColorTable[i] := ColorToDWord(FColorPalette[i]);
    end;
  end;
  SetConsoleScreenBufferInfoEx(Handle, @info);
end;

procedure SetScreenBufferTextAttribute(Handle: THandle; Attribute: TCellColorAttribute);
begin
  SetConsoleTextAttribute(Handle, AttributeToWord(Attribute));
end;

function TScreenBuffer.GetForeground: TColorPaletteIndex;
begin
  GetInfo;
  Result := FTextColors.Foreground;
end;

procedure TScreenBuffer.SetForeground(Value: TColorPaletteIndex);
begin
  GetInfo;
  FTextColors.Foreground := Value;
  SetScreenBufferTextAttribute(Handle, FTextColors);
end;

function TScreenBuffer.GetBackground: TColorPaletteIndex;
begin
  GetInfo;
  Result := FTextColors.Background;
end;

procedure TScreenBuffer.SetBackground(Value: TColorPaletteIndex);
begin
  GetInfo;
  FTextColors.Background := Value;
  SetScreenBufferTextAttribute(Handle, FTextColors);
end;

function TScreenBuffer.GetSize: TAreaSize;
begin
  GetInfo;
  Result := FSize;
end;

function TScreenBuffer.GetCursor: TCursor;
begin
  FCursor.Handle := Handle;
  Result := FCursor;
end;

function GetMode(Handle: THandle): LongWord;
begin
  GetConsoleMode(Handle, Result);
end;

function GetBitState(Value: LongWord; Bit: LongWord): Boolean;
begin
  Result := (Value and (1 shl Bit)) <> 0;
end;

function TScreenBuffer.GetVTP: Boolean;
begin
  Result := GetBitState(GetMode(Handle), ENABLE_VIRTUAL_TERMINAL_PROCESSING);
end;

procedure SetModeBit(Handle: THandle; Bit: LongWord; Enable: Boolean);
var
  Mode: LongWord;
begin
  Mode := GetMode(Handle);
  if Enable then
    Mode := Mode or (1 shl Bit)
  else
    Mode := Mode and not (1 shl Bit);
  SetConsoleMode(Handle, Mode);
end;

procedure TScreenBuffer.SetVTP(Value: Boolean);
begin
  SetModeBit(Handle, ENABLE_VIRTUAL_TERMINAL_PROCESSING, Value);
end;

function LocationToCoord(L: TCellLocation): COORD;
begin
  with Result do begin
    X := L.Column;
    Y := L.Row;
  end;
end;

function TScreenBuffer.GetCharactersAt(aLocation: TCellLocation; Count: Integer = 1): WideString;
var
  nLength: DWord;
  dwReadCoord: COORD;
  charsRead: DWord;
  Chars: Pointer;
begin
  nLength := Count * SizeOf(WideChar);
  GetMem(Chars, nLength);
  dwReadCoord := LocationToCoord(aLocation);
  ReadConsoleOutputCharacterW(Handle, Chars, nLength, dwReadCoord, charsRead);
  Result := PWideChar(Chars);
  SetLength(Result, charsRead);
  FreeMem(Chars);
end;

procedure TScreenBuffer.SetCharactersAt(Characters: WideString; aLocation: TCellLocation; Count: Integer = -1);
var
  nLength: DWord;
  dwWriteCoord: COORD;
  charsWritten: DWord;
begin
  if Count = -1 then begin
    nLength := Length(Characters);
  end else begin
    nLength := Count;
  end;
  dwWriteCoord := LocationToCoord(aLocation);
  WriteConsoleOutputCharacterW(Handle, PWideChar(Characters), nLength, dwWriteCoord, charsWritten);
end;

function GetAttributes(Handle: THandle; aLocation: TCellLocation; Count: Integer): TWords;
var
  dwReadCoord: COORD;
  nLength: DWord;
  attrsRead: DWord;
  i: Integer;
begin
  nLength := Count;
  SetLength(Result, nLength);
  dwReadCoord := LocationToCoord(aLocation);
  ReadConsoleOutputAttribute(Handle, Result, nLength, dwReadCoord, attrsRead);
  SetLength(Result, attrsRead);
end;

function TScreenBuffer.GetAttributesAt(aLocation: TCellLocation; Count: Integer = 1): TCellColorAttributes;
var
  Words: TWords;
  i: Integer;
begin
  Words := GetAttributes(Handle, aLocation, Count);
  SetLength(Result, Length(Words));
  for i := 0 to Length(Words) - 1 do begin
    Result[i] := WordToAttribute(Words[i]);
  end;
end;

procedure TScreenBuffer.SetAttributesAt(Attributes: TCellColorAttributes; aLocation: TCellLocation; Count: Integer = -1);
var
  Words: TWords;
  i: Integer;
  attrsWritten: DWord;
begin
  if Count = -1 then begin
    Count := Length(Attributes);
  end;
  if Count > Length(Attributes) then begin
    Count := Length(Attributes);
  end;
  SetLength(Words, Count);
  for i := 0 to Count - 1 do begin
    Words[i] := AttributeToWord(Attributes[i]);
  end;
  WriteConsoleOutputAttribute(Handle, Words, Count, LocationToCoord(aLocation), attrsWritten);
end;

function TScreenBuffer.GetFont: TFont;
var
  info: CONSOLE_FONT_INFOEX;
begin
  info.cbSize := SizeOf(CONSOLE_FONT_INFOEX);
  GetCurrentConsoleFontEx(Handle, False, @info);
  with Result do begin
    Size := CoordToSize(info.dwFontSize);
    FaceName := info.FaceName;
  end;
end;

procedure TScreenBuffer.SetFont(Value: TFont);
var
  info: CONSOLE_FONT_INFOEX;
begin
  with info do begin
    cbSize := SizeOf(CONSOLE_FONT_INFOEX);
    dwFontSize := SizeToCoord(Value.Size);
    FontFamily := FF_DONTCARE;
    FontWeight := FW_NORMAL;
    FaceName := Value.FaceName;
  end;
  SetCurrentConsoleFontEx(Handle, False, @info);
end;

procedure TScreenBuffer.CopyAreaTo(Area: TArea; aBuffer: TScreenBuffer; aLocation: TCellLocation);
var
  CharInfos: Pointer;
  CharInfosSize: Integer;

  dwBufferSize, dwBufferCoord: COORD;
  region: SMALL_RECT;
begin
  with Area.Size do GetMem(CharInfos, Height * Width * SizeOf(CHAR_INFO));
  dwBufferSize := SizeToCoord(Area.Size);
  region := AreaToSmallRect(Area);
  ReadConsoleOutputW(Handle, CharInfos, dwBufferSize, dwBufferCoord, region);
  with region do begin
    Top := aLocation.Row;
    Left := aLocation.Column;
    Bottom := Top + Area.Size.Height;
    Right := Left + Area.Size.Width;
  end;
  WriteConsoleOutputW(aBuffer.Handle, CharInfos, dwBufferSize, dwBufferCoord, region);
end;

procedure TScreenBuffer.ScrollArea(ScrollArea: TArea; aLocation: TCellLocation; ClippingArea: TArea; Filler: TCharacterCell);
var
  srScroll: SMALL_RECT;
  destination: COORD;
  fill: CHAR_INFO;
  srClip: SMALL_RECT;
begin
  srScroll := AreaToSmallRect(ScrollArea);
  destination := LocationToCoord(aLocation);
  srClip := AreaToSmallRect(ClippingArea);
  with fill do begin
    UnicodeChar := Filler.Character;
    Attributes := AttributeToWord(Filler.Colors);
  end;
  ScrollConsoleScreenBuffer(Handle, srScroll, srClip, destination, fill);
end;

procedure TScreenBuffer.SetAttributeAt(Attribute: TCellColorAttribute; aLocation: TCellLocation; Count: Integer = 1);
var
  attrsWritten: DWord;
begin
  FillConsoleOutputAttribute(Handle, AttributeToWord(Attribute), Count, LocationToCoord(aLocation), attrsWritten);
end;

procedure TScreenBuffer.SetCharacterAt(Character: WideChar; aLocation: TCellLocation; Count: Integer = 1);
var
  charsWritten: DWord;
begin
  FillConsoleOutputCharacter(Handle, Character, Count, LocationToCoord(aLocation), charsWritten);
end;

procedure TScreenBuffer.Write(Characters: WideString);
var
  charsWritten: DWord;
begin
  WriteConsoleW(Handle, PWideChar(Characters), Length(Characters), charsWritten, Nil);
end;

function TScreenBuffer.GetColorPalette(Index: TColorPaletteIndex): TColor;
begin
  GetInfo;
  Result := FColorPalette[Index];
end;

procedure TScreenBuffer.SetColorPalette(Index: TColorPaletteIndex; aColor: TColor);
begin
  GetInfo;
  FColorPalette[Index] := aColor;
  SetInfo;
end;

{TScreenBuffers}

function TScreenBuffers.GetBuffer(aName: String): TScreenBuffer;
var
  index: Integer;
begin
  index := AnsiIndexText(aName, FBufferNames);
  if index = -1 then begin
    Raise EConsoleException.Create(Format('No ScreenBuffer with name %s exists.', [aName]));
  end;
  Result := FBuffers[index];
end;

function TScreenBuffers.GetCount: Integer;
begin
  Result := Length(FBufferNames);
end;

procedure TScreenBuffers.Add(aName: String);
var
  dwDesiredAccess: DWORD;
  dwShareMode: DWORD;
  sa: SECURITY_ATTRIBUTES;
  dwFlags: DWORD;
begin
  dwDesiredAccess := GENERIC_READ or GENERIC_WRITE;
  dwShareMode := FILE_SHARE_READ or FILE_SHARE_WRITE;
  with sa do begin
    nLength := SizeOf(SECURITY_ATTRIBUTES);
    lpSecurityDescriptor := Nil;
    bInheritHandle := True;
  end;
  AddUsingHandle(aName, CreateConsoleScreenBuffer(dwDesiredAccess, dwShareMode, sa, CONSOLE_TEXTMODE_BUFFER, Nil));
end;

procedure TScreenBuffers.AddUsingHandle(aName: String; aHandle: THandle);
var
  aScreenBuffer: TScreenBuffer;
begin
  if AnsiIndexText(aName, FBufferNames) > -1 then begin
    Raise EConsoleException.Create(Format('A ScreenBuffer with name %s already exists.', [aName]));
  end;
  SetLength(FBufferNames, Count+1);
  FBufferNames[Count-1] := aName;
  aScreenBuffer.Handle := aHandle;
  SetLength(FBuffers, Count+1);
  FBuffers[Count-1] := aScreenBuffer;
  aScreenBuffer.GetInfo;
end;

{TConsole}

procedure TConsole.Init;
begin
  FInput.Handle := StdInputHandle;
  FBuffers.AddUsingHandle('default', StdOutputHandle);
  FBuffers['default'].VirtualTerminalProcessing := True;
  OutputCodePage := CP_UTF8;
end;

procedure TConsole.Done;
begin
end;

function TConsole.GetBuffer(BufferName: WideString): TScreenBuffer;
begin
  Result := FBuffers[BufferName];
end;

procedure TConsole.SetActiveBuffer(Value: WideString);
begin
  SetConsoleActiveScreenBuffer(Buffers[Value].Handle);
end;

function TConsole.GetTitle: WideString;
var
  nSize: DWord;
  aTitle: array[0..1024] of WideChar;
begin
  GetConsoleTitleW(PWideChar(@aTitle), SizeOf(aTitle));
  Result := aTitle;
end;

procedure TConsole.SetTitle(Value: WideString);
begin
  SetConsoleTitleW(PWideChar(Value));
end;

procedure TConsole.AddBuffer(aName: WideString);
begin
  FBuffers.Add(aName);
end;

function TConsole.GetInputCodePage: LongWord;
begin
  Result := GetConsoleCP;
end;

procedure TConsole.SetInputCodePage(Value: LongWord);
begin
  SetConsoleCP(Value);
end;

function TConsole.GetOutputCodePage: LongWord;
begin
  Result := GetConsoleOutputCP;
end;

procedure TConsole.SetOutputCodePage(Value: LongWord);
begin
  SetConsoleOutputCP(Value);
end;

{TConsoleInput}

function SelectionFlag(info: CONSOLE_SELECTION_INFO; Flag: DWord): Boolean;
begin
  Result := (info.dwFlags and Flag) <> 0;
end;

function GetSelection: TSelection;
var
  i: CONSOLE_SELECTION_INFO;
begin
  GetConsoleSelectionInfo(@i);
  with Result do begin
    MousePressed := SelectionFlag(i, CONSOLE_MOUSE_DOWN);
    Selecting := SelectionFlag(i, CONSOLE_MOUSE_SELECTION);
    Selected := SelectionFlag(i, CONSOLE_NO_SELECTION);
    InProgress := SelectionFlag(i, CONSOLE_SELECTION_IN_PROGRESS);
    Empty := i.dwFlags = 0;
    Anchor := CoordToLocation(i.dwSelectionAnchor);
    Area := SmallRectToArea(i.srSelection);
  end;
end;

function NextEvent(Handle: THandle): INPUT_RECORD;
var
  eventCount: DWord;
begin
  GetNumberOfConsoleInputEvents(Handle, eventCount);
  if eventCount <> 0 then begin
    PeekConsoleInput(Handle, Result, 1, eventCount);
  end;
end;

function TConsoleInput.GetNextEventType: TInputEventType;
begin
  Result := ietNone;
  if GetSelection.Selected then begin
    Result := ietSelection;
  end else begin
    case NextEvent(Handle).EventType of
      KEY_EVENT: Result := ietKey;
      _MOUSE_EVENT: Result := ietMouse;
      WINDOW_BUFFER_SIZE_EVENT: Result := ietWindow;
    end;
  end;
end;

function TConsoleInput.GetNextMouseEventType: TMouseEventType;
var
  next: INPUT_RECORD;
begin
  Result := metNone;
  next := NextEvent(Handle);
  if next.EventType = _MOUSE_EVENT then begin
    with next.event.MouseEvent do begin
      if dwEventFlags = 0 then begin
        Result := metButtonState;
      end else begin
        case dwEventFlags of
          DOUBLE_CLICK: Result := metSecondClick;
          MOUSE_MOVED: Result := metMouseMoved;
          MOUSE_HWHEELED: Result := metWheelState;
          MOUSE_WHEELED: Result := metWheelState;
        end;
      end;
    end;
  end;
end;

function TConsoleInput.GetNextKeyEventType: TInputActivationState;
var
  next: INPUT_RECORD;
begin
  Result := iasNone;
  next := NextEvent(Handle);
  if NEXT.EventType = KEY_EVENT then begin
    if next.Event.KeyEvent.bKeyDown then begin
      Result := iasPressed;
    end else begin
      Result := iasReleased;
    end;
  end;
end;

function KeyFlag(s: DWord; Flag: DWord): Boolean;
begin
  Result := (s and Flag) <> 0;
end;

function GetControlKeys(s: DWord): TControlKeys;
begin
  with Result do begin
    Capslock := KeyFlag(s, CAPSLOCK_ON);
    Enhanced := KeyFlag(s, ENHANCED_KEY);
    LeftAlt := KeyFlag(s, LEFT_ALT_PRESSED);
    LeftCtrl := KeyFlag(s, LEFT_CTRL_PRESSED);
    Numlock := KeyFlag(s, NUMLOCK_ON);
    RightAlt := KeyFlag(s, RIGHT_ALT_PRESSED);
    RightCtrl := KeyFlag(s, RIGHT_CTRL_PRESSED);
    ScrollLock := KeyFlag(s, SCROLLLOCK_ON);
    Shift := KeyFlag(s, SHIFT_PRESSED);
  end;
end;

function ButtonFlag(i: INPUT_RECORD; Flag: DWord): Boolean;
begin
  Result := (i.Event.MouseEvent.dwEventFlags and Flag) <> 0;
end;

function TConsoleInput.ConsumeMouseEvent: TMouseEvent;
var
  i: INPUT_RECORD;
  eventCount: DWord;
  siWheelDistance: SmallInt;
  siWheelState: SmallInt;
begin
  ReadConsoleInput(Handle, i, 1, eventCount);
  if eventCount <> 0 then begin
    if i.EventType = _MOUSE_EVENT then begin
      with i.Event.MouseEvent do begin
        Result.ControlKeys := GetControlKeys(dwControlKeyState);
        Result.Location := CoordToLocation(dwMousePosition);
        if dwEventFlags = 0 then begin
          // Result.EventType := metButtonState;
          if dwButtonState = 0 then begin
            Result.ButtonState := iasReleased;
          end else begin
            Result.ButtonState := iasPressed;
            if ButtonFlag(i, RIGHTMOST_BUTTON_PRESSED) then begin
              Include(Result.ClickedButtons, cmbRight);
            end;
            if ButtonFlag(i, FROM_LEFT_1ST_BUTTON_PRESSED) then begin
              Include(Result.ClickedButtons, cmbLeft1);
            end;
            if ButtonFlag(i, FROM_LEFT_2ND_BUTTON_PRESSED) then begin
              Include(Result.ClickedButtons, cmbLeft2);
            end;
            if ButtonFlag(i, FROM_LEFT_3RD_BUTTON_PRESSED) then begin
              Include(Result.ClickedButtons, cmbLeft3);
            end;
            if ButtonFlag(i, FROM_LEFT_4TH_BUTTON_PRESSED) then begin
              Include(Result.ClickedButtons, cmbLeft4);
            end;
          end;
        end else begin
          siWheelDistance := Hi(dwButtonState);
          siWheelState := Lo(dwButtonState);
          case dwEventFlags of
            MOUSE_MOVED: begin
              // Result.EventType := metMouseMoved;
            end;

            DOUBLE_CLICK: begin
              // Result.EventType := metSecondClick;
            end;

            MOUSE_HWHEELED: begin
              // Result.EventType := metHorizontalWheel;
              Result.WheelDistance := siWheelDistance;
              if siWheelState = 0 then begin
                Result.WheelState := iasReleased;
              end else begin
                Result.WheelState := iasPressed;
              end;
              if siWheelDistance > 0 then begin
                Result.WheelDirection := wdRight;
              end else begin
                Result.WheelDirection := wdLeft;
              end;
            end;

            MOUSE_WHEELED: begin
              // Result.EventType := metVerticalWheel;
              Result.WheelDistance := siWheelDistance;
              if siWheelState = 0 then begin
                Result.WheelState := iasReleased;
              end else begin
                Result.WheelState := iasPressed;
              end;
              if siWheelDistance > 0 then begin
                Result.WheelDirection := wdBackward;
              end else begin
                Result.WheelDirection := wdForward;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TConsoleInput.ConsumeKeyEvent: TKeyEvent;
var
  ir: INPUT_RECORD;
  eventCount: DWord;
begin
  ReadConsoleInput(Handle, ir, 1, eventCount);
  if eventCount <> 0 then begin
    if ir.EventType = KEY_EVENT then begin
      with ir.Event.KeyEvent do begin
        Result.Repetitions := wRepeatCount;
        Result.KeyCode := wVirtualKeyCode;
        Result.ScanCode := wVirtualScanCode;
        Result.Char := UnicodeChar;
        Result.ControlKeys := GetControlKeys(dwControlKeyState);
        case wVirtualKeyCode of
          VK_LSHIFT: Result.ControlKeys.LeftShift := True;
          VK_RSHIFT: Result.ControlKeys.RightShift := True;

          VK_VOLUME_MUTE: Result.VolumeKey := cvkMute;
          VK_VOLUME_DOWN: Result.VolumeKey := cvkDown;
          VK_VOLUME_UP: Result.VolumeKey := cvkUp;

          VK_MEDIA_NEXT_TRACK: Result.MediaKey := cmkNext;
          VK_MEDIA_PREV_TRACK: Result.MediaKey := cmkPrev;
          VK_MEDIA_STOP: Result.MediaKey := cmkStop;
          VK_MEDIA_PLAY_PAUSE: Result.MediaKey := cmkPlayPause;

          VK_LWIN: Result.WindowsKey := cksLeft;
          VK_RWIN: Result.WindowsKey := cksRight;

          VK_LMENU: Result.MenuKey := cksLeft;
          VK_RMENU: Result.MenuKey := cksRight;
        end;
      end;
    end;
  end;
end;

function TConsoleInput.ConsumeResizeEvent: TResizeEvent;
var
  ir: INPUT_RECORD;
  eventCount: DWord;
begin
  Result.EventType := retNone;
  ReadConsoleInput(Handle, ir, 1, eventCount);
  if eventCount <> 0 then begin
    if ir.EventType = WINDOW_BUFFER_SIZE_EVENT then begin
      with ir.Event.WindowBufferSizeEvent do begin
        Result.EventType := retResize;
        Result.NewSize := CoordToSize(dwSize);
      end;
    end;
  end;
end;

function TConsoleInput.WaitForEvent(Millis: Integer): TInputEventType;
begin
  Result := ietNone;
  if WaitForSingleObject(Handle, Millis) <> 0 then begin
    Result := GetNextEventType;
  end;
end;

procedure TConsoleInput.DiscardEvents;
begin
  FlushConsoleInputBuffer(Handle);
end;

{TControlKeys}

function TControlKeys.GetCtrl: Boolean;
begin
  Result := LeftCtrl or RightCtrl;
end;

function TControlKeys.GetAlt: Boolean;
begin
  Result := LeftAlt or RightAlt;
end;

initialization

  Reset(Input);
  Rewrite(Output);

  StdInputHandle := GetStdHandle(STD_INPUT_HANDLE);
  StdOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);

  TextRec(Input).Handle := StdInputHandle;
  TextRec(Output).Handle := StdOutputHandle;

  Console.Init;

finalization

  Console.Done;

  Close(Input);
  Close(Output);

end.
