#include "session.h"
#include "p_match.h"
#include "db.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

char current_user[USERNAME_LEN];
Match* current_match;
Turn* current_turn;
Action* last_action;

void set_current_user(char* username){
    sprintf(current_user, "%s",username);
}

void set_current_match(Match* match){
    current_match = match;
}

void set_current_turn(Turn* turn){
    current_turn = turn;
}

void set_last_action(Action* action){
    last_action = action;
}