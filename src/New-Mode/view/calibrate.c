#include "calibrate.h"
#include "../utils/io.h"

void view_calibrate() {
  bool result;
  while (!result) {
    clear_screen();
    printffn("*****************************************************************"
             "************************");
    printffn("---------------- Type [y] if you can see the whole phrase in one "
             "line -------------------");
    printffn("---------------- Otherwise resize your screen and type [r] to "
             "re-render -----------------");
    printffn("*****************************************************************"
             "************************");
    result = yes_or_no("Do you want to proceed or re-render?", 'y', 'r', false,
                       true);
  }
}
