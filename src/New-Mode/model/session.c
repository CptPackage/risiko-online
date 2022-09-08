#include "session.h"
#include "p_match.h"
#include "db.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

char current_user[USERNAME_LEN];
Match* current_match;


void set_current_user(char* username){
    sprintf(current_user, "%s",username);
}

void set_current_match(Match* match){
    current_match = match;
}