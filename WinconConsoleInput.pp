unit WinconConsoleInput;

{$mode delphi}

interface

  uses

    Windows;

  type

    TInputEventType = (ietNone, ietWindowEvent, ietMouseEvent, ietKeyEvent);

    TWindowEventType = (wetNone, wetWindowResized, wetWindowFocus);

    TWindowResizedEvent = record
      Rows: Integer;
      Columns: Integer;
    end;

    TWindowFocusEvent = record
      Focused: Boolean;
    end;

    TMouseCursorLocation = record
      Row: Integer;
      Column: Integer;
    end;

    TControlKeys = record
      CapsLockOn: Boolean;
      EnhancedKey: Boolean;
      LeftAltPressed: Boolean;
      LeftCtrlPressed: Boolean;
      NumLockOn: Boolean;
      RightAltPressed: Boolean;
      RightCtrlPressed: Boolean;
      ScrollLockOn: Boolean;
      ShiftPressed: Boolean;
    end;

    TMouseButtons = record
      Left1Pressed: Boolean;
      Left2Pressed: Boolean;
      Left3Pressed: Boolean;
      Left4Pressed: Boolean;
      RightMostPressed: Boolean;
    end;

    TMouseEventType = (metNone, metMouseCursorMoved, metSingleClick, metDoubleClick, metHorizontalWheel, metVerticalWheel, metButtonReleased);

    TMouseButtonClickedEvent = record
      CursorLocation: TMouseCursorLocation;
      ControlKeys: TControlKeys;
      Buttons: TMouseButtons;
    end;

    TMouseEvent = record
      CursorLocation: TMouseCursorLocation;
      ControlKeys: TControlKeys;
    end;

    TMouseHorizontalWheelDirection = (mhwdRight, mhwdLeft);

    TMouseHorizontalWheelEvent = record
      CursorLocation: TMouseCursorLocation;
      WheelDirection: TMouseHorizontalWheelDirection;
      ControlKeys: TControlKeys;
    end;

    TMouseVerticalWheelDirection = (mvwdForward, mvwdBackwards);

    TMouseVerticalWheelEvent = record
      CursorLocation: TMouseCursorLocation;
      WheelDirection: TMouseVerticalWheelDirection;
      ControlKeys: TControlKeys;
    end;

    TKeyEventType = (ketNone, ketPressed, ketReleased);

    TReleasedKeyEvent = record
      ScanCode: Integer;
      KeyCode: Integer;
      UnicodeChar: UnicodeString;
      ControlKeys: TControlKeys;
    end;

    TPressedKeyEvent = record
      Repetitions: Integer;
      ScanCode: Integer;
      KeyCode: Integer;
      UnicodeChar: UnicodeString;
      ControlKeys: TControlKeys;
    end;

    TConsoleInput = record
      private
        FInputHandle: THandle;

        function GetEchoInputEnabled: Boolean;
        procedure SetEchoInputEnabled(Value: Boolean);
        function GetInsertModeEnabled: Boolean;
        procedure SetInsertModeEnabled(Value: Boolean);
        function GetLineInputEnabled: Boolean;
        procedure SetLineInputEnabled(Value: Boolean);
        function GetMouseInputEnabled: Boolean;
        procedure SetMouseInputEnabled(Value: Boolean);
        function GetProcessedInputEnabled: Boolean;
        procedure SetProcessedInputEnabled(Value: Boolean);
        function GetQuickEditModeEnabled: Boolean;
        procedure SetQuickEditModeEnabled(Value: Boolean);
        function GetWindowInputEnabled: Boolean;
        procedure SetWindowInputEnabled(Value: Boolean);

        procedure Init;

        function GetNextInputEventType: TInputEventType;
        function GetNextMouseEventType: TMouseEventType;

        function GetNextWindowResizedEvent: TWindowResizedEvent;
        function GetNextWindowFocusEvent: TWindowFocusEvent;
        function GetNextMouseButtonClickedEvent: TMouseButtonClickedEvent;
        function GetNextMouseEvent: TMouseEvent;
        function GetNextMouseVerticalWheelEvent: TMouseVerticalWheelEvent;
        function GetNextMouseHorizontalWheelEvent: TMouseHorizontalWheelEvent;

        function GetNextKeyEventType: TKeyEventType;
        function GetNextWindowEventType: TWindowEventType;
        function GetNextPressedKeyEvent: TPressedKeyEvent;
        function GetNextReleasedKeyEvent:TReleasedKeyEvent;
      public
        property EchoInputEnabled: Boolean read GetEchoInputEnabled write SetEchoInputEnabled;
        property InsertModeEnabled: Boolean read GetInsertModeEnabled write SetInsertModeEnabled;
        property LineInputEnabled: Boolean read GetLineInputEnabled write SetLineInputEnabled;
        property MouseInputEnabled: Boolean read GetMouseInputEnabled write SetMouseInputEnabled;
        property ProcessedInputEnabled: Boolean read GetProcessedInputEnabled write SetProcessedInputEnabled;
        property QuickEditModeEnabled: Boolean read GetQuickEditModeEnabled write SetQuickEditModeEnabled;
        property WindowInputEnabled: Boolean read GetWindowInputEnabled write SetWindowInputEnabled;

        property NextInputEventType: TInputEventType read GetNextInputEventType;
        property NextWindowEventType: TWindowEventType read GetNextWindowEventType;
        property NextMouseEventType: TMouseEventType read GetNextMouseEventType;
        property NextKeyEventType: TKeyEventType read GetNextKeyEventType;

        property WindowResizedEvent: TWindowResizedEvent read GetNextWindowResizedEvent;
        property WindowFocusEvent: TWindowFocusEvent read GetNextWindowFocusEvent;
        property KeyPressedEvent: TPressedKeyEvent read GetNextPressedKeyEvent;
        property KeyReleasedEvent: TReleasedKeyEvent read GetNextReleasedKeyEvent;
        property MouseButtonClickedEvent: TMouseButtonClickedEvent read GetNextMouseButtonClickedEvent;
        property MouseButtonReleasedEvent: TMouseEvent read GetNextMouseEvent;
        property MouseCursorMovedEvent: TMouseEvent read GetNextMouseEvent;
        property MouseVerticalWheelEvent: TMouseVerticalWheelEvent read GetNextMouseVerticalWheelEvent;
        property MouseHorizontalWheelEvent: TMouseHorizontalWheelEvent read GetNextMouseHorizontalWheelEvent;

        procedure DiscardNextEvent;
        procedure DiscardNextEvents;
    end;

  var

    ConsoleInput: TConsoleInput;

