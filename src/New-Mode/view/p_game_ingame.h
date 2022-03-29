#pragma once
#include "../model/p_match.h"
#include "../utils/view.h"

extern void view_game_ingame(Match *match);

extern void render_match_start(Match *match);

extern void render_turn_start();

extern void render_turn_end();

extern void render_movement();

extern void render_combat();

extern void render_placement();

extern void render_territories(int player_id);

extern void render_neighbour_nations();

extern void render_attackable_nations();

extern void render_dice_roll();

extern void render_players_info(Match *match);

extern void render_waiting_action(SpinnerConfig *spinner_config);
