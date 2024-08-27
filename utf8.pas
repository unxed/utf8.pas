unit utf8;

{$H+}

interface

uses
  cwstring,
  {$IFDEF UNIX}BaseUnix, {$ENDIF}
  {$IFDEF WINDOWS}Windows, {$ENDIF}
  SysUtils, Classes, Process, StrUtils;

function IsSystemLocaleUTF8: Boolean;
function IsValidUTF8(const Str: string): Boolean;
function Pos(substr: string; str: string): integer;
function Length(const s: string): Integer;
function Copy(const s: string; Index, Count: Integer): string;
procedure Delete(var s: string; Index, Count: Integer);
procedure Insert(const s1, s2: string; Index: Integer; var result: string);
function Trim(const s: string): string;
function UpperCase(const s: string): string;
function LowerCase(const s: string): string;
function Concat(const s1, s2, s3: string): string;
//no need: replace works the same way for ascii and utf8
//function StringReplace(const s, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;

implementation

var
  LocaleChecked: boolean;
  LocaleIsUTF8:  boolean;

function IsSystemLocaleUTF8: Boolean;
{$IFDEF WINDOWS}
var
  codePage: Integer;
begin
  if LocaleChecked then
  begin
    IsSystemLocaleUTF8 := LocaleIsUTF8;
    Exit;
  end;
  
  // Получаем кодовую страницу для текущей локали в Windows
  codePage := GetACP;
  IsSystemLocaleUTF8 := (codePage = CP_UTF8);

  LocaleChecked := true;
  LocaleIsUTF8  := IsSystemLocaleUTF8;
end;
{$ELSE}
var
  localeOutput: TStringList;
  localeInfo: string;
  foundUTF8: Boolean;
begin
  if LocaleChecked then
  begin
    IsSystemLocaleUTF8 := LocaleIsUTF8;
    Exit;
  end;

  foundUTF8 := False;
  localeOutput := TStringList.Create;

    // Выполняем команду locale и получаем вывод
    with TProcess.Create(nil) do
    begin

      Executable := 'locale';
      ShowWindow := swoHide;
      Options := [poUsePipes, poNoConsole];
      Execute;
      localeOutput.LoadFromStream(Output);

      Free;
    end;

    // Проверяем вывод на наличие 'UTF-8'
    for localeInfo in localeOutput do
    begin
      if System.Pos('UTF-8', localeInfo) > 0 then
      begin
        foundUTF8 := True;
        Break;
      end;
    end;

    IsSystemLocaleUTF8 := foundUTF8;

    localeOutput.Free;

    LocaleChecked := true;
    LocaleIsUTF8  := IsSystemLocaleUTF8;
end;
{$ENDIF}

function IsValidUTF8(const Str: string): Boolean;
var
  I: Integer;
  CodePoint: Integer;
  BytesRemaining: Integer;
  OutVal: Boolean;
begin
  OutVal := True;
  BytesRemaining := 0;
  CodePoint := 0;

  for I := 1 to System.Length(Str) do
  begin
    
    // Get the next byte.
    CodePoint := Ord(Str[I]);

    // Check if it's a continuation byte.
    if (CodePoint and $C0) = $80 then
    begin
      // It's a continuation byte.
      if BytesRemaining > 0 then
      begin
        // We're expecting more continuation bytes.
        CodePoint := (CodePoint and $3F) or (CodePoint shr 6);
        BytesRemaining := BytesRemaining - 1;
      end
      else
      begin
        // Unexpected continuation byte.
        IsValidUTF8 := False;
        Exit;
      end;
    end
    else
    begin
      // It's a starting byte.
      if BytesRemaining > 0 then
      begin
        // Incomplete multi-byte sequence.
        IsValidUTF8 := False;
        Exit;
      end;

      // Determine the number of bytes in the sequence.
      if (CodePoint and $80) = $00 then
        BytesRemaining := 0 // 1-byte sequence
      else if (CodePoint and $E0) = $C0 then
        BytesRemaining := 1 // 2-byte sequence
      else if (CodePoint and $F0) = $E0 then
        BytesRemaining := 2 // 3-byte sequence
      else if (CodePoint and $F8) = $F0 then
        BytesRemaining := 3 // 4-byte sequence
      else
      begin
        // Invalid starting byte.
        IsValidUTF8 := False;
        Exit;
      end;

      CodePoint := (CodePoint and (not ($80 shr BytesRemaining))) shl (6 * BytesRemaining);
    end;

  end;

  // Check if there are any incomplete sequences.
  IsValidUTF8 := OutVal and (BytesRemaining = 0);