implementation

  uses

    WinconUtils;

  procedure TConsoleInput.Init;
  begin
    FInputHandle := GetStdHandle(STD_INPUT_HANDLE);
  end;

  function TConsoleInput.GetNextInputEventType:TInputEventType;
  var
    lpcNumberOfEvents: DWORD;
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead : DWORD;
  begin
    Result := ietNone;
    if GetNumberOfConsoleInputEvents(FInputHandle, lpcNumberOfEvents) then begin
      if lpcNumberOfEvents > 0 then begin
        PeekConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
        if lpNumberOfEventsRead <> 0 then begin
          case lpBuffer.EventType of
            FOCUS_EVENT:
              Result := ietWindowEvent;
            MENU_EVENT:
              DiscardNextEvent;
            KEY_EVENT:
              Result := ietKeyEvent;
            _MOUSE_EVENT:
              begin
                Result := ietMouseEvent;
              end;
            WINDOW_BUFFER_SIZE_EVENT:
              Result := ietWindowEvent;
          end;
        end;
      end;
    end;
  end;

  function TConsoleInput.GetEchoInputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_ECHO_INPUT);
  end;

  procedure TConsoleInput.SetEchoInputEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_ECHO_INPUT, Value);
  end;

  function TConsoleInput.GetInsertModeEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_INSERT_MODE);
  end;

  procedure TConsoleInput.SetInsertModeEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_INSERT_MODE, Value);
  end;

  function TConsoleInput.GetLineInputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_LINE_INPUT);
  end;

  procedure TConsoleInput.SetLineInputEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_LINE_INPUT, Value);
  end;

  function TConsoleInput.GetMouseInputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_MOUSE_INPUT);
  end;

  procedure TConsoleInput.SetMouseInputEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_MOUSE_INPUT, Value);
  end;

  function TConsoleInput.GetProcessedInputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_PROCESSED_INPUT);
  end;

  procedure TConsoleInput.SetProcessedInputEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_PROCESSED_INPUT, Value);
  end;

  function TConsoleInput.GetQuickEditModeEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_QUICK_EDIT_MODE);
  end;

  procedure TConsoleInput.SetQuickEditModeEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_QUICK_EDIT_MODE, Value);
  end;

  function TConsoleInput.GetWindowInputEnabled: Boolean;
  begin
    Result := GetModeBit(GetMode(FInputHandle), ENABLE_WINDOW_INPUT);
  end;

  procedure TConsoleInput.SetWindowInputEnabled(Value: Boolean);
  begin
    SetModeBit(FInputHandle, ENABLE_WINDOW_INPUT, Value);
  end;

  procedure TConsoleInput.DiscardNextEvents;
  begin
    FlushConsoleInputBuffer(FInputHandle);
  end;

  function TConsoleInput.GetNextWindowEventType: TWindowEventType;
  var
    lpBuffer: INPUT_RECORD;
    lpNumberOfEventsRead : DWORD;
  begin
    Result := wetNone;
    case NextInputEventType of
      ietWindowEvent: begin
        PeekConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
        case lpBuffer.EventType of
          FOCUS_EVENT:
            Result := wetWindowFocus;
          WINDOW_BUFFER_SIZE_EVENT:
            Result := wetWindowResized;
        end;
      end;
    end;
  end;

  function TConsoleInput.GetNextMouseEventType: TMouseEventType;
  var
    lpBuffer: INPUT_RECORD;
    lpNumberOfEventsRead : DWORD;
  begin
    Result := metNone;
    case NextInputEventType of
      ietMouseEvent: begin
        PeekConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
        case lpBuffer.Event.MouseEvent.dwEventFlags of
          DOUBLE_CLICK:
            Result := metDoubleClick;
          MOUSE_HWHEELED:
            Result := metHorizontalWheel;
          MOUSE_MOVED:
            Result := metMouseCursorMoved;
          MOUSE_WHEELED:
            Result := metVerticalWheel;
          else
            if lpBuffer.Event.MouseEvent.dwButtonState <> 0 then
              Result := metSingleClick
            else
              Result := metButtonReleased;
        end;
      end;
    end;
  end;

  function TConsoleInput.GetNextWindowResizedEvent: TWindowResizedEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    with lpBuffer.Event.WindowBufferSizeEvent.dwSize do begin
      Result.Rows := Y;
      Result.Columns := X;
    end;
  end;

  function TConsoleInput.GetNextWindowFocusEvent: TWindowFocusEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    with lpBuffer.Event.FocusEvent do begin
      Result.Focused := bSetFocus;
    end;
  end;

  procedure AssignMouseLocation(var Location: TMouseCursorLocation; MousePosition: COORD);
  begin
    with MousePosition do begin
      Location.Column := Y;
      Location.Row := X;
    end;
  end;

  procedure AssignControlKeys(var ControlKeys: TControlKeys; ControlKeyState: DWORD);
  begin
    with ControlKeys do begin
      CapsLockOn := ControlKeyState and CAPSLOCK_ON <> 0;
      EnhancedKey := ControlKeyState and ENHANCED_KEY <> 0;
      LeftAltPressed := ControlKeyState and LEFT_ALT_PRESSED <> 0;
      LeftCtrlPressed := ControlKeyState and LEFT_CTRL_PRESSED <> 0;
      NumLockOn := ControlKeyState and NUMLOCK_ON <> 0;
      RightAltPressed := ControlKeyState and RIGHT_ALT_PRESSED <> 0;
      RightCtrlPressed := ControlKeyState and RIGHT_CTRL_PRESSED <> 0;
      ScrollLockOn := ControlKeyState and SCROLLLOCK_ON <> 0;
      ShiftPressed := ControlKeyState and SHIFT_PRESSED <> 0;
    end;
  end;

  function TConsoleInput.GetNextMouseButtonClickedEvent: TMouseButtonClickedEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    with lpBuffer.Event.MouseEvent do begin
      Result.Buttons.Left1Pressed := dwButtonState and FROM_LEFT_1ST_BUTTON_PRESSED <> 0;
      Result.Buttons.Left2Pressed := dwButtonState and FROM_LEFT_2ND_BUTTON_PRESSED <> 0;
      Result.Buttons.Left3Pressed := dwButtonState and FROM_LEFT_3RD_BUTTON_PRESSED <> 0;
      Result.Buttons.Left4Pressed := dwButtonState and FROM_LEFT_3RD_BUTTON_PRESSED <> 0;
      Result.Buttons.RightMostPressed := dwButtonState and RIGHTMOST_BUTTON_PRESSED <> 0;

      AssignMouseLocation(Result.CursorLocation, lpBuffer.Event.MouseEvent.dwMousePosition);
      AssignControlKeys(Result.ControlKeys, lpBuffer.Event.MouseEvent.dwControlKeyState);
    end;
  end;

  function TConsoleInput.GetNextMouseEvent: TMouseEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    AssignMouseLocation(Result.CursorLocation, lpBuffer.Event.MouseEvent.dwMousePosition);
    AssignControlKeys(Result.ControlKeys, lpBuffer.Event.MouseEvent.dwControlKeyState);
  end;

  function TConsoleInput.GetNextMouseVerticalWheelEvent: TMouseVerticalWheelEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    if Smallint(HiWord(lpBuffer.Event.MouseEvent.dwButtonState)) > 0 then
      Result.WheelDirection := mvwdForward
    else
      Result.WheelDirection := mvwdBackwards;
    AssignMouseLocation(Result.CursorLocation, lpBuffer.Event.MouseEvent.dwMousePosition);
    AssignControlKeys(Result.ControlKeys, lpBuffer.Event.MouseEvent.dwControlKeyState);
  end;

  function TConsoleInput.GetNextMouseHorizontalWheelEvent: TMouseHorizontalWheelEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    if Smallint(HiWord(lpBuffer.Event.MouseEvent.dwButtonState)) > 0 then
      Result.WheelDirection := mhwdRight
    else
      Result.WheelDirection := mhwdLeft;
    AssignMouseLocation(Result.CursorLocation, lpBuffer.Event.MouseEvent.dwMousePosition);
    AssignControlKeys(Result.ControlKeys, lpBuffer.Event.MouseEvent.dwControlKeyState);
  end;

  function TConsoleInput.GetNextKeyEventType: TKeyEventType;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    Result := ketNone;
    PeekConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    if lpNumberOfEventsRead <> 0 then begin
      if lpBuffer.Event.KeyEvent.bKeyDown then
        Result := ketPressed
      else
        Result := ketReleased;
    end;
  end;

  function TConsoleInput.GetNextPressedKeyEvent: TPressedKeyEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    with lpBuffer.Event.KeyEvent do begin
      Result.Repetitions := wRepeatCount;
      Result.ScanCode := wVirtualScanCode;
      Result.KeyCode := wVirtualKeyCode;
      Result.UnicodeChar := UnicodeChar;
      AssignControlKeys(Result.ControlKeys, dwControlKeyState);
    end;
  end;

  function TConsoleInput.GetNextReleasedKeyEvent:TReleasedKeyEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
    with lpBuffer.Event.KeyEvent do begin
      Result.ScanCode := wVirtualScanCode;
      Result.KeyCode := wVirtualKeyCode;
      Result.UnicodeChar := UnicodeChar;
      AssignControlKeys(Result.ControlKeys, dwControlKeyState);
    end;
  end;

  procedure TConsoleInput.DiscardNextEvent;
  var
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead: DWORD;
  begin
    ReadConsoleInput(FInputHandle, lpBuffer, 1, lpNumberOfEventsRead);
  end;

  initialization

    ConsoleInput.Init;

end.