program Test;

{$H+}

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
  s:='Привет, мир!';
  WriteLn(pos('мир', s)); // should be 9
  WriteLn(length('мир')); // should be 3

  WriteLn();

  // charset utf-8
  s:='РџСЂРёРІРµС‚, РјРёСЂ!'; // 'РјРёСЂ' at pos 9
  WriteLn(pos('РјРёСЂ', s)); // should be 9, 15 without utf8 module
  WriteLn(length('РјРёСЂ')); // should be 3, 6 without utf8 module

  WriteLn();
	
end.
