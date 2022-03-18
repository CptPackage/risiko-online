#include "view.h"
#include "io.h"
#include <stdio.h>
#include <string.h>

void print_char_line(char spacing_char) {
  for (int i = 0; i < LINE_WIDTH; i++) {
    printf("%c", spacing_char);
  }
  printf("\n");
  fflush(stdout);
}

void print_dash_line() {
  for (int i = 0; i < LINE_WIDTH; i++) {
    printf("-");
  }
  printf("\n");
  fflush(stdout);
}

void print_star_line() {
  for (int i = 0; i < LINE_WIDTH; i++) {
    printf("*");
  }
  printf("\n");
  fflush(stdout);
}

void print_padded_text(char *text, char padding_char) {
  if (text == NULL) {
    print_star_line();
    return;
  }

  int padding = LINE_WIDTH - strlen(text);
  for (int i = 0; i < padding / 2; i++) {
    printf("%c", padding_char);
  }
  if (padding / 2 > 1) {
    printf(" ");
  }
  printf("%s", text);
  for (int i = 0; i < padding / 2; i++) {
    printf("%c", padding_char);
  }
  if (padding / 2 > 1) {
    printf(" ");
  }
  printf("\n");
  fflush(stdout);
}
