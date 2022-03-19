#include "p_match_result.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

void view_match_result(match_result_t match_result) {
  bool result;
  while (!result) {
    clear_screen();
    print_char_line('-');
    print_framed_text("", '|', false);
    switch (match_result) {
    // QUIT
    case 0:
      print_framed_text("YOU QUIT THE MATCH!", '|', false);
      break;

    // LOST
    case 1:
      print_framed_text("CONGRATULATIONS! YOU WON!", '|', false);
      break;

    // WON
    case 2:
      print_framed_text("YOU LOST!", '|', false);
      break;
    case 3:
      print_framed_text("UNKNOWN match_result_t!", '|', false);
      break;
    }
    print_framed_text("", '|', false);
    print_char_line('-');
    result = yes_or_no("Go to Main Menu", 'y', 'n', true, true);
  }
}
