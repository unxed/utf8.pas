**readme in English is below**

На сегодняшний день популярность языков программирования в значительной степени определяется тем, насколько гладко они работают с самой популярной кодировкой текста — UTF-8 (см. http://utf8everywhere.org/).

К сожалению, во Free Pascal UTF-8 поддерживается не очень хорошо. Например, стандартные функции, такие как Pos и Length, возвращают некорректные значения, если им переданы параметры типа string содержащие текст в UTF-8.

При этом использование string для хранения строк —  наиболе лаконичный и интуитивный способ работы с ними. Новичок в программировании всегда будет использовать этот тип, а не разбираться в различиях между WideString, UnicodeString и UTF8String.

Для решения этой проблемы я написал простейший модуль. Он заменяет стандартные функции для работы со строками, такие как Pos или Length, добавляя поддержку кодировки UTF-8. Такая поддержка применяется, если системная локаль UTF-8 (да, вы можете использовать её и на Windows тоже), и если строка-параметр является формально корректной UTF-8 строкой.

Вам достаточно дописать `uses utf8` в начало вашей программы, чтобы привычные строковые функции начали работать правильно. См. demo.pas

Лицензия: та же, что и у Free Pascal

---

As of today, the popularity of programming languages is largely determined by how seamlessly they work with the most popular text encoding — UTF-8 (see http://utf8everywhere.org/).

Unfortunately, UTF-8 support in Free Pascal is not very strong. For instance, standard functions like `Pos` and `Length` return incorrect values when they are passed `string` type parameters that contain UTF-8 encoded text.

At the same time, using `string` for storing text is the most concise and intuitive way to work with strings. A beginner in programming will always use this type without delving into the differences between `WideString`, `UnicodeString`, and `UTF8String`.

To address this issue, I have written a simple module. It replaces standard string functions like `Pos` and `Length`, adding support for UTF-8 encoding. This support is applied if the system locale is set to UTF-8 (yes, you can use it on Windows as well) and if the string parameter is a formally correct UTF-8 string.

You only need to add `uses utf8` at the beginning of your program to make the usual string functions work correctly. See demo.pas for an example.

License: same as Free Pascal's one
