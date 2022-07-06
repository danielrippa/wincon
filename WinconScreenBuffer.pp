unit WinconScreenBuffer;

{$mode delphi}

interface

  uses Windows, WinconTypes, WinconCursor;

  type

    TScreenBuffer = record
      private
        FHandle: THandle;

        FTextAttributes: Word;
        FColorPalette: TColorPalette;

        FCursor: TCursor;

        FSize: TScreenAreaSize;
        FVisibleArea: TScreenArea;

        function GetTextAttributes: Word;
        procedure SetTextAttributes(Value: Word);

        function GetSize: TScreenAreaSize;
        procedure SetSize(Value: TScreenAreaSize);

        function GetVisibleArea: TScreenArea;
        procedure SetVisibleArea(Value: TScreenArea);

        function GetPaletteColor(Index: TPaletteColorIndex): TColor;
        procedure SetPaletteColor(Index: TPaletteColorIndex; Value: TColor);

        function GetFontFace: UnicodeString;
        procedure SetFontFace(Value: UnicodeString);
        function GetFontWeight: Integer;
        procedure SetFontWeight(Value: Integer);
        function GetFontWidth: Integer;
        procedure SetFontWidth(Value: Integer);
        function GetFontHeight: Integer;
        procedure SetFontHeight(Value: Integer);

        function GetNewLineAutoReturnEnabled: Boolean;
        procedure SetNewLineAutoReturnEnabled(Value: Boolean);

        function GetVirtualTerminalProcessingEnabled: Boolean;
        procedure SetVirtualTerminalProcessingEnabled(Value: Boolean);

        function GetExtendedCharacterAttributesEnabled: Boolean;
        procedure SetExtendedCharacterAttributesEnabled(Value: Boolean);

        function GetProcessedOutputEnabled: Boolean;
        procedure SetProcessedOutputEnabled(Value: Boolean);

        function GetWrapAtEolOutputEnabled: Boolean;
        procedure SetWrapAtEolOutputEnabled(Value: Boolean);

        procedure GetProperties;
        procedure SetProperties;
      public
        procedure Init(aHandle: THandle);

        property Cursor: TCursor read FCursor;

        property TextAttributes: Word read GetTextAttributes write SetTextAttributes;

        property NewLineAutoReturnEnabled: Boolean read GetNewLineAutoReturnEnabled write SetNewLineAutoReturnEnabled;
        property VirtualTerminalProcessingEnabled: Boolean read GetVirtualTerminalProcessingEnabled write SetVirtualTerminalProcessingEnabled;
        property ExtendedCharacterAttributesEnabled: Boolean read GetExtendedCharacterAttributesEnabled write SetExtendedCharacterAttributesEnabled;
        property ProcessedOutputEnabled: Boolean read GetProcessedOutputEnabled write SetProcessedOutputEnabled;
        property WrapAtEolOutputEnabled: Boolean read GetWrapAtEolOutputEnabled write SetWrapAtEolOutputEnabled;

        property PaletteColor[Index: TPaletteColorIndex]: TColor read GetPaletteColor write SetPaletteColor;

        property Size: TScreenAreaSize read GetSize write SetSize;
        property VisibleArea: TScreenArea read GetVisibleArea write SetVisibleArea;

        property FontFace: UnicodeString read GetFontFace write SetFontFace;
        property FontWeight: Integer read GetFontWeight write SetFontWeight;
        property FontWidth: Integer read GetFontWidth write SetFontWidth;
        property FontHeight: Integer read GetFontHeight write SetFontHeight;

        function GetAreaCells(aArea: TScreenArea): TScreenCells;
        procedure SetAreaCells(aArea: TScreenArea; aCells: TScreenCells);

        function GetAreaCharacters(aArea: TScreenArea): UnicodeString;
        procedure SetAreaCharacters(aArea: TScreenArea; aCharacters: UnicodeString);

        function GetAreaAttributes(aArea: TScreenArea): TScreenCellsAttributes;
        procedure SetAreaAttributes(aArea: TScreenArea; aAttributes: TScreenCellsAttributes);

        procedure ScrollArea(aArea: TScreenArea; aLocation: TScreenCellLocation; aFill: TScreenCell);

        procedure Activate;
        procedure Write(Characters: UnicodeString);

        procedure Close;
    end;

