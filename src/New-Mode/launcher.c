#include "controller/login.h"
#include "controller/player.h"
#include "controller/ingame.h"
#include "model/db.h"
#include "model/p_match.h"
#include "model/p_match_history.h"
#include "signal.h"
#include "utils/dotenv.h"
#include "utils/io.h"
#include "utils/validation.h"
#include "utils/view.h"
#include "view/calibrate.h"
#include "view/login.h"
#include "view/p_game_ingame.h"
#include "view/p_game_waiting.h"
#include "view/p_lobby.h"
#include "view/p_match_history.h"
#include "view/p_match_result.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <math.h>
#include "model/session.h"
#include "pthread.h"


#define check_env_failing(varname)                                             \
  if (getenv((varname)) == NULL) {                                             \
    fprintf(stderr, "[FATAL] env variable %s not set\n", (varname));           \
    ret = false;                                                               \
  }

static bool validate_dotenv(void) {
  bool ret = true;

  check_env_failing("HOST");
  check_env_failing("DB");
  check_env_failing("PORT");

  check_env_failing("LOGIN_USER");
  check_env_failing("LOGIN_PASS");
  check_env_failing("MODERATOR_USER");
  check_env_failing("MODERATOR_PASS");
  check_env_failing("PLAYER_USER");
  check_env_failing("PLAYER_PASS");
  return ret;
}
#undef set_env_failing


void initApp();
int startup();



void* my_thread(){
  printffn("T - File NO: %d",STDIN_FILENO);
  while(true){
    int input;
    scanf("%d",&input);
    printf("Input: %d",input);
  }
}

