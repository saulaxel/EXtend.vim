#include <stdio.h>
enum { LINES = 10, COLUMNS =10 };
int main(void)
{
    int matrix[LINES][COLUMNS];

    for (int i = 0; i < 10; i++) {
        puts("Processing . . .");
    }
    for (int line = 0; line < LINES; line++) {
        for (size_t col = 0; col < COLUMNS; col++) {
            printf("%d ", matrix[line][col]);
        }
        putchar('\n');
    }
    for (size_t j = 0; j < 20; j++) {
        puts("More processing . . .");
    }
}
