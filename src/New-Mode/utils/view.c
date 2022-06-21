#include "view.h"
#include "io.h"
#include "mem.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/*
 *
 *  NOTE: All the functions that take Colors as a parameter, calls reset_color()
 *  before returning when provided with a Colors that isn't 0.
 *
 *  This note is useful when you are calling set_color() and reset_color()
 *  directly in your views.
 *
 */

void print_logo(Colors risiko_color, Colors online_color,
                Colors container_color) {
  set_color(risiko_color);
  print_star_line(container_color);
  set_color(container_color);
  set_color(risiko_color);
  print_framed_text(" :::====  ::: :::===  ::: :::  === :::==== ", '*', false,
                    0, 0);
  print_framed_text(" :::  === ::: :::     ::: ::: ===  :::  ===", '*', false,
                    0, 0);
  print_framed_text(" =======  ===  =====  === ======   ===  ===", '*', false,
                    0, 0);
  print_framed_text(" === ===  ===     === === === ===  ===  ===", '*', false,
                    0, 0);
  print_framed_text(" ===  === === ======  === ===  ===  ====== ", '*', false,
                    0, 0);
  print_framed_text(" ", '*', false, container_color, container_color);
  set_color(container_color);
  set_color(online_color);
  print_framed_text(" :::====  :::= === :::      ::: :::= === :::=====", '*',
                    false, 0, 0);
  print_framed_text(" :::  === :::===== :::      ::: :::===== :::     ", '*',
                    false, 0, 0);
  print_framed_text(" ===  === ======== ===      === ======== ======  ", '*',
                    false, 0, 0);
  print_framed_text(" ===  === ======== ===      === ======== ======  ", '*',
                    false, 0, 0);
  print_framed_text(" ===  === === ==== ===      === === ==== ===     ", '*',
                    false, 0, 0);
  print_framed_text("  ======  ===  === ======== === ===  === ========", '*',
                    false, 0, 0);
  print_star_line(container_color);
  clear_line();
  reset_color();
}

void print_framed_text_list(char **text_list, char frame_char, int list_size) {
  if (text_list == NULL) {
    printff("Error: print_framed_text_list() called with NULL text_list!\n");
    return;
  }
  print_char_line(frame_char, 0);
  for (int i = 0; i < list_size; i++) {
    print_framed_text(text_list[i], frame_char, false, 0, 0);
  }
  print_char_line(frame_char, 0);
}

void print_framed_text_left(char *text, char frame_char, bool vertical_frame,
                            Colors text_color, Colors frame_color) {
  if (text == NULL) {
    printff("Error: print_framed_text() called with NULL text!\n");
    return;
  }

  int text_len = strlen(text);
  int padding = LINE_WIDTH - text_len;

  if (vertical_frame) {
    if (frame_color) {
      reset_color();
      set_color(frame_color);
    }
    print_char_line(frame_char, 0);
  }

  if (frame_color) {
    reset_color();
    set_color(frame_color);
  }
  printf("%c", frame_char);

  if (text_color) {
    reset_color();
    set_color(text_color);
  }
  printf("%s", text);

  for (int i = 0; i < padding - 1; i++) {
    if (i == (padding - 2)) {
      if (text_color) {
        reset_color();
      }

      if (frame_color) {
        reset_color();
        set_color(frame_color);
      }
      printf(" %c", frame_char);
    } else {
      printf(" ");
    }
  }

  printf("\n\r");
  if (vertical_frame) {
    if (frame_color) {
      reset_color();
      set_color(frame_color);
    }
    print_char_line(frame_char, 0);
  }

  if (text_color || frame_color) {
    reset_color();
  }

  fflush(stdout);
}

void print_framed_text(char *text, char frame_char, bool vertical_frame,
                       Colors text_color, Colors frame_color) {
  if (text == NULL) {
    printff("Error: print_framed_text() called with NULL text!\n");
    return;
  }

  int text_len = strlen(text);
  int padding = LINE_WIDTH - text_len;
  int end_spacing = text_len % 2; // Remove one padding_char from the end if the
                                  // text is odd number of chars

  if (vertical_frame) {
    if (frame_color) {
      reset_color();
      set_color(frame_color);
    }
    print_char_line(frame_char, 0);
  }

  printf("\r");
  for (int i = 0; i < padding / 2; i++) {
    if (i == 0) {
      if (frame_color) {
        set_color(frame_color);
      }

      printf("%c", frame_char);

      if (text_color) {
        reset_color();
        set_color(text_color);
      }
    }
    printf(" ");
  }

  printf("%s", text);

  for (int i = 0; i < padding / 2 - end_spacing; i++) {
    if (i == (padding / 2 - end_spacing) - 1) {
      if (text_color) {
        reset_color();
      }

      if (frame_color) {
        set_color(frame_color);
      }

      printf(" %c", frame_char);

      if (text_color) {
        reset_color();
        set_color(text_color);
      }
    } else {
      printf(" ");
    }
  }
  printf("\n\r");

  if (vertical_frame) {
    if (frame_color) {
      reset_color();
      set_color(frame_color);
    }
    print_char_line(frame_char, 0);
  }

  if (text_color || frame_color) {
    reset_color();
  }

  fflush(stdout);
}

void print_error_text(char *text) {
  char *line = malloc(TEXT_LINE_MEM);
  sprintf(line, " [Error] %s", text);
  printff("\n");
  print_framed_text_left(line, '*', true, WHITE_TXT || WHITE_BG, RED_TXT);
  printff("\n");
  free(line);
}

