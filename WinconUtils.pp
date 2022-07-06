unit WinconUtils;

{$mode delphi}

interface

  uses Windows, WinconTypes, WinconConsoleInput;

  function CreateScreenBuffer: THandle;

  function GetMode(Handle: THandle): LongWord;
  function GetModeBit(Value: LongWord; Bit: LongWord): Boolean;
  procedure SetModeBit(Handle: THandle; Bit: LongWord; Enable: Boolean);

  function ScreenCellLocation(aRow, aColumn: Integer): TScreenCellLocation;

  function ScreenCellLocationAsCOORD(aLocation: TScreenCellLocation): COORD;
  function COORDAsScreenCellLocation(aCoord: COORD): TScreenCellLocation;

  function ScreenArea(aLocation: TScreenCellLocation; aSize: TScreenAreaSize): TScreenArea;
  function ScreenAreaAsSMALLRECT(aScreenArea: TScreenArea): SMALL_RECT;
  function SMALLRECTAsScreenArea(sr: SMALL_RECT): TScreenArea;

  function ScreenAreaSize(aHeight, aWidth: Integer): TScreenAreaSize;
  function ScreenAreaSizeAsCOORD(aAreaSize: TScreenAreaSize): COORD;
  function COORDAsScreenAreaSize(Value: COORD): TScreenAreaSize;

  function DWORDAsCursorSize(aDWord: DWORD): TCursorSize;
  function CursorSizeAsDWORD(aSize: TCursorSize): DWORD;

  function GetScreenBufferInfo(aHandle: THandle): CONSOLE_SCREEN_BUFFER_INFOEX;
  procedure SetScreenBufferInfo(aHandle: THandle; info: CONSOLE_SCREEN_BUFFER_INFOEX);

  function Color(Red, Green, Blue: Byte; aX: Byte = 0): TColor;
  function DWORDAsColor(Value: DWord): TColor;
  function ColorAsDWORD(Value: TColor): DWord;

  function ControlKeysAsString(Controlkeys: TControlKeys): String;

