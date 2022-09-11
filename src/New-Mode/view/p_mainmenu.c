#include "p_mainmenu.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include "../model/session.h"
#include <stdio.h>

#define P_MAIN_MENU_CHOICES_NUM 3

int view_main_menu_player() {
  char choices[P_MAIN_MENU_CHOICES_NUM] = {'1', '2', '3'};
  char op;
  clear_screen();
  set_color(STYLE_BOLD);
  set_color(GREEN_TXT);
  print_star_line(0);
  print_padded_text("MAIN MENU", '*', 0);
  print_padded_text(current_user, '*', 0);
  print_star_line(0);
  print_framed_text_left(" [1] Join a Match", '*', false, 0, 0);
  print_framed_text_left(" [2] Watch Match History", '*', false, 0, 0);
  print_framed_text_left(" [3] Exit", '*', false, 0, 0);
  print_star_line(0);
  clear_line();
  op = multi_choice(NULL, choices, P_MAIN_MENU_CHOICES_NUM);
  reset_color();
  clear_line();
  return op - '1';
}