void print_warning_text(char *text) {
  char *line = malloc(TEXT_LINE_MEM);
  sprintf(line, " [Warning] %s", text);
  printff("\n");
  print_framed_text_left(line, '*', true, WHITE_TXT || WHITE_BG, YELLOW_TXT);
  printff("\n");
  free(line);
}

void print_info_text(char *text) {
  char *line = malloc(TEXT_LINE_MEM);
  sprintf(line, " [Info] %s", text);
  printff("\n");
  print_framed_text_left(line, '*', true, WHITE_TXT || WHITE_BG,
                         WHITE_TXT || WHITE_BG);
  printff("\n");
  free(line);
}

void print_tabs(int tabs_count, Colors color) {
  if (tabs_count == 0) {
    return;
  }
  printf("\r");
  if (color) {
    set_color(color);
  }
  for (int i = 0; i < tabs_count; i++) {
    printf("\t");
  }

  if (color) {
    reset_color();
  }

  fflush(stdout);
}

void print_char_line(char spacing_char, Colors color) {
  printf("\r");
  if (color) {
    set_color(color);
  }
  for (int i = 0; i < LINE_WIDTH + 1; i++) {
    printf("%c", spacing_char);
  }
  printf("\n");

  if (color) {
    reset_color();
  }

  fflush(stdout);
}

void print_dash_line(Colors color) {
  printf("\r");
  if (color) {
    set_color(color);
  }
  for (int i = 0; i < LINE_WIDTH + 1; i++) {
    printf("-");
  }
  printf("\n");
  if (color) {
    reset_color();
  }
  fflush(stdout);
}

void print_star_line(Colors color) {
  printf("\r");
  if (color) {
    set_color(color);
  }
  for (int i = 0; i < LINE_WIDTH + 1; i++) {
    printf("*");
  }
  printf("\n");
  if (color) {
    reset_color();
  }

  fflush(stdout);
}

void print_padded_text(char *text, char padding_char, Colors color) {
  if (text == NULL) {
    print_star_line(color);
    return;
  }

  int text_len = strlen(text);
  int padding = LINE_WIDTH - text_len;
  int end_spacing = text_len % 2; // Remove one padding_char from the end if the
  // text is odd number of chars

  if (color) {
    set_color(color);
  }

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

  if (color) {
    reset_color();
  }
  fflush(stdout);
}

void print_menu(char *menu_title, char **labels, char *choices, int labels_num,
                char padding_char) {
  if (labels == NULL || choices == NULL) {
    print_char_line('X', 0);
    printff("ERROR: Wrong args to print_menu()!\n");
    print_char_line('X', 0);
    return;
  }

  char _padding_char = '-';
  if (padding_char != -1) {
    _padding_char = padding_char;
  }

  if (menu_title != NULL) {
    print_char_line(_padding_char, 0);
    print_padded_text(menu_title, _padding_char, 0);
  }

  print_char_line(_padding_char, 0);
  for (int i = 0; i < labels_num; i++) {
    printf("\r[%c]-> <%s>\n", choices[i], labels[i]);
  }
  print_char_line(_padding_char, 0);
  printf("\n\r");
  fflush(stdout);
}

void print_spinner(char *loading_text, SpinnerConfig *config) {
  printff("\r");
  const char *spinners[] = {"⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾"};
  const char *spinners_reversed[] = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"};
  const int spinners_size = 8;
  char **text = malloc(sizeof(char **));
  *text = loading_text;
  if (loading_text == NULL) {
    *text = "Loading...";
  }

  if (config->color) {
    set_color(config->color);
  }

  int i = 0;
  while (config->is_loading) {
    if (config->can_print) {
      if (config->reversed_animation) {
        printff("\r %s - %s", spinners_reversed[i], *text);
      } else {
        printff("\r %s - %s", spinners[i], text[0]);
      }
      i = (i + 1) % spinners_size;
      usleep(100000);
      clear_line();
    }
  }

  if (config->color) {
    reset_color();
  }
}

void clear_screen_to_bottom(void) {
  printf("\033[%dJ", CLEAR_FROM_CURSOR_TO_END);
}
void clear_screen_to_top(void) {
  printf("\033[%dJ", CLEAR_FROM_CURSOR_TO_BEGIN);
}
void clear_line(void) { printf("\033[%dK", CLEAR_ALL); }
void clear_line_to_right(void) { printf("\033[%dK", CLEAR_FROM_CURSOR_TO_END); }
void clear_line_to_left(void) {
  printf("\033[%dK", CLEAR_FROM_CURSOR_TO_BEGIN);
}

void move_up(int positions) { printf("\033[%dA", positions); }

void move_down(int positions) { printf("\033[%dB", positions); }

void move_right(int positions) { printf("\033[%dC", positions); }

void move_left(int positions) { printf("\033[%dD", positions); }

void move_to(int row, int col) { printf("\033[%d;%df", row, col); }

void save_cursor() { printff("\033%d", 7); }
void restore_cursor() { printff("\033%d", 8); }

void reset_color() { printff("\033[0m"); }

void set_color(Colors color) { printff("\x1b[%dm", color); }

/*                      Struct Related utils                      */

SpinnerConfig *get_spinner_config() {
  SpinnerConfig *config = malloc(sizeof(SpinnerConfig));
  config->is_loading = true;
  config->can_print = true;
  config->reversed_animation = false;
  return config;
}

bool destroy_spinner_config(SpinnerConfig *config) { free(config); }
