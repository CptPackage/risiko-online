#include "p_game_ingame.h"
#include "../model/p_match.h"
#include "../model/session.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "../utils/view.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct _poll_thread_config {
  Match* match;
} IngamePollThreadConfig;

void* ingame_poll_match_thread(void* args) {
  IngamePollThreadConfig* config = (IngamePollThreadConfig*)args;

  while (config->match->match_status != ENDED) {

    /* Logic to fetch data from database and update match, turn,... */
  }
}

void view_game_ingame(Match* match) {
  pthread_t tid;
  clear_screen();


  render_match_start(match);

  while (current_turn == NULL) {
    // set_current_turn(get_latest_turn());
  }

  // IngamePollThreadConfig thread_config = { match };

  // if (pthread_create(&tid, NULL, ingame_poll_match_thread, &thread_config)) {
  //   printffn("Error: Failed to create Thread!\n");
  //   exit(-1);
  // }
  while (match->match_status != ENDED) {
    render_turn_start(NULL);
    render_turn_end(NULL);
    render_placement(NULL);
    render_movement(NULL);
    render_combat(NULL);
    pause();
  }

  clear_screen();
  pthread_cancel(tid);
}

void render_match_start(Match* match) {
  char* line_1 = malloc(TEXT_LINE_MEM);
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

void render_turn_start(Turn* turn) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  char* line_2 = malloc(TEXT_LINE_MEM);
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

void render_turn_end(Turn* turn) {
  char* line_1 = malloc(TEXT_LINE_MEM);
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

void render_waiting_action(SpinnerConfig* spinner_config) {
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  while (spinner_config->is_loading) {
    print_spinner("Waiting for any action", spinner_config);
  }
  reset_color();
}

void render_players_info(Match* match) {
  char* line_1 = malloc(TEXT_LINE_MEM);
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

void render_action(Action* action) {
  if (action == NULL) {
    return;
  }

  switch (action->details->action_type) {
    case PLACEMENT:
      render_placement(action);
    break;  
    case MOVEMENT:
      render_movement(action);
    break;
    case COMBAT:
      render_combat(action);
    break;
    default:
      print_framed_text("[render_action] UNKNOWN ACTION TYPE!", 'X',true, STYLE_BOLD,RED_TXT);
    break;
  }


}

void render_movement(Action* action) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  char* line_2 = malloc(TEXT_LINE_MEM);
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

void render_placement(Action* action) {
  char* line_1 = malloc(TEXT_LINE_MEM);
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

void render_combat(Action* action) {}

void render_territories(Territory** territories) {}

void render_neighbour_nations(Territory** territories) {
  // Get right data
  // Print header
  render_territories(territories);
}

void render_attackable_nations(Territory** territories) {
  // Get right data
  // Print header
  render_territories(territories);
}