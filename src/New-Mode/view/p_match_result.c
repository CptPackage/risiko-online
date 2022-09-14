#include "p_match_result.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

void view_match_result(match_result_t match_result) {
  bool result;
  while (!result) {
    clear_screen();
    set_color(STYLE_BOLD);
    set_color(BLACK_BG);
    print_star_line(0);
    print_padded_text("MATCH RESULT", '*', 0);
    print_star_line(0);
    print_char_line('-', 0);
    print_framed_text("", '|', false, 0, 0);
    switch (match_result) {
    // LOST
    case 0:
      print_framed_text("YOU HAVE BEEN ELIMINATED!", '|', false, RED_TXT, STYLE_BOLD);
      break;

    // WON
    case 1:
      print_framed_text("CONGRATULATIONS! YOU WON!", '|', false, GREEN_TXT, STYLE_BOLD);
      break;

    default:
      print_framed_text("UNKNOWN match_result_t!", '|', false, 0, STYLE_BOLD);
      break;
    }
    set_color(STYLE_BOLD);
    set_color(BLACK_BG);
    print_framed_text("", '|', false, 0, 0);
    print_char_line('-', 0);
    result = yes_or_no("Go to Main Menu", 'y', 'n', true, true);
  }
  reset_color();
}
