unit WinconTypes;

{$mode delphi}

interface

  type

    TCursorSize = 1..100;

    TPaletteColorIndex = 0..$f;

    TScreenCellLocation = record
      Row: Integer;
      Column: Integer;
    end;

    TScreenCellsAttributes = array of Word;

    TScreenCell = record
      Character: WideChar;
      CellAttributes: Word;
    end;

    TScreenCells = array of TScreenCell;

    TScreenAreaSize = record
      Height: Integer;
      Width: Integer;
    end;

    TScreenArea = record
      Location: TScreenCellLocation;
      Size: TScreenAreaSize;
    end;

    TColor = packed record
      R: Byte;
      G: Byte;
      B: Byte;
      X: Byte;
    end;

    TColorPalette = array [0..$f] of TColor;

    TFontInfo = record
      FaceName: UnicodeString;
      Weight: Integer;
      Height: Integer;
      Width: Integer;
    end;


implementation

end.