program Test;

{$H+} // aliases string (without a specified length) to AnsiString

uses
  utf8;

var
  s: string;

begin

//  (*
  Write('Locale is UTF-8: ');
  WriteLn(IsSystemLocaleUTF8());

  WriteLn();
//  *)

  // charset 1251 (windows cyrillic)
  s:='������, ���!';
  WriteLn(pos('���', s)); // should be 9
  WriteLn(length('���')); // should be 3
  WriteLn('Кодировка: ', StringCodePage(s)); // 0 with $H+, 65001 without

  WriteLn();

  // charset utf-8
  s:='Привет, мир!'; // 'мир' at pos 9
  WriteLn(pos('мир', s)); // should be 9, 15 without utf8 module
  WriteLn(length('мир')); // should be 3, 6 without utf8 module
  WriteLn('Кодировка: ', StringCodePage(s)); // 0 with $H+, 65001 without

  WriteLn();
	
end.
