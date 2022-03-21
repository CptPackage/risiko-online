#include "p_mainmenu.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

void view_main_menu_player() {
  char choices[] = {'1', '2', '3'};
  clear_screen();
  print_star_line();
  print_padded_text("MAIN MENU", '*');
  print_star_line();
  print_framed_text_left(" [1] Join a Match", '*', false, 0);
  print_framed_text_left(" [2] Watch Match History", '*', false, 0);
  print_framed_text_left(" [3] Exit", '*', false, 0);
  print_star_line();
  multi_choice(NULL, choices, 3);
}
