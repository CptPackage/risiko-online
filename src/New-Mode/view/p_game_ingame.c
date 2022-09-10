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
  while (config->match->match_status != ENDED) {

    /* Logic to fetch data from database and update match, turn,... */
  }
}

void view_game_ingame(Match *match) {
  pthread_t tid;
  SpinnerConfig *spinner_config;
  clear_screen();
  spinner_config = get_spinner_config();
  spinner_config->is_loading = true;

  // IngamePollThreadConfig thread_config = {spinner_text, match};

  // if (pthread_create(&tid, NULL, ingame_poll_match_thread, &thread_config)) {
  //   printffn("Error: Failed to create Thread!\n");
  //   exit(-1);
  // }

  *can_exit_flag = 0;
  render_match_start(match);
  while (match->match_status != ENDED) {
    render_turn_start();
    render_turn_end();
    render_placement();
    render_movement();
    render_combat();
    render_waiting_action(spinner_config);
    pause();
  }
  *can_exit_flag = 1;

  destroy_spinner_config(spinner_config);

  clear_screen();
}

void render_match_start(Match *match) {
  char *line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "Match #%d has started!", match->match_id);
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_turn_start() {
  char *line_1 = malloc(TEXT_LINE_MEM);
  char *line_2 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "New Turn");
  sprintf(line_2, "<Dummy>'s Turn ");
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_2, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
  free_safe(line_2);
}

void render_turn_end() {
  char *line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<Dummy>'s Turn Ended");
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_waiting_action(SpinnerConfig *spinner_config) {
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  while (spinner_config->is_loading) {
    print_spinner("Waiting for any action", spinner_config);
  }
  reset_color();
}

void render_players_info(Match *match) {
  char *line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<Dummy>'s tanks are moving");
  set_color(BLACK_BG);
  set_color(YELLOW_TXT);
  print_char_line('-', 0);
  print_framed_text_left(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_movement() {
  char *line_1 = malloc(TEXT_LINE_MEM);
  char *line_2 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<Dummy>'s tanks are moving");
  sprintf(line_2, "<50> Tanks - <Egypt> -> <Territori del Nord Ovest>!");
  set_color(BLACK_BG);
  set_color(YELLOW_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_framed_text(line_2, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_placement() {
  char *line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<Dummy> placed <50> tanks on <Egypt>!");
  set_color(BLACK_BG);
  set_color(YELLOW_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_combat() {}

void render_territories(int player_id) {}

void render_neighbour_nations() {}

void render_attackable_nations() {}

void render_dice_roll() {}
