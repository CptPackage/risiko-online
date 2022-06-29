#include "player.h"
#include "../model/p_match.h"
#include "../model/p_match_history.h"
#include "../utils/io.h"
#include "../view/p_lobby.h"
#include "../view/p_mainmenu.h"
#include "../view/p_match_history.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define P_MATCHES_PAGE_SIZE 8

static bool join_match(void) {
  char *choices;
  init_choices_array(&choices, P_MATCHES_PAGE_SIZE + 1, 0);
  char op;
  int matches_size = 2;
  Match **matches = malloc(sizeof(Match *) * matches_size);
  Match match_1 = {1, 1, 4, LOBBY};
  Match match_2 = {2, 2, 2, COUNTDOWN};
  matches[0] = &match_1;
  matches[1] = &match_2;
  view_lobby(matches, matches_size);
  op = multi_choice(NULL, choices, P_MATCHES_PAGE_SIZE + 1);
  
  return false;
}

static bool review_match_history(void) {
  int logs_size = 3;
  MatchLog **logs = malloc(sizeof(MatchLog *) * logs_size);
  MatchLog log1 = {1, 1, "27/5/2012 - 05:00", "27/5/2012 - 05:30", WON};
  MatchLog log2 = {2, 2, "27/5/2012 - 07:00", "27/5/2012 - 07:30", QUIT};
  MatchLog log3 = {3, 3, "27/5/2012 - 07:00", "27/5/2012 - 08:30", LOST};
  logs[0] = &log1;
  logs[1] = &log2;
  logs[2] = &log3;
  view_match_history(logs, logs_size);
  return false;
}


static bool exit_game(void) {  
  // Do Cleanup
  return true; 
}
static struct {
  enum actions action;
  bool (*control)(void);
} controls[END_OF_ACTIONS] = {
    {.action = JOIN_MATCH, .control = join_match},
    {.action = REVIEW_MATCH_HISTORY, .control = review_match_history},
    {.action = EXIT, .control = exit_game}};

void controller_moderator(void) {
  // db_switch_to_administrator();

  while (true) {
    int action = view_main_menu_player();
    if (action >= END_OF_ACTIONS) {
      fprintf(stderr, "Error: unknown action\n");
      continue;
    }
    if (controls[action].control())
      break;

  }
}
