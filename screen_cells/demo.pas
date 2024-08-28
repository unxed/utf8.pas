program MyProgram;

//{$codepage UTF8}
{$mode objfpc}{$H+}

uses
  lazutf8,
  cwstring,
  ctypes;

// Объявление внешних функций
function mbrtowc(pwc: PUCS4Char; s: PAnsiChar; n: csize_t; ps: Pointer): csize_t; cdecl; external 'libc';
function wcwidth(wc: cint): cint; cdecl; external 'libc';

// Функция для подсчета количества экранных ячеек
function CountScreenCells(const str: AnsiString): Integer;
var
  mbstate: Pointer;
  wc: UCS4Char;
  p: PAnsiChar;
  len: csize_t;
  totalWidth: Integer;
begin
  totalWidth := 0;
  mbstate := nil; 
  p := PAnsiChar(str);

  while p^ <> #0 do
  begin

    len := mbrtowc(@wc, p, 6, mbstate); 
    if (len = csize_t(-1)) or (len = csize_t(-2)) then
      Break;

    // 128578

    if wcwidth(Integer(wc)) > 0 then
      Inc(totalWidth, wcwidth(Integer(wc)));

    // writeln('-- ', wcwidth(LongInt(wc)), ' - ', wc, ' - ', LongInt(wc), ' - ', len);

    Inc(p, len);
  end;

  Result := totalWidth;
end;

// Функция для подсчета количества графем
function CountGraphemes(const str: AnsiString): Integer;
var
  mbstate: Pointer;
  wc: UCS4Char;
  p: PAnsiChar;
  len: csize_t;
  count: Integer;
begin
  count := 0;
  mbstate := nil; 
  p := PAnsiChar(str);

  while p^ <> #0 do
  begin
    len := mbrtowc(@wc, p, 6, mbstate); 
    if (len = csize_t(-1)) or (len = csize_t(-2)) then
      Break;

    // Пропускаем составные символы (диакритические знаки)
    if (wcwidth(Integer(wc)) = 0) or (wc = UCS4Char(#0)) then
    begin
      Inc(p, len);
      Continue;
    end;

    Inc(count);
    Inc(p, len);
  end;

  Result := count;
end;

var
  s: AnsiString;
  screenCells: Integer;
  graphemes: Integer;

begin
  // 16 bytes, 7 code points, 6 screen cells, 5 graphemes
  s := 'a1🙂❤️ё';

  // Вызов функций подсчета
  screenCells := CountScreenCells(s);
  graphemes := CountGraphemes(s);

  // Вывод результатов
  WriteLn();
  WriteLn('Строка: ', s);
  WriteLn('Количество графем: ', graphemes);
  WriteLn('Количество экранных ячеек: ', screenCells);
  writeln('Количество кодовых точек: ', UTF8Length(s));

  // WriteLn('** Ширина символа: ', wcwidth(128512)); // U+1F600

  // writeln('max: ', csize_t(High(AnsiChar)));

  ReadLn;
end.