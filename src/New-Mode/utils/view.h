#pragma once
#define LINE_WIDTH 89 // Means: 89 of `*` covers a complete line
#define DEFAULT_PADDING_CHAR '-'
#include <stdbool.h>

extern void print_framed_text_list(char **text_list, char frame_char,
                                   int list_size);
extern void print_framed_text_left(char *text, char frame_char,
                                   bool vertical_frame);
extern void print_framed_text(char *text, char frame_char, bool vertical_frame);
extern void print_tabs(int tabs_count);
extern void print_char_line(char spacing_char);
extern void print_dash_line();
extern void print_star_line();
extern void print_padded_text(char *text, char padding_char);
extern void print_menu(char *menu_title, char **labels, char *choices,
                       int labels_num, char padding_char);
