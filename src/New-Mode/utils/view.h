#pragma once
#define LINE_WIDTH 89 // Means: 89 of `*` covers a complete line
#define DEFAULT_PADDING_CHAR '-'

extern void print_tabs(int tabs_count);
extern void print_char_line(char spacing_char);
extern void print_dash_line();
extern void print_star_line();
extern void print_padded_text(char *text, char padding_char);