implementation

  function CreateScreenBuffer: THandle;
  var
    dwDesiredAccess: DWORD;
    dwShareMode: DWORD;
    sa: SECURITY_ATTRIBUTES;
  begin
    dwDesiredAccess := GENERIC_READ or GENERIC_WRITE;
    dwShareMode := FILE_SHARE_READ or FILE_SHARE_WRITE;
    with sa do begin
      nLength := SizeOf(SECURITY_ATTRIBUTES);
      lpSecurityDescriptor := Nil;
      bInheritHandle := True;
    end;
    Result := CreateConsoleScreenBuffer(dwDesiredAccess, dwShareMode, sa, CONSOLE_TEXTMODE_BUFFER, Nil);
  end;

  function GetMode(Handle: THandle): LongWord;
  begin
    GetConsoleMode(Handle, Result);
  end;

  function GetModeBit(Value: LongWord; Bit: LongWord): Boolean;
  begin
    // Result := (Value and (1 shl Bit)) <> 0;
    Result := (Value and Bit) <> 0;
  end;

  procedure SetModeBit(Handle: THandle; Bit: LongWord; Enable: Boolean);
  var
    Mode: LongWord;
  begin
    Mode := GetMode(Handle);
    if Enable then
      Mode := Mode or Bit
    else
      Mode := Mode and not Bit;
    SetConsoleMode(Handle, Mode);
  end;

  function ScreenAreaAsSMALLRECT(aScreenArea: TScreenArea): SMALL_RECT;
  begin
    with Result do begin
      Top := aScreenArea.Location.Row;
      Left := aScreenArea.Location.Column;
      Bottom := Top + aScreenArea.Size.Height;
      Right := Left + aScreenArea.Size.Width;
    end;
  end;

  function ScreenCellLocationAsCOORD(aLocation: TScreenCellLocation): COORD;
  begin
    with Result do begin
      X := aLocation.Column;
      Y := aLocation.Row;
    end;
  end;

  function ScreenAreaSizeAsCOORD(aAreaSize: TScreenAreaSize): COORD;
  begin
    with Result do begin
      X := aAreaSize.Width;
      Y := aAreaSize.Height;
    end;
  end;

  function ScreenCellLocation(aRow, aColumn: Integer): TScreenCellLocation;
  begin
    with Result do begin
      Row := aRow;
      Column := aColumn;
    end;
  end;

  function DWordAsCursorSize(aDWord: DWORD): TCursorSize;
  begin
    Result := aDWord;
  end;

  function CursorSizeAsDWord(aSize: TCursorSize): DWORD;
  begin
    Result := aSize;
  end;

  function CoordAsScreenCellLocation(aCoord: COORD): TScreenCellLocation;
  begin
    with Result do begin
      Column := aCoord.X;
      Row := aCoord.Y;
    end;
  end;

  function GetScreenBufferInfo(aHandle: THandle): CONSOLE_SCREEN_BUFFER_INFOEX;
  begin
    Result.cbSize := SizeOf(Result);
    GetConsoleScreenBufferInfoEx(aHandle, @Result);
  end;

  procedure SetScreenBufferInfo(aHandle: THandle; info: CONSOLE_SCREEN_BUFFER_INFOEX);
  begin
    info.cbSize := SizeOf(info);
    with info.srWindow do begin
      Right := Right + 1;
      Bottom := Bottom + 1;
    end;
    SetConsoleScreenBufferInfoEx(aHandle, @info);
  end;

  function DWordAsColor(Value: DWord): TColor;
  begin
    with Result do begin
      R := Value and $FF;
      Value := Value shr 8;
      G := Value and $FF;
      Value := Value shr 8;
      B := Value and $FF;
    end;
  end;

  function ColorAsDword(Value: TColor): DWord;
  begin
    with Value do begin
      Result := R + (G shl 8) + (B shl 16);
    end;
  end;

  function COORDAsScreenAreaSize(Value: COORD): TScreenAreaSize;
  begin
    with Result do begin
      Width := Value.X;
      Height := Value.Y;
    end;
  end;

  function SMALLRECTAsScreenArea(sr: SMALL_RECT): TScreenArea;
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

  function ScreenAreaSize(aHeight, aWidth: Integer): TScreenAreaSize;
  begin
    with Result do begin
      Height := aHeight;
      Width := aWidth;
    end;
  end;

  function ScreenArea(aLocation: TScreenCellLocation; aSize: TScreenAreaSize): TScreenArea;
  begin
    with Result do begin
      Location := aLocation;
      Size := aSize;
    end;
  end;

  function Color(Red, Green, Blue: Byte; aX: Byte = 0): TColor;
  begin
    with Result do begin
      R := Red;
      G := Green;
      B := Blue;
      X := aX;
    end;
  end;

  function ControlKeysAsString;
    function Append(Prefix, Suffix: String): String;
    begin
      if Prefix <> '' then
        Result := Result + ' ';
      Result := Result + Suffix;
    end;
  begin
    Result := '';

    with ControlKeys do begin
      if CapsLockOn then
        Result := Append(Result, 'capslock');
      if EnhancedKey then
        Result := Append(Result, 'enhancedkey');
      if LeftAltPressed then
        Result := Append(Result, 'leftalt');
      if LeftCtrlPressed then
        Result := Append(Result, 'leftctrl');
      if NumLockOn then
        Result := Append(Result, 'numlock');
      if RightAltPressed then
        Result := Append(Result, 'rightalt');
      if RightCtrlPressed then
        Result := Append(Result, 'rightctrl');
      if ScrollLockOn then
        Result := Append(Result, 'scrolllock');
      if ShiftPressed then
        Result := Append(Result, 'shift');

      if LeftAltPressed or RightAltPressed then
        Result := Append(Result, 'alt');
      if LeftCtrlPressed or RightCtrlPressed then
        Result := Append(Result, 'ctrl');
    end;

  end;

end.