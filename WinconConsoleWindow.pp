unit WinconConsoleWindow;

{$mode delphi}

interface

  uses Windows;

  type

    TConsoleWindow = record
      private
        FInputHandle: THandle;
        FOutputHandle: THandle;
        FWindowHandle: HWND;

        function GetTitle: WideString;
        procedure SetTitle(Value: WideString);
        function GetFullScreen: Boolean;
        procedure SetFullScreen(Value: Boolean);

        procedure Init;
      public
        property Title: WideString read GetTitle write SetTitle;
        property FullScreen: Boolean read GetFullScreen write SetFullScreen;
    end;

  var

    ConsoleWindow: TConsoleWindow;

implementation

  procedure TConsoleWindow.Init;
  begin
    FInputHandle := GetStdHandle(STD_INPUT_HANDLE);
    FOutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    FWindowHandle := GetConsoleWindow;
  end;

  type

    TTitleChars = array [0..2048] of char;

  function TConsoleWindow.GetTitle: WideString;
  var
    Chars: TTitleChars;
  begin
    if (GetConsoleTitle(Chars, SizeOf(TTitleChars))  <> 0) then begin
      Result := Chars;
    end;
  end;

  procedure TConsoleWindow.SetTitle(Value: WideString);
  var
    Chars: TTitleChars;
  begin
    Chars := Value;
    SetConsoleTitle(Chars);
  end;

  function TConsoleWindow.GetFullScreen: Boolean;
  var
    lsModeFlags: DWORD;
  begin
    Result := False;
    if GetConsoleDisplayMode(@lsModeFlags) then begin
      case lsModeFlags of
        CONSOLE_FULLSCREEN: Result := True;
      end;
    end;
  end;

  procedure TConsoleWindow.SetFullScreen(Value: Boolean);
  var
    lpNewScreenBufferDimensions: COORD;
    Mode: DWORD;
  begin
    if Value then
      Mode := CONSOLE_FULLSCREEN_MODE
    else
      Mode := CONSOLE_WINDOWED_MODE;
    SetConsoleDisplayMode(FOutputHandle, Mode, @lpNewScreenBufferDimensions);
  end;

  initialization

    ConsoleWindow.Init;

end.