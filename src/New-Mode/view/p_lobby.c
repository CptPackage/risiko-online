#include "p_lobby.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

extern char *match_status_strings[MATCH_STATUS_NUM];

void view_lobby(Match **matches, int matches_size) {
  clear_screen();
  print_star_line();
  print_framed_text("JOIN A MATCH", '*', false);
  print_star_line();

  for (int i = 0; i < matches_size; i++) {
    printffn("");
    render_lobby_match(matches[i], i);
  }
}

void render_lobby_match(Match *match, int match_index) {
  char *line_1 = malloc(sizeof(char) * 1024);
  sprintf(line_1, "[%d] Match: %d | Room: %d | Players: %d | Status: %s",
          match_index, match->match_id, match->room_id, match->players_num,
          match_status_strings[match->match_status]);
  print_char_line('-');
  print_framed_text_left(line_1, '|', false);
  print_char_line('-');
  free(line_1);
}