end;

function Pos(substr: string; str: string): integer;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(substr) and IsValidUTF8(str) then
    Pos := system.pos(UTF8Decode(substr), UTF8Decode(str))
  else
    Pos := system.pos(substr, str);
end;

function Length(const s: string): Integer;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) then
    Length := System.Length(UTF8Decode(s))
  else
    Length := System.Length(s);
end;

function Copy(const s: string; Index, Count: Integer): string;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) then
    Copy := UTF8Encode(System.Copy(UTF8Decode(s), Index, Count))
  else
    Copy := System.Copy(s, Index, Count);
end;

procedure Delete(var s: string; Index, Count: Integer);
var
  s2: UnicodeString;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) then
  begin
    s2 := UTF8Decode(s);
    System.Delete(s2, Index, Count);
    s := UTF8Encode(s2);
  end
  else
    System.Delete(s, Index, Count);
end;

procedure Insert(const s1, s2: string; Index: Integer; var result: string);
var
  s3u: UnicodeString;
  s3: String;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s1) and IsValidUTF8(s2) then
  begin
	s3u := UTF8Decode(s2);
    System.Insert(UTF8Decode(s1), s3u, Index);
    result := UTF8Encode(s3u);
  end
  else
  begin
    s3 := s2;
    System.Insert(s1, s3, Index);
    result := s3;
  end;
end;

function Trim(const s: string): string;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) then
    Trim := UTF8Encode(SysUtils.Trim(UTF8Decode(s)))
  else
    Trim := SysUtils.Trim(s);
end;

function UpperCase(const s: string): string;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) then
    UpperCase := UTF8Encode(SysUtils.UpperCase(UTF8Decode(s)))
  else
    UpperCase := SysUtils.UpperCase(s);
end;

function LowerCase(const s: string): string;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) then
    LowerCase := UTF8Encode(System.LowerCase(UTF8Decode(s)))
  else
    LowerCase := System.LowerCase(s);
end;

function Concat(const s1, s2, s3: string): string;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s1) and IsValidUTF8(s2) and IsValidUTF8(s3) then
    Concat := UTF8Encode(System.Concat(UTF8Decode(s1), UTF8Decode(s2), UTF8Decode(s3)))
  else
    Concat := System.Concat(s1, s2, s3);
end;

function StringReplace(const s, OldPattern, NewPattern: string; Flags: TReplaceFlags): string;
begin
  if IsSystemLocaleUTF8() and IsValidUTF8(s) and IsValidUTF8(OldPattern) and IsValidUTF8(NewPattern) then
    StringReplace := UTF8Encode(SysUtils.UnicodeStringReplace(UTF8Decode(s), UTF8Decode(OldPattern), UTF8Decode(NewPattern), Flags))
  else
    StringReplace := SysUtils.StringReplace(s, OldPattern, NewPattern, Flags);
end;

initialization
  (*
  SetMultiByteConversionCodePage(CP_UTF8);
  SetMultiByteFileSystemCodePage(CP_UTF8);
  SetMultiByteRTLFileSystemCodePage(CP_UTF8);
  *)

  LocaleChecked := false;
  LocaleIsUTF8  := false;
end.
