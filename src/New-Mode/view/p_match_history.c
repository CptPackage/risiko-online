#include "p_match_history.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>
#include <stdlib.h>

char *match_results_strings[] = {"QUIT", "LOST", "WON"};

void view_match_history_list(MatchLog **logs, int logs_size) {
  clear_screen();
  print_star_line();
  print_padded_text("MATCHES HISTORY", '*');
  print_star_line();

  for (int i = 0; i < logs_size; i++) {
    printffn("");
    render_match_log(logs[i]);
  }
}

void render_match_log(MatchLog *log) {
  char *line_1 = malloc(sizeof(char) * 1024);
  char *line_2 = malloc(sizeof(char) * 1024);
  sprintf(line_1, " Match: %d - Room: %d", log->match_id, log->room_id);
  sprintf(line_2, " Start: %s - End: %s", log->start_time, log->end_time);
  print_star_line();
  print_framed_text(match_results_strings[log->result], '*', false);
  print_star_line();
  print_framed_text_left(line_1, '*', false);
  print_framed_text_left(line_2, '*', false);
  print_star_line();
  free(line_1);
  free(line_2);
}
