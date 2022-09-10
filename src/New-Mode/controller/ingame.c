#include <stdlib.h>
#include "ingame.h"
#include "../view/p_game_waiting.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "../model/session.h"

int action = WAITING_MATCH_START;

static bool waiting_match_start (void){
  view_game_waiting(current_match);

  if(current_match == NULL){
    return true;
  }
  
  action = MATCH_IN_PROGRESS;
}

static bool ingame (void){

}

static bool match_result (void){

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
