#include "p_match_history.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

char *match_results_strings[] = {"ELIMINATED", "WON"};

void view_match_history(Matches_Logs_List*logs) {
  clear_screen();
  set_color(GREEN_TXT);
  set_color(STYLE_BOLD);
  print_star_line(0);
  print_padded_text("MATCHES HISTORY", '*', 0);
  print_star_line(0);
  reset_color();
  
  if(logs->logs_count == 0){
    set_color(YELLOW_TXT);
    print_char_line('-', 0);
    set_color(STYLE_BOLD);
    print_framed_text("You haven't participated in any match yet!", '|', false, 0, 0);
    set_color(STYLE_NORMAL);
    set_color(YELLOW_TXT);
    print_char_line('-', 0);
  }

  for (int i = 0; i < logs->logs_count; i++) {
    render_match_log(logs->logs[i]);
  }
  reset_color();
  clear_line();
}

void render_match_log(Match_Log log) {
  switch (log.result) {
  case 0:
    set_color(RED_TXT);
    break;
  case 1:
    set_color(GREEN_TXT);
    break;
  }
  char *line_1 = malloc(sizeof(char) * 1024);
  char *line_2 = malloc(sizeof(char) * 1024);
  sprintf(line_1, " Room: %d - Match: %d", log.room_id, log.match_id);
  sprintf(line_2, "  %s -> %s", log.start_time, log.end_time);
  print_char_line('-', 0);
  print_framed_text(match_results_strings[log.result], '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_1, '*', false, 0, 0);
  print_framed_text(line_2, '*', false, 0, 0);
  print_char_line('-', 0);
  free(line_1);
  free(line_2);
}
