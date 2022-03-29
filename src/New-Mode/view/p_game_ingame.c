#include "p_game_ingame.h"
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
} IngamePollThreadConfig;

SpinnerConfig *spinner_config;

void *ingame_poll_match_thread(void *args) {
  IngamePollThreadConfig *config = (IngamePollThreadConfig *)args;
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

void view_game_ingame(Match *match) {
  pthread_t tid;
  clear_screen();
  // IngamePollThreadConfig thread_config = {spinner_text, match};

  // if (pthread_create(&tid, NULL, ingame_poll_match_thread, &thread_config)) {
  //   printffn("Error: Failed to create Thread!\n");
  //   exit(-1);
  // }

  render_match_start(match);

  while (match->match_status != ENDED) {
    pause();
  }

  clear_screen();
}

void render_match_start(Match *match) {
  char *line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "Match #%d has started!", match->match_id);
  set_color(GREEN_BG);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0);
  print_char_line('-', 0);
  reset_color();
  clear_line();
  free(line_1);
}

void render_turn_start() {}

void render_turn_end() {}

void render_movement() {}

void render_combat() {}

void render_placement() {}

void render_territories(int player_id) {}

void render_neighbour_nations() {}

void render_attackable_nations() {}

void render_dice_roll() {}

void render_players_info(Match *match) {}
