#include <stdio.h>
#include <wchar.h>
#include <locale.h>
#include <string.h>
#include <stdlib.h>
#include <uchar.h>

int main() {
  // Установка локали для корректного определения MB_CUR_MAX
  if (!setlocale(LC_CTYPE, "")) {
    fprintf(stderr, "Не удалось установить локаль.\n");
    return 1;
  }

  // Вывод значения MB_CUR_MAX
  printf("MB_CUR_MAX = %ld\n", MB_CUR_MAX);

  return 0;
}