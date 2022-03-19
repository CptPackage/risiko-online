#include "p_match_result.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

void view_match_result(match_result_t match_result) {
  print_char_line('-');
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
  }
  print_char_line('-');
}
