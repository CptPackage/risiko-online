#pragma once
#define LINE_WIDTH 89 // Means: 89 of `*` covers a complete line
#define DEFAULT_PADDING_CHAR '-'
#include <stdbool.h>

typedef enum {
  CLEAR_FROM_CURSOR_TO_END,
  CLEAR_FROM_CURSOR_TO_BEGIN,
  CLEAR_ALL
} clear_codes;

typedef enum {
  RESET_COLOR,
  BLACK_TXT = 30,
  RED_TXT,
  GREEN_TXT,
  YELLOW_TXT,
  BLUE_TXT,
  MAGENTA_TXT,
  CYAN_TXT,
  WHITE_TXT,

  BLACK_BG = 40,
  RED_BG,
  GREEN_BG,
  YELLOW_BG,
  BLUE_BG,
  MAGENTA_BG,
  CYAN_BG,
  WHITE_BG
} Colors;

typedef struct _spinner_cfg_t {
  bool is_loading;
  bool can_print;
  bool reversed_animation;
} SpinnerConfig;

extern void print_logo(Colors risiko_color, Colors online_color);
extern void print_framed_text_list(char **text_list, char frame_char,
                                   int list_size);
extern void print_framed_text_left(char *text, char frame_char,
                                   bool vertical_frame, Colors color);
extern void print_framed_text(char *text, char frame_char, bool vertical_frame,
                              Colors color);
extern void print_tabs(int tabs_count);
extern void print_char_line(char spacing_char);
extern void print_dash_line();
extern void print_star_line();
extern void print_padded_text(char *text, char padding_char);
extern void print_menu(char *menu_title, char **labels, char *choices,
                       int labels_num, char padding_char);
extern void print_spinner(char *loading_text, SpinnerConfig *config);

extern void clear_line();
extern void clear_screen_to_bottom(void);
extern void clear_screen_to_top(void);
extern void clear_line(void);
extern void clear_line_to_right(void);
extern void clear_line_to_left(void);

extern void move_up(int positions);
extern void move_down(int positions);
extern void move_right(int positions);
extern void move_left(int positions);
extern void move_to(int row, int col);

extern void save_cursor();
extern void restore_cursor();

extern void reset_color();
extern void set_color(Colors color);

/*                      Struct Related utils                      */

SpinnerConfig *get_spinner_config();
bool destroy_spinner_config(SpinnerConfig *config);
