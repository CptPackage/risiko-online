#include "m_mainmenu.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

void view_main_menu_mod() {
  char choices[] = {'1', '2', '3', '4'};
  clear_screen();
  print_star_line();
  print_padded_text("MODERATOR MENU", '*');
  print_star_line();
  print_framed_text_left(" [1] Create Room", '*', false);
  print_framed_text_left(" [2] View In-Game Matches", '*', false);
  print_framed_text_left(" [3] View Idle Players", '*', false);
  print_framed_text_left(" [4] Exit", '*', false);
  print_star_line();
  multi_choice(NULL, choices, 4);
}
