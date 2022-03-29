#pragma once
#include "../model/p_match.h"
#include "../model/p_match_history.h"

void view_match_history(MatchLog **logs, int logs_size);
void render_match_log(MatchLog *log);