implementation

  uses WinconUtils;

  procedure TScreenBuffer.Init(aHandle: THandle);
  begin
    FHandle := aHandle;
    FCursor.Init(aHandle);
    GetProperties;
  end;

  function TScreenBuffer.GetNewLineAutoReturnEnabled: Boolean;
  begin
    Result := not GetModeBit(GetMode(FHandle), DISABLE_NEWLINE_AUTO_RETURN);
  end;

  procedure TScreenBuffer.SetNewLineAutoReturnEnabled(Value: Boolean);
  begin
    SetModeBit(FHandle, DISABLE_NEWLINE_AUTO_RETURN, not Value);
  end;

  function TScreenBuffer.GetVirtualTerminalProcessingEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FHandle), ENABLE_VIRTUAL_TERMINAL_PROCESSING);
  end;

  procedure TScreenBuffer.SetVirtualTerminalProcessingEnabled(Value: Boolean);
  begin
    SetModeBit(FHandle, ENABLE_VIRTUAL_TERMINAL_PROCESSING, Value);
  end;

  function TScreenBuffer.GetExtendedCharacterAttributesEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FHandle), ENABLE_LVB_GRID_WORLDWIDE);
  end;

  procedure TScreenBuffer.SetExtendedCharacterAttributesEnabled(Value: Boolean);
  begin
    SetModeBit(FHandle, ENABLE_LVB_GRID_WORLDWIDE, Value);
  end;

  function TScreenBuffer.GetProcessedOutputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FHandle), ENABLE_PROCESSED_OUTPUT);
  end;

  procedure TScreenBuffer.SetProcessedOutputEnabled(Value: Boolean);
  begin
    SetModeBit(FHandle, ENABLE_PROCESSED_OUTPUT, Value);
  end;

  function TScreenBuffer.GetWrapAtEolOutputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FHandle), ENABLE_WRAP_AT_EOL_OUTPUT );
  end;

  procedure TScreenBuffer.SetWrapAtEolOutputEnabled(Value: Boolean);
  begin
    SetModeBit(FHandle, ENABLE_WRAP_AT_EOL_OUTPUT, Value);
  end;

  procedure TScreenBuffer.ScrollArea(aArea: TScreenArea; aLocation: TScreenCellLocation; aFill: TScreenCell);
  var
    ScrollRectangle, ClipRectangle: SMALL_RECT;
    DestinationOrigin: COORD;
    Fill: CHAR_INFO;
  begin
    ScrollRectangle := ScreenAreaAsSMALLRECT(aArea);
    ClipRectangle := ScreenAreaAsSMALLRECT(aArea);
    DestinationOrigin := ScreenCellLocationAsCOORD(aLocation);
    with Fill do begin
      UnicodeChar := aFill.Character;
      Attributes := aFill.CellAttributes;
    end;
    ScrollConsoleScreenBuffer(FHandle, ScrollRectangle, ClipRectangle, DestinationOrigin, Fill);
  end;

  function TScreenBuffer.GetAreaCells(aArea: TScreenArea): TScreenCells;
  var
    I, Len: Integer;
    Buffer: array of CHAR_INFO;
    region: SMALL_RECT;
  begin
    Result := Nil;
    with aArea.Size do begin
      Len := Height * Width;

      SetLength(Buffer, Len);
      SetLength(Result, Len);
    end;
    region := ScreenAreaAsSMALLRECT(aArea);
    ReadConsoleOutputW(FHandle, Pointer(Buffer), ScreenAreaSizeAsCOORD(aArea.Size), ScreenCellLocationAsCOORD(ScreenCellLocation(0, 0)), region);
    for I := 0 to Len - 1 do begin
      with Result[I] do begin
        with Buffer[I] do begin
          Character := UnicodeChar;
          CellAttributes := Attributes;
        end;
      end;
    end;
  end;

  procedure TScreenBuffer.SetAreaCells(aArea: TScreenArea; aCells: TScreenCells);
  var
    I, Len: Integer;
    Buffer: array of CHAR_INFO;
    region: SMALL_RECT;
  begin
    region := ScreenAreaAsSMALLRECT(aArea);
    with aArea.Size do begin
      Len := Height * Width;
      if Len > Length(aCells) then begin
        Len := Length(aCells);
      end;
    end;
    SetLength(Buffer, Len);
    for I := 0 to Len - 1 do begin
      with Buffer[I] do begin
        with aCells[I] do begin
          UnicodeChar := Character;
          Attributes := CellAttributes;
        end;
      end;
    end;
    WriteConsoleOutputW(FHandle, Pointer(Buffer), ScreenAreaSizeAsCOORD(aArea.Size), ScreenCellLocationAsCOORD(ScreenCellLocation(0, 0)), region);
  end;

  function GetCellsCharacters(aCells: TScreenCells): UnicodeString;
  var
    I: Integer;
  begin
    Result := '';
    for I := 0 to Length(aCells) - 1 do begin
      Result := Result + aCells[I].Character;
    end;
  end;

  function GetCellsAttributes(aCells: TScreenCells): TScreenCellsAttributes;
  var
    I, Len: Integer;
  begin
    Result := Nil;
    Len := Length(aCells);
    SetLength(Result, Len);
    for I := 0 to Len - 1 do begin
      Result[I] := aCells[I].CellAttributes;
    end;
  end;

  function TScreenBuffer.GetAreaCharacters(aArea: TScreenArea): UnicodeString;
  begin
    Result := GetCellsCharacters(GetAreaCells(aArea));
  end;

  procedure TScreenBuffer.SetAreaCharacters(aArea: TScreenArea; aCharacters: UnicodeString);
  var
    OriginalCells: TScreenCells;
    CharInfos: array of CHAR_INFO;
    I: Integer;
    region: SMALL_RECT;
  begin
    OriginalCells := GetAreaCells(aArea);
    SetLength(CharInfos, Length(OriginalCells));
    for I := 0 to Length(OriginalCells) - 1 do begin
      with CharInfos[I] do begin
        if I < Length(aCharacters) then begin
          UnicodeChar := aCharacters[I+1];
        end else begin
          UnicodeChar := OriginalCells[I].Character;
        end;
        Attributes := OriginalCells[I].CellAttributes;
      end;
    end;
    region := ScreenAreaAsSMALLRECT(aArea);
    try
      WriteConsoleOutputW(FHandle, Pointer(CharInfos), ScreenAreaSizeAsCOORD(aArea.Size), ScreenCellLocationAsCOORD(ScreenCellLocation(0, 0)), region);
    finally
    end;
  end;

  function TScreenBuffer.GetAreaAttributes(aArea: TScreenArea): TScreenCellsAttributes;
  begin
    Result := GetCellsAttributes(GetAreaCells(aArea));
  end;

  procedure TScreenBuffer.SetAreaAttributes(aArea: TScreenArea; aAttributes: TScreenCellsAttributes);
  var
    OriginalCells: TScreenCells;
    CharInfos: array of CHAR_INFO;
    I, Len: Integer;
    region: SMALL_RECT;
  begin
    OriginalCells := GetAreaCells(aArea);
    Len := Length(OriginalCells);
    if Len > Length(aAttributes) then begin
      Len := Length(aAttributes);
    end;
    SetLength(CharInfos, Len);
    for I := 0 to Len - 1 do begin
      with CharInfos[I] do begin
        UnicodeChar := OriginalCells[I].Character;
        Attributes := aAttributes[I];
      end;
    end;
    region := ScreenAreaAsSMALLRECT(aArea);
    WriteConsoleOutputW(FHandle, Pointer(CharInfos), ScreenAreaSizeAsCOORD(aArea.Size), ScreenCellLocationAsCOORD(ScreenCellLocation(0, 0)), region);
  end;

  procedure TScreenBuffer.GetProperties;
  var
    I: Integer;
  begin
    with GetScreenBufferInfo(FHandle) do begin
      FSize := COORDAsScreenAreaSize(dwSize);
      FVisibleArea := SMALLRECTAsScreenArea(srWindow);
      FTextAttributes := wAttributes;
      for I := 0 to $f do begin
        FColorPalette[I] := DWordAsColor(ColorTable[I]);
      end;
    end;
  end;

  procedure TScreenBuffer.SetProperties;
  var
    info: CONSOLE_SCREEN_BUFFER_INFOEX;
    I: TPaletteColorIndex;
  begin
    info := GetScreenBufferInfo(FHandle);
    with info do begin
      dwSize := ScreenAreaSizeAsCOORD(FSize);
      srWindow := ScreenAreaAsSMALLRECT(FVisibleArea);
      wAttributes := FTextAttributes;
      for I := 0 to $f do begin
        ColorTable[I] := ColorAsDWord(FColorPalette[I]);
      end;
    end;
    SetScreenBufferInfo(FHandle, info);
  end;

  function TScreenBuffer.GetTextAttributes: Word;
  begin
    GetProperties;
    Result := FTextAttributes;
  end;

  procedure TScreenBuffer.SetTextAttributes(Value: Word);
  begin
    GetProperties;
    FTextAttributes := Value;
    SetProperties;
  end;

  function TScreenBuffer.GetSize: TScreenAreaSize;
  begin
    GetProperties;
    Result := FSize;
  end;

  procedure TScreenBuffer.SetSize(Value: TScreenAreaSize);
  begin
    GetProperties;
    FSize := Value;
    SetProperties;
  end;

  function TScreenBuffer.GetVisibleArea: TScreenArea;
  begin
    GetProperties;
    Result := FVisibleArea;
  end;

  procedure TScreenBuffer.SetVisibleArea(Value: TScreenArea);
  begin
    GetProperties;
    FVisibleArea := Value;
    SetProperties;
  end;

  function TScreenBuffer.GetPaletteColor(Index: TPaletteColorIndex): TColor;
  begin
    GetProperties;
    Result := FColorPalette[Index];
  end;

  procedure TScreenBuffer.SetPaletteColor(Index: TPaletteColorIndex; Value: TColor);
  begin
    GetProperties;
    FColorPalette[Index] := Value;
    SetProperties;
  end;

  function ConsoleFontInfo: CONSOLE_FONT_INFOEX;
  var
    Size: Integer;
  begin
    Size := SizeOf(Result);
    FillChar(Result, Size, 0);
    Result.cbSize := Size;
  end;

  function GetBufferFontInfoEx(aHandle: THandle): CONSOLE_FONT_INFOEX;
  begin
    Result := ConsoleFontInfo;
    GetCurrentConsoleFontEx(aHandle, False, @Result);
  end;

  function GetScreenBufferFontInfo(aHandle: THandle): TFontInfo;
  begin
    with GetBufferFontInfoEx(aHandle) do begin
      Result.FaceName := FaceName;
      Result.Weight := FontWeight;
      Result.Height := dwFontSize.Y;
      Result.Width := dwFontSize.X;
    end;
  end;

  procedure SetScreenBufferFontInfo(aHandle: THandle; FontInfo: TFontInfo);
  var
    InfoEx: CONSOLE_FONT_INFOEX;
  begin
    InfoEx := GetBufferFontInfoEx(aHandle);
    InfoEx.FaceName := FontInfo.FaceName;
    InfoEx.FontWeight := FontInfo.Weight;
    InfoEx.dwFontSize.Y := FontInfo.Height;
    InfoEx.dwFontSize.X := FontInfo.Width;
    SetCurrentConsoleFontEx(aHandle, False, @InfoEx);
  end;

  function TScreenBuffer.GetFontFace: UnicodeString;
  begin
    Result := GetScreenBufferFontInfo(FHandle).FaceName;
  end;

  procedure TScreenBuffer.SetFontFace(Value: UnicodeString);
  var
    FontInfo: TFontInfo;
  begin
    FontInfo := GetScreenBufferFontInfo(FHandle);
    FontInfo.FaceName := Value;
    SetScreenBufferFontInfo(FHandle, FontInfo);
  end;

  function TScreenBuffer.GetFontWeight: Integer;
  begin
    Result := GetScreenBufferFontInfo(FHandle).Weight;
  end;

  procedure TScreenBuffer.SetFontWeight(Value: Integer);
  var
    FontInfo: TFontInfo;
  begin
    FontInfo := GetScreenBufferFontInfo(FHandle);
    FontInfo.Weight := Value;
    SetScreenBufferFontInfo(FHandle, FontInfo);
  end;

  function TScreenBuffer.GetFontWidth: Integer;
  begin
    Result := GetScreenBufferFontInfo(FHandle).Width;
  end;

  procedure TScreenBuffer.SetFontWidth(Value: Integer);
  var
    FontInfo: TFontInfo;
  begin
    FontInfo := GetScreenBufferFontInfo(FHandle);
    FontInfo.Width := Value;
    SetScreenBufferFontInfo(FHandle, FontInfo);
  end;

  function TScreenBuffer.GetFontHeight: Integer;
  begin
    Result := GetScreenBufferFontInfo(FHandle).Height;
  end;

  procedure TScreenBuffer.SetFontHeight(Value: Integer);
  var
    FontInfo: TFontInfo;
  begin
    FontInfo := GetScreenBufferFontInfo(FHandle);
    FontInfo.Height := Value;
    SetScreenBufferFontInfo(FHandle, FontInfo);
  end;

  procedure TScreenBuffer.Activate;
  begin
    SetConsoleActiveScreenBuffer(FHandle);
  end;

  procedure TScreenBuffer.Write(Characters: UnicodeString);
  var
    charsWritten: DWORD;
  begin
    WriteConsoleW(FHandle, PUnicodeChar(Characters), Length(Characters), charsWritten, Nil);
  end;

  procedure TScreenBuffer.Close;
  begin
    CloseHandle(FHandle);
  end;

end.