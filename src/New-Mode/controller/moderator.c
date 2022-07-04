#include "moderator.h"
#include "../utils/io.h"
#include "../model/db.h"
#include "../view/m_mainmenu.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static bool create_room(void) {

  return false;
}

static bool display_ingame_matches(void) {
  return false;
}


static bool display_idle_players(void) {
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
    {.action = CREATE_ROOM, .control = create_room},
    {.action = DISPLAY_INGAME_MATCHES, .control = display_ingame_matches},
    {.action = DISPLAY_IDLE_PLAYERS, .control = display_idle_players},
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
