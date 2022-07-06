unit WinconCursor;

{$mode delphi}

interface

  uses Windows, WinconTypes;

  type

    TCursor = record
      private
        FHandle: THandle;
        FSize: TCursorSize;
        FVisible: Boolean;

        function GetLocation: TScreenCellLocation;
        procedure SetLocation(Value: TScreenCellLocation);

        function GetVisible: Boolean;
        procedure SetVisible(Value: Boolean);

        function GetSize: TCursorSize;
        procedure SetSize(Value: TCursorSize);

        procedure GetInfo;
        procedure SetInfo;
      public
        procedure Init(aHandle: THandle);
        property Location: TScreenCellLocation read GetLocation write SetLocation;
        property Visible: Boolean read GetVisible write SetVisible;
        property Size: TCursorSize read GetSize write SetSize;
    end;

  implementation

    uses WinconUtils;

    procedure TCursor.Init(aHandle: THandle);
    begin
      Fhandle := aHandle;
    end;

    procedure TCursor.GetInfo;
    var
      info: CONSOLE_CURSOR_INFO;
    begin
      if GetConsoleCursorInfo(FHandle, info) then begin
        with info do begin
          FSize := DWordAsCursorSize(dwSize);
          FVisible := bVisible;
        end;
      end;
    end;

    procedure TCursor.SetInfo;
    var
      info: CONSOLE_CURSOR_INFO;
    begin
      with info do begin
        dwSize := CursorSizeAsDword(FSize);
        bVisible := FVisible;
      end;
      SetConsoleCursorInfo(FHandle, @info);
    end;

    function TCursor.GetLocation: TScreenCellLocation;
    begin
      Result := COORDAsScreenCellLocation(GetScreenBufferInfo(FHandle).dwCursorPosition);
    end;

    procedure TCursor.SetLocation(Value: TScreenCellLocation);
    begin
      SetConsoleCursorPosition(FHandle, ScreenCellLocationAsCoord(Value));
    end;

    function TCursor.GetVisible: Boolean;
    begin
      GetInfo;
      Result := FVisible;
    end;

    procedure TCursor.SetVisible(Value: Boolean);
    begin
      FVisible := Value;
      SetInfo;
    end;

    function TCursor.GetSize: TCursorSize;
    begin
      GetInfo;
      Result := FSize;
    end;

    procedure TCursor.SetSize(Value: TCursorSize);
    begin
      FSize := Value;
      SetInfo;
    end;

end.