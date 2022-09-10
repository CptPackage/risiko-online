#include "player.h"
#include "../model/p_match.h"
#include "../model/p_match_history.h"
#include "../utils/io.h"
#include "../view/p_lobby.h"
#include "../view/p_mainmenu.h"
#include "../view/p_match_history.h"
#include "../model/db.h"
#include "../model/session.h"
#include "ingame.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static bool join_match(void) {
  char *choices;
  char op;
  Matches_List* matches;
  init_choices_array(&choices, P_MATCHES_PAGE_SIZE + 1, 0);
  go_to_lobby:
  matches =  get_joinable_rooms(P_MATCHES_PAGE_SIZE);
  view_lobby(matches);
  op = multi_choice(NULL, choices, P_MATCHES_PAGE_SIZE + 1);
  if(op != '0'){
    int roomIndex = (op - '0') - 1;
    int roomNumber = matches->matches[roomIndex].room_id;
    bool joinedRoom = join_room(roomNumber);

    if(joinedRoom){
      set_current_match(&matches->matches[roomIndex]);
      controller_ingame();
    }

    goto go_to_lobby;
  }
  free(matches);
  set_current_match(NULL);
  return false;
}

static bool review_match_history(void) {
  Matches_Logs_List* logs = get_player_history();
  view_match_history(logs);
  press_anykey();
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
    {.action = JOIN_MATCH, .control = join_match},
    {.action = REVIEW_MATCH_HISTORY, .control = review_match_history},
    {.action = EXIT, .control = exit_game}};

void controller_player(void) {
   db_switch_to_player();

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
