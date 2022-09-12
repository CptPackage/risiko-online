#pragma once
#include <stdbool.h>
#include <stdlib.h>
#include "db.h"
#include "p_match.h"

extern char current_user[USERNAME_LEN];
extern Match* current_match;
extern Turn* current_turn;
extern Action* last_action;


void set_current_user(char* username);
void set_current_match(Match* match);
void set_current_turn(Turn* turn);
void set_last_action(Action* action);