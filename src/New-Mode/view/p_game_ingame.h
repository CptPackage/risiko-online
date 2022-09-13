#pragma once
#include "../model/p_match.h"
#include "../utils/view.h"

// Defines which Action Menu to display
typedef enum { 
    GENERAL_MENU = 0,
    PERSONAL_MENU = 1
} menu_mode_t;

// Defines which Thread will be printing to the screen
// Polling thread will change it to 0, if it's on main_thread mode and the turn has passed; 
typedef enum {
    POLLING_THREAD = 0,
    MAIN_THREAD = 1
} printing_control_t;


extern void view_game_ingame(Match *match);

extern void render_actions_menu(menu_mode_t new_menu_mode);

extern void render_match_start(Match *match);

extern void render_turn_start(Turn* turn);

extern void render_turn_end(Turn* turn);

extern void render_action(Action* action);

extern void render_movement(Action* action);

extern void render_combat(Action* action);

extern void render_placement(Action* action);

extern void render_territories(Territories* territories);

extern void render_scoreboard(Territories* territories);

extern void render_personal_territories(Territories* territories);

//Internally call render_territories, but with the right data!
extern void render_neighbour_nations(Territories* territories);

//Internally call render_territories, but with the right data!
extern void render_attackable_nations(Territories* territories); 

extern void render_players_info(Match *match);

extern void render_waiting_action(SpinnerConfig *spinner_config);
