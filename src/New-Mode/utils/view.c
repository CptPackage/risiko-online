#include "view.h"
#include "io.h"
#include <stdio.h>
#include <string.h>

void print_framed_text_list(char **text_list, char frame_char, int list_size) {
  if (text_list == NULL) {
    printff("Error: print_framed_text_list() called with NULL text_list!\n");
    return;
  }
  print_char_line(frame_char);
  for (int i = 0; i < list_size; i++) {
    print_framed_text(text_list[i], frame_char, false);
  }
  print_char_line(frame_char);
}

void print_framed_text_left(char *text, char frame_char, bool vertical_frame) {
  if (text == NULL) {
    printff("Error: print_framed_text() called with NULL text!\n");
    return;
  }

  if (vertical_frame) {
    print_char_line(frame_char);
  }

  int text_len = strlen(text);
  int padding = LINE_WIDTH - text_len;

  printf("%c", frame_char);
  printf("%s", text);

  for (int i = 0; i < padding - 1; i++) {
    if (i == (padding - 2)) {
      printf(" %c", frame_char);
    } else {
      printf(" ");
    }
  }

  printf("\n\r");
  fflush(stdout);
  if (vertical_frame) {
    print_char_line(frame_char);
  }
}

void print_framed_text(char *text, char frame_char, bool vertical_frame) {
  if (text == NULL) {
    printff("Error: print_framed_text() called with NULL text!\n");
    return;
  }

  if (vertical_frame) {
    print_char_line(frame_char);
  }

  int text_len = strlen(text);
  int padding = LINE_WIDTH - text_len;
  int end_spacing = text_len % 2; // Remove one padding_char from the end if the
                                  // text is odd number of chars
  printf("\r");
  for (int i = 0; i < padding / 2; i++) {
    if (i == 0) {
      printf("%c", frame_char);
    }
    printf(" ");
  }

  printf("%s", text);

  for (int i = 0; i < padding / 2 - end_spacing; i++) {

    if (i == (padding / 2 - end_spacing) - 1) {
      printf(" %c", frame_char);
    } else {
      printf(" ");
    }
  }

  printf("\n\r");
  fflush(stdout);
  if (vertical_frame) {
    print_char_line(frame_char);
  }
}

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
  if (padding_char != -1) {
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
