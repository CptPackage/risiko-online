#pragma once
#include "../model/p_match.h"

enum ingame_actions { WAITING_MATCH_START, MATCH_IN_PROGRESS, MATCH_ENDED, EOA };

extern void controller_ingame(void);
