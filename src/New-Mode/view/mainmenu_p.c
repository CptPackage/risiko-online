#include "mainmenu_p.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

char choices[] = {'1', '2', '3'};

void view_main_menu_player() {
  clear_screen();
  print_star_line();
  print_padded_text("MAIN MENU", '*');
  print_star_line();
  print_framed_text_left(" [1] Join a Match", '*', false);
  print_framed_text_left(" [2] Watch Match History", '*', false);
  print_framed_text_left(" [3] Exit", '*', false);
  print_star_line();
  multi_choice(NULL, choices, 3);
}
