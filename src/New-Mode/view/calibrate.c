#include "calibrate.h"
#include "../utils/io.h"
#include "../utils/view.h"

void view_calibrate() {
  bool result;
  while (!result) {
    clear_screen();
    print_star_line();
    print_framed_text(
        "Type [y] if you can see the whole UI in one line un-deformed", '|',
        false);
    print_framed_text("Otherwise resize your screen and type [r] to re-render",
                      '|', false);
    print_star_line();
    result = yes_or_no("Do you want to proceed or re-render?", 'y', 'r', false,
                       true);
  }
}
