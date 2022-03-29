#include "calibrate.h"
#include "../utils/io.h"
#include "../utils/view.h"

void view_calibrate() {
  bool result;
  while (!result) {
    clear_screen();
    set_color(YELLOW_TXT);
    print_star_line(0);
    print_framed_text(
        "Type [y] if you can see the whole UI in one line un-deformed", '|',
        false, 0);
    print_framed_text("Otherwise resize your screen and type [r] to re-render",
                      '|', false, 0);
    print_star_line(0);
    result = yes_or_no("Do you want to proceed or re-render?", 'y', 'r', false,
                       true);
    reset_color();
  }
}
