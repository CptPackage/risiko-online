#include "m_mainmenu.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

#define MENU_OPTIONS 4

int view_main_menu_mod() {
  char choices[] = {'1', '2', '3', '4'};
  char op;
  clear_screen();
  set_color(STYLE_BOLD);
  print_star_line(0);
  print_padded_text("MODERATOR MENU", '*', 0);
  print_star_line(0);
  print_framed_text_left(" [1] Create Room", '*', false, 0, 0);
  print_framed_text_left(" [2] View In-Game Matches", '*', false, 0, 0);
  print_framed_text_left(" [3] View Idle Players", '*', false, 0, 0);
  print_framed_text_left(" [4] Exit", '*', false, 0, 0);
  print_star_line(0);
  op = multi_choice(NULL, choices, MENU_OPTIONS);
  reset_color();
  clear_line();
  return op - '1';
}
