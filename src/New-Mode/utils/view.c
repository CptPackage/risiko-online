#include "view.h"
#include "io.h"
#include <stdio.h>
#include <string.h>

// void print_framed_text(char *text, char frame_char) {
//   int usable_space = LINE_WIDTH - 2;
//   int text_len = strlen(text);
//   int lines_num = 1;
//   if (text_len > usable_space) {
//     lines_num = usable_space / text_len;
//   }
//   int char_count = 0;
//
//   printf_char_line(frame_char);
//
//   int padding = usable_space - text_len;
//
//   for (int i = 0; i < padding / 2; i++) {
//     printf("%c", padding_char);
//   }
//   if (padding / 2 > 1) {
//     printf(" ");
//   }
//   printf("%s", text);
//   for (int i = 0; i < padding / 2; i++) {
//     printf("%c", padding_char);
//   }
//   if (padding / 2 > 1) {
//     printf(" ");
//   }
//   printf("\n");
//   fflush(stdout);
//
//   // for (int i = 0; i < text_len; i++) {
//   //   printf("%c", frame_char);
//   //   for (int j = 0; j < usable_space; j++) {
//   //     printf("%c", text[i + j]);
//   //   }
//   //   if (i + j >= text_len) {
//   //     break;
//   //   }
//   //   printf("%c\n", frame_char);
//   // }
//   printf_char_line(frame_char);
// }

void print_tabs(int tabs_count) {
  if (tabs_count == 0) {
    return;
  }
  printf("\r");
  for (int i = 0; i < tabs_count; i++) {
    printf("\t");
  }
  fflush(stdout);
}

void print_char_line(char spacing_char) {
  printf("\r");
  for (int i = 0; i < LINE_WIDTH + 1; i++) {
    printf("%c", spacing_char);
  }
  printf("\n");
  fflush(stdout);
}

void print_dash_line() {
  printf("\r");
  for (int i = 0; i < LINE_WIDTH + 1; i++) {
    printf("-");
  }
  printf("\n");
  fflush(stdout);
}

void print_star_line() {
  printf("\r");
  for (int i = 0; i < LINE_WIDTH + 1; i++) {
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
  int text_len = strlen(text);
  int padding = LINE_WIDTH - text_len;
  int end_spacing = text_len % 2; // Remove one padding_char from the end if the
                                  // text is odd number of chars
  printf("\r");
  for (int i = 0; i < padding / 2; i++) {
    printf("%c", padding_char);
  }
  if (padding / 2 > 1) {
    printf(" ");
  }
  printf("%s", text);
  if (padding / 2 > 1) {
    printf(" ");
  }
  for (int i = 0; i < padding / 2 - end_spacing; i++) {
    printf("%c", padding_char);
  }
  printf("\n\r");
  fflush(stdout);
}

void print_menu(char *menu_title, char **labels, char *choices, int labels_num,
                char padding_char) {
  if (labels == NULL || choices == NULL) {
    print_char_line('X');
    printff("ERROR: Wrong args to print_menu()!\n");
    print_char_line('X');
    return;
  }

  char _padding_char = '-';
  if (padding_char != NULL) {
    _padding_char = padding_char;
  }

  if (menu_title != NULL) {
    print_char_line(_padding_char);
    print_padded_text(menu_title, _padding_char);
  }

  print_char_line(_padding_char);
  for (int i = 0; i < labels_num; i++) {
    printf("\r[%c]-> <%s>\n", choices[i], labels[i]);
  }
  print_char_line(_padding_char);
  printf("\n\r");
  fflush(stdout);
}
