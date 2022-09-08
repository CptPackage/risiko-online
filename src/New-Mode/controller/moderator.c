#include "moderator.h"
#include "../utils/io.h"
#include "../model/db.h"
#include "../view/m_mainmenu.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static bool create_new_room(void) {
  int numberOfActivePlayers = get_active_players_count();
  printff("Current Active Players: %d",numberOfActivePlayers);
  int roomNumber = create_room(25);
  printff("New Created Room: %d",roomNumber);
  return false;
}

static bool display_analytical_report(void) {
  int recentlyActiveCount = get_recently_active_players_count();
  printff("Recently Active Count: %d\n",recentlyActiveCount);
  ActiveMatchesStats* stats = get_ingame_matches_and_players();
  printff("Ingame Matches: %d - Ingame Players: %d ",stats->numberOfStartedMatches, stats->numberOfIngamePlayers);
  free(stats);
  return false;
}


static bool exit_game(void) {  
  logout();
  return true; 
}

static struct {
  enum actions action;
  bool (*control)(void);
} controls[END_OF_ACTIONS] = {
    {.action = CREATE_ROOM, .control = create_new_room},
    {.action = DISPLAY_ANALYTICAL_REPORT, .control = display_analytical_report},
    {.action = EXIT, .control = exit_game}};

void controller_moderator(void) {
   db_switch_to_moderator();

  while (true) {
    int action = view_main_menu_mod();
    if (action >= END_OF_ACTIONS) {
      fprintf(stderr, "Error: unknown action\n");
      continue;
    }
    if (controls[action].control())
      break;

  }
}
