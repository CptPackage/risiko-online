#pragma once
#include "../model/p_match.h"
#include "../utils/view.h"

extern void view_game_ingame(Match *match);

extern void render_match_start(Match *match);

extern void render_turn_start(Turn* turn);

extern void render_turn_end(Turn* turn);

extern void render_action(Action* action);

extern void render_movement(Action* action);

extern void render_combat(Action* action);

extern void render_placement(Action* action);

extern void render_territories(Territory** territories);

//Internally call render_territories, but with the right data!
extern void render_neighbour_nations(Territory** territories);

//Internally call render_territories, but with the right data!
extern void render_attackable_nations(Territory** territories); 

extern void render_players_info(Match *match);

extern void render_waiting_action(SpinnerConfig *spinner_config);
