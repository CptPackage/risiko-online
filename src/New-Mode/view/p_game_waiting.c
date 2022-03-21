#include "p_game_waiting.h"
#include "../model/p_match.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "../utils/view.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct _poll_thread_config {
  char *spinner_text;
  Match *match;
} WaitingPollThreadConfig;

SpinnerConfig *spinner_config;

void *waiting_poll_match_thread(void *args) {
  WaitingPollThreadConfig *config = (WaitingPollThreadConfig *)args;
  int i = 0;
  while (config->match->match_status != STARTED) {
    /* Logic to fetch data from database and update match status */
    if (config->match->match_status == COUNTDOWN) {
      sprintf(config->spinner_text, "# of players: %d", i);
      i = i + 1;
      sleep(2);
    }
    if (i == 6) {
      config->match->match_status = STARTED;
      spinner_config->is_loading = false;
    }
  }
}

void view_game_waiting(Match *match) {
  clear_screen();
  char *line_1 = malloc(TEXT_LINE_MEM);
  char *line_2 = malloc(TEXT_LINE_MEM);
  char *spinner_text = malloc(TEXT_LINE_MEM);
  match_status_t initial_status = match->match_status;
  pthread_t tid;
  sprintf(line_1, "Status: %s", get_match_status_string(match->match_status));
  sprintf(line_2, "Room #%d", match->room_id);
  print_char_line('-');
  print_framed_text(line_1, '|', false, 0);
  print_char_line('-');
  print_framed_text(line_2, '|', false, 0);
  print_char_line('-');

  WaitingPollThreadConfig thread_config = {spinner_text, match};

  if (pthread_create(&tid, NULL, waiting_poll_match_thread, &thread_config)) {
    printffn("Error: Failed to create Thread!\n");
    exit(-1);
  }

  int x;

  while (match->match_status != STARTED) {
    if (match->match_status != initial_status) {
      initial_status = match->match_status;
      move_to(2, 0);
      sprintf(line_1, "Status: %s",
              get_match_status_string(match->match_status));
      print_framed_text(line_1, '|', false, GREEN_TXT);
      move_down(3);
    }

    if (match->match_status == COUNTDOWN) {
      spinner_config = get_spinner_config();
      print_spinner(spinner_text, spinner_config);
      destroy_spinner_config(spinner_config);
    } else if (match->match_status == LOBBY) {
      printff("LOBBY IN COUNTDOWN TAKE YOUR ACTION: ");
      scanf("%d", &x);
      move_up(1);
      clear_line();
      switch (x) {
      case 0:
        match->match_status = COUNTDOWN;
        break;
      case 1:
        match->match_status = STARTED;
        break;
      }
    }
  }
  clear_screen();

  print_framed_text("MATCH STARTED!", ' ', false, 0);

  free(line_1);
  free(line_2);
  free(spinner_text);
}
