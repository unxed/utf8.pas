#include <stdio.h>
#include <wchar.h>
#include <locale.h>
#include <string.h>
#include <stdlib.h>

// Reference:
// 16 bytes, 7 code points, 6 screen cells, 5 graphemes

// Экранные ячейки: 6
// Графемы: 5

// Функция для подсчета количества экранных ячеек
int count_screen_cells(const char *str) {
    setlocale(LC_ALL, "");
    int total_width = 0;

    mbstate_t state;
    memset(&state, 0, sizeof(state));

    const char *p = str;
    wchar_t wc;

    while (*p) {
        size_t len = mbrtowc(&wc, p, MB_CUR_MAX, &state);
        if (len == (size_t)-1 || len == (size_t)-2) {
            break;
        }

        int width = wcwidth(wc);
        if (width > 0) {
            total_width += width;
        }

        p += len;
    }

    return total_width;
}

// Функция для подсчета количества графем
int count_graphemes(const char *str) {
    setlocale(LC_ALL, "");
    int count = 0;

    mbstate_t state;
    memset(&state, 0, sizeof(state));

    const char *p = str;
    wchar_t wc;

    while (*p) {
        size_t len = mbrtowc(&wc, p, MB_CUR_MAX, &state);
        if (len == (size_t)-1 || len == (size_t)-2) {
            break;
        }

        // Пропускаем составные символы (диакритические знаки)
        if (!wcwidth(wc) || wc == L'\0') {
            p += len;
            continue;
        }

        count++;
        p += len;
    }

    return count;
}

int main() {
    const char *str = "a1🙂❤️ё";

    int screen_cells = count_screen_cells(str);
    int graphemes = count_graphemes(str);

    printf("\n");
    printf("Строка: %s\n", str);
    printf("Экранные ячейки: %d\n", screen_cells);
    printf("Графемы: %d\n", graphemes);

    return 0;
}
