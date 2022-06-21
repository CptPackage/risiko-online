#include "p_lobby.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

int view_lobby(Match **matches, int matches_size) {
  int chosen_match_index;
  clear_screen();
  set_color(GREEN_TXT);
  print_star_line(0);
  print_framed_text("JOIN A MATCH", '*', false, 0, 0);
  print_star_line(0);

  for (int i = 0; i < matches_size; i++) {
    if (matches[i]->match_status == 1) { // Match in Countdown
      set_color(YELLOW_TXT);
    } else {
      set_color(GREEN_TXT);
    }

    render_lobby_match(matches[i], i);
  }

  reset_color();
  clear_line();
}

void render_lobby_match(Match *match, int match_index) {
  char *line_1 = malloc(sizeof(char) * 1024);
  sprintf(line_1, "[%d] Match: %d | Room: %d | Players: %d | Status: %s",
          match_index + 1, match->match_id, match->room_id, match->players_num,
          get_match_status_string(match->match_status));
  print_char_line('-', 0);
  print_framed_text_left(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  free(line_1);
}
