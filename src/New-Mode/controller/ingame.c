#include <stdlib.h>

static struct {
  enum actions action;
  bool (*control)(void);
} controls[END_OF_ACTIONS] = {
    {.action = JOIN_MATCH, .control = join_match},
    {.action = REVIEW_MATCH_HISTORY, .control = review_match_history},
    {.action = EXIT, .control = exit_menu}};

void controller_ingame(void) {
  while (true) {
    int action = view_main_menu_player();
    if (action >= END_OF_ACTIONS) {
      fprintf(stderr, "Error: unknown action\n");
      continue;
    }
    if (controls[action].control())
      break;

    press_anykey();
  }
}
