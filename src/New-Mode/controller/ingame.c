#include <stdlib.h>
#include "ingame.h"
#include "../view/p_game_waiting.h"
#include "../view/p_game_ingame.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "../model/session.h"
#include "../utils/io.h"

int action = WAITING_MATCH_START;

static bool waiting_match_start (void){
  view_game_waiting(current_match);
  if(current_match == NULL){
    return true;
  }
  
  action = MATCH_IN_PROGRESS;
  return false;
}

static bool ingame (void){
  set_can_exit_flag(1, NULL);
  view_game_ingame(current_match);
  action = MATCH_ENDED;
  return false;
}

static bool match_result (void){
  // Get Player Status
  set_current_turn(NULL);
  set_current_match(NULL);
  return true;
}

static struct {
  enum ingame_actions action;
  bool (*control)(void);
} controls[EOA] = {
    {.action = WAITING_MATCH_START, .control = waiting_match_start},
    {.action = MATCH_IN_PROGRESS, .control = ingame},
    {.action = MATCH_ENDED, .control = match_result}
};

void controller_ingame(void) {
   action = WAITING_MATCH_START;
   
   while (true) {
    if (action >= EOA) {
      fprintf(stderr, "Error: unknown action\n");
      continue;
    }

    if (controls[action].control())
      break;

  } 
}
