#pragma once
#include <stdbool.h>
#include <stdlib.h>
#include "db.h"
#include "p_match.h"

extern char current_user[USERNAME_LEN];
extern Match* current_match;

void set_current_user(char* username);
void set_current_match(Match* match);