int main(int argc, char** argv) {
  if (startup()) {
    printff("Error: Failed during startup procedure!\n");
    return -1;
  }



  /*                      [TEMP] TEST AREA                       */
  // printf("Extra Rooms Needed: %d * %d\n", numberOfExtraRoomsNeeded, numberOfRoomsNeeded);
  // char* stats_info = malloc(sizeof(char) * 1024);
  // sprintf(stats_info, " Active Players: %d | Rooms Number: %d | Extra Rooms Needed: %d",
  //   numberOfActivePlayers, numberOfRooms, numberOfExtraRoomsNeeded);

  // PlayersList list;
  // list.players_count = 6;
  // strcpy(list.players[0], "Hey");
  // strcpy(list.players[1],"Man");
  // strcpy(list.players[2],"How");
  // strcpy(list.players[3],"Is it going?");
  // strcpy(list.players[4],"Whadup");
  // strcpy(list.players[5],"Nigga");

  // PlayersList* listx = &list;


  // for (size_t i = 0; i < listx->players_count; i++)
  // {
  //   printff("[%d] -> %s\n",i, listx->players[i]);
  // }
  
  // return;

  // clear_screen();
  // set_color(STYLE_BOLD);
  // print_star_line(0);
  // print_framed_text("CREATE NEW ROOMS", '*', false, 0, 0);
  // print_star_line(0);
  // print_framed_text_left(stats_info, '*', false, 0, 0);
  // print_char_line('*', 0);
  // reset_color();
  // free(stats_info);
  // return 0;

  // printff("Username: %s\n", creds.username);
  // printff("Password: %s\n", creds.password);
  // controller_player();
  // char *choices;
  // init_choices_array(&choices, 10);
  // char op;
  // op = multi_choice(NULL, choices, 10);
  // multi_choice(NULL, choices, 5);
  // view_main_menu_mod();
  // print_logo(BLUE_TXT, CYAN_TXT, BLACK_BG);
  // print_error_text("Test Error");
  // Match match_1 = {1, 1, 4, LOBBY};
  // view_game_waiting(&match_1);
  // view_game_ingame(&match_1);

  // view_match_result(WON);
  // view_match_result(LOST);
  // view_match_result(QUIT);
  // int matches_size = 2;
  // Match **matches = malloc(sizeof(LobbyMatch *) * matches_size);
  // Match match_1 = {1, 1, 4, LOBBY};
  // Match match_2 = {2, 2, 5, COUNTDOWN};
  // matches[0] = &match_1;
  // matches[1] = &match_2;
  // view_lobby(matches, matches_size);

  /**************************************************************/

  // Init
  if (initialize_io()) {
    clear_screen();
    /* DEVELOPMENT SETUP FOR GAME SESSION*/
    // db_switch_to_player();
    // set_current_user("player2");
    // Match match;
    // match.match_id = 3;
    // match.room_id = 3;
    // match.players_num = 3;
    // match.match_status = STARTED;
    // set_current_match(&match);
    // controller_ingame();

    // strcpy(match.match_start_countdown,"09-09-2022 - 15:07");
    // match.match_id = 4;
    // match.room_id = 4;
    
    // PlayersList* list = get_match_players();
    // Turn* turn = get_latest_turn();

    // printff("Turn Info: %d, %d, %s, %s\n",turn->match_id, turn->turn_id, turn->player, turn->turn_start_time);

    // // player_status_t result = did_player_win_or_lose();

    // Turn turn = {3,7,"player2"};
    // set_current_turn(&turn);

    // int unplacedTanks = get_player_unplaced_tanks();
    // printff("Tanks Count: %d\n\n",unplacedTanks);
    // bool turn_has_action = does_turn_have_action(&turn);
    // printffn("Does turn have action: %d", turn_has_action);
    
    // Action* action = get_turn_action(&turn);
    // printffn("Action Info: %d - %d - %d - %s - %s - %d - %d",
    // action->match_id,action->turn_id,action->action_id,action->player,
    // action->target_nation,action->tanks_number,action->details->action_type);
    

    // get_action_details(action);
    // render_combat(action);
    // printffn("Action Info: %d - %d - %d - %s - %s - %d - %d",
    // action->match_id,action->turn_id,action->action_id,action->player,
    // action->target_nation,action->tanks_number,action->details->action_type);

    // printffn("Action Details: %d - %p", action->details->action_type, action->details->content);


    // if(action->details->action_type == 1){
    //   Movement* movement = action->details->content;
    //   printffn("Source: %d", movement->source_nation);
    // }

    // if(action->details->action_type == 2){    
    //   Combat* combat = action->details->content;
    //   printffn("Combat Details: %s - %d - %d - %s - %d - %d - %d", 
    //   combat->attacker_nation, combat->attacker_lost_tanks, action->tanks_number,
    //   combat->defender_player, combat->defender_tanks_number, combat->defender_lost_tanks, combat->succeded);
    //   printffn("Nation occupied: %d",combat->succeded);
    // }
    // int count = 42;
    // Territories* territories_list;
    
    // territories_list = malloc(sizeof(*territories_list) + sizeof(Territory) * count);
    // memset(territories_list,0,sizeof(*territories_list) + sizeof(Territory) * count);
    // territories_list->territories_count = 42;

    // for (size_t i = 0; i < count; i++)
    // {
    // territories_list->territories[i].match_id = i;
    // strcpy(territories_list->territories[i].nation,"Africa del Nord Chicchi");
    // strcpy(territories_list->territories[i].occupier, "CptPackage");
    // territories_list->territories[i].occupying_tanks_number = i + 1;
    // }

    // printffn("Status: %d - %d",INGAME, did_player_win_or_lose());

    // territories_list = get_personal_territories();
    // territories_list = get_scoreboard();
    // territories_list = get_actionable_territories();
    // territories_list = get_neighbour_territories("America Centrale");
    // territories_list = get_attackable_territories("America Centrale");
    // controller_ingame();

    // print_char_line('+',0);
    // print_framed_text("[1] Show Personal Territory | [2] Show Scoreboard | [3] Show Unplaced Tanks"
    // ,'+',false,0,0);
    // print_framed_text("[4] Place Tanks |   [5] Move Tanks    | [6] Attack ",'+',false,0,0);
    // print_char_line('+',0);

    // sleep(2);
    
    // Switch from Personal Actions to General Actions
    // 4 lines
    
    // move_up(3);
    // move_up(4);
    // clear_line();
    // // move_down(1);
    // print_char_line('+',0);
    // print_framed_text("[1] Show Personal Territory | [2] Show Scoreboard | [3] Show Unplaced Tanks"
    // ,'+',false,0,0);
    // print_char_line('+',0);


    // sleep(2);
    //Switch from General Actions to Personal Actions
    // move_up(1);
  //   print_char_line('+',0);
  //   print_framed_text("[1] Show Personal Territory | [2] Show Scoreboard | [3] Show Unplaced Tanks"
  //   ,'+',false,0,0);
  //   print_framed_text("[4] Place Tanks |   [5] Move Tanks    | [6] Attack ",'+',false,0,0);
  //   print_char_line('+',0);
  // sleep(2);
    // printffn("Size: %d",territories_list->territories_count);

    // for (size_t i = 0; i < territories_list->territories_count; i++)
    // {
    //   Territory current = territories_list->territories[i];
    //   printffn("Territories: %d - %s - %s - %d"
    //   ,current.match_id,current.nation,current.occupier,current.occupying_tanks_number);
    // }
    // printffn("Current Territory: %s",territories_list->territories[0].nation);
    // action_combat(territories_list->territories[0].nation,"Alberta");
    // action_movement(territories_list->territories[0].nation,"Congo", 1);
    // action_placement("Quebec", 5);
    
    
    // territories_list->territories = malloc(sizeof(Territory*) * territories_list->territories_count); 

    // return 0;
    // view_calibrate(); // CALIBRATION DISABLED DURING DEVELOPMENT
    initApp(); //TEMPORARILY DISABLED FOR PLAYER TESTING!
  }

  fini_db();
  fini_validation();
  return 0;
}

void initApp() {
  clear_screen();
  login();
}

int startup() {
  if (env_load(".", false) != 0)
    return 1;
  if (!validate_dotenv())
    return 2;
  if (!init_validation())
    return 3;
  if (!init_db())
    return 4;

  setup_exit_interrupt_handler();
  setup_cleanup_interrupt_handler();
  return 0;
}
