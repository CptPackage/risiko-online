#include "p_game_ingame.h"
#include "../model/p_match.h"
#include "../model/session.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "../utils/view.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define QUERIES_SEMAPHORE 1011
#define PERSONAL_MENU_CHOICES_SIZE 6
#define GENERAL_MENU_CHOICES_SIZE 3

pthread_mutex_t sync_lock;

typedef struct _poll_thread_config {
  Match* match;
} IngameInputThreadConfig;

player_status_t player_current_status = INGAME;
menu_mode_t cached_menu_mode = GENERAL_MENU;
menu_mode_t menu_mode = GENERAL_MENU;
Turn* last_displayed_turn;
Action* last_displayed_action;
char personal_menu_choices[PERSONAL_MENU_CHOICES_SIZE] = { '1', '2', '3', '4','5','6' };
char general_menu_choices[GENERAL_MENU_CHOICES_SIZE] = { '1', '2', '3' };


void* ingame_poll_match_thread(void* args) {
  IngameInputThreadConfig* config = (IngameInputThreadConfig*)args;
  pthread_mutex_lock(&sync_lock);
  Turn* turn = get_latest_turn();
  pthread_mutex_unlock(&sync_lock);
  Turn* current_turn_temp = current_turn;
  if (turn != NULL) { //For first turn
    current_turn_temp = current_turn;
    set_current_turn(turn);

    if (current_turn_temp != NULL && turn->turn_id != current_turn_temp->turn_id) {
      free(current_turn_temp);
    }
    render_turn_start(turn);
    if (strcmp(turn->player, current_user) == 0) {
      render_actions_menu(PERSONAL_MENU);
    } else {
      render_actions_menu(GENERAL_MENU);
    }
    last_displayed_turn = turn;
  }

  bool any_new_actions;
  Action* action;
  while (config->match->match_status != ENDED && player_current_status == INGAME) {
  refetch_turns:
    current_turn_temp = current_turn;
    pthread_mutex_lock(&sync_lock);
    turn = get_latest_turn();
    player_current_status =  did_player_win_or_lose();
    if (turn->turn_id != current_turn_temp->turn_id) { // Check on a new turn
      if (does_turn_have_action(current_turn_temp) == 1) {
        if (last_displayed_action == NULL ||
          (last_displayed_action != NULL && last_displayed_action->turn_id != turn->turn_id)) {
          action = get_turn_action(current_turn_temp);
          get_action_details(action);
          render_action(action);
          last_displayed_action = action;
        }
      }
      last_displayed_turn = current_turn_temp;
      render_turn_end(current_turn_temp);
      set_current_turn(turn);
      free(current_turn_temp);
      render_turn_start(turn);
      if (does_turn_have_action(turn) == 1) {
        if (last_displayed_action == NULL ||
          (last_displayed_action != NULL && last_displayed_action->turn_id != turn->turn_id)) {
          action = get_turn_action(turn);
          get_action_details(action);
          render_action(action);
          last_displayed_action = action;
          render_turn_end(turn);
          last_displayed_turn = turn;
          // goto refetch_turns;
        }
      }
      printffn("");
      if (strcmp(turn->player, current_user) == 0) {
        render_actions_menu(PERSONAL_MENU);
      } else {
        render_actions_menu(GENERAL_MENU);
      }
    } else { //Check on the same turn
      if (does_turn_have_action(turn) == 1) {
        if (last_displayed_action == NULL ||
          (last_displayed_action != NULL && last_displayed_action->turn_id != turn->turn_id)) {
          action = get_turn_action(turn);
          get_action_details(action);
          render_action(action);
          last_displayed_action = action;
          render_turn_end(turn);
          last_displayed_turn = turn;
          // goto refetch_turns;
        }
      }
    }
    pthread_mutex_unlock(&sync_lock);
    sleep(2);
  }

  print_framed_text("THE MATCH HAS ENDED - ENTER ANY KEY TO PROCEED",'*',true,YELLOW_TXT,YELLOW_TXT);
}

void view_game_ingame(Match* match) {
  pthread_t tid;
  char op;
  clear_screen();

  IngameInputThreadConfig thread_config = { match };
  if (pthread_create(&tid, NULL, ingame_poll_match_thread, &thread_config)) {
    printffn("Error: Failed to create Thread!\n");
    exit(-1);
  }

  render_match_start(match);

  while (match->match_status != ENDED && player_current_status == INGAME) {
    if (menu_mode == PERSONAL_MENU) {
      cached_menu_mode = PERSONAL_MENU;
      op = multi_choice(NULL, personal_menu_choices, PERSONAL_MENU_CHOICES_SIZE);
      clear_line();
    } else {
      cached_menu_mode = GENERAL_MENU;
      op = multi_choice(NULL, general_menu_choices, GENERAL_MENU_CHOICES_SIZE);
      clear_line();
    }
pthread_mutex_lock(&sync_lock);
  switch (op) {
    case '1':{
        if(cached_menu_mode != menu_mode){
          break;
        }
        Territories* personal_territories = get_personal_territories();
        render_personal_territories(personal_territories);
        free(personal_territories);
        render_actions_menu(menu_mode);
    }
    break;
    case '2':{
        if(cached_menu_mode != menu_mode){
          break;
        }
        Territories* scoreboard_territories = get_scoreboard();
        render_scoreboard(scoreboard_territories);
        free(scoreboard_territories);
        render_actions_menu(menu_mode);
    }
    break;
    case '3':{
        if(cached_menu_mode != menu_mode){
          break;
        }

        char* line_1 = malloc(TINY_MEM);
        int unplaced_tanks = get_player_unplaced_tanks();
        sprintf(line_1," You have %d unplaced Tanks.", unplaced_tanks);
        printffn("");
        print_char_line('+',0);
        print_framed_text_left(line_1,'+',false,0,0);
        print_char_line('+',0);
        printffn(""); 
        render_actions_menu(menu_mode);
        free(line_1);
    }
    break;
    case '4':{
        if(cached_menu_mode != menu_mode){
          break;
        }

        if(menu_mode != PERSONAL_MENU){
          break;
        }
        char* line_1 = malloc(TINY_MEM);
        int unplaced_tanks = get_player_unplaced_tanks();
        if(unplaced_tanks < 1){
          sprintf(line_1,"[Can't place new tanks] You have %d unplaced tanks!", unplaced_tanks);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          free(line_1);
          render_actions_menu(menu_mode);
          break;
        }

        Territories* personal_territories = get_personal_territories();
        render_personal_territories(personal_territories);
        int territory_number = get_input_number("Insert Territory number: ");
        int tanks_to_place = get_input_number("Insert Tanks number: ");

        if(tanks_to_place > unplaced_tanks){
          sprintf(line_1,"[Invalid Tanks Number] You can't place more than %d tanks!", unplaced_tanks);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_placement;
        }

        if(territory_number <= 0 || territory_number > personal_territories->territories_count){
          sprintf(line_1,"[Invalid Territory Number] Territory Number has to be between %d and %d!", 1,personal_territories->territories_count);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_placement;
        }


        if(strcmp(current_turn->player,current_user) != 0){
          sprintf(line_1,"[Turn Timeout] Your turn has passed before you took action!");
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_placement;
        }

        action_placement(personal_territories->territories[territory_number-1].nation,tanks_to_place);
      
      no_placement:
        free(line_1);
        free_safe(personal_territories);
        // render_actions_menu(menu_mode);
    }
    break;
    case '5':{
      if(cached_menu_mode != menu_mode){
          break;
      }

      if(menu_mode != PERSONAL_MENU){
          break;
      }

        char* line_1 = malloc(TINY_MEM);
        Territories* source_territories = get_actionable_territories();
        print_char_line('+', 0);
        print_framed_text("Tanks moving from ... ", '+', false, 0, 0);
        render_territories(source_territories);
        int source_territory_number = get_input_number("Insert Source Territory number: ");
        
        if(source_territory_number <= 0 
        || source_territory_number > source_territories->territories_count){
          sprintf(line_1,"[Invalid Territory Number] Territory Number has to be between %d and %d!"
          , 1,source_territories->territories_count);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_movement_2;
        }

        Territories* target_territories = get_neighbour_territories(source_territories->territories[source_territory_number - 1].nation);
        print_char_line('+', 0);
        print_framed_text("Tanks moving to ... ", '+', false, 0, 0);
        render_territories(target_territories);
        int target_territory_number = get_input_number("Insert Target Territory number: ");
        

        if(target_territory_number <= 0 
        || target_territory_number > target_territories->territories_count){
          sprintf(line_1,"[Invalid Territory Number] Territory Number has to be between %d and %d!"
          , 1,target_territories->territories_count);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_movement_1;
        }

        int tanks_number = get_input_number("Insert Number of Tanks: ");
        if(tanks_number > source_territories->territories[source_territory_number - 1].occupying_tanks_number){
          sprintf(line_1,"[Invalid Tanks Number] You can't place more than %d tanks!",
          source_territories->territories[source_territory_number - 1].occupying_tanks_number);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_movement_1;
        }

        if(strcmp(current_turn->player,current_user) != 0){
          sprintf(line_1,"[Turn Timeout] Your turn has passed before you took action!");
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_movement_1;
        }

        action_movement(source_territories->territories[source_territory_number - 1].nation,
        target_territories->territories[target_territory_number - 1].nation, tanks_number);

      no_movement_1:
        free_safe(target_territories);
      no_movement_2:
        free_safe(source_territories);
      no_movement_3:
        free(line_1);
        // render_actions_menu(menu_mode);
    }break;
    case '6':{
      if(cached_menu_mode != menu_mode){
        break;
      }

      if(menu_mode != PERSONAL_MENU){
          break;
        }
        char* line_1 = malloc(TINY_MEM);
        Territories* source_territories = get_actionable_territories();
        print_char_line('+', 0);
        print_framed_text("Choose your attacking territory ", '+', false, 0, 0);
        render_territories(source_territories);
        int source_territory_number = get_input_number("Insert Attacker Territory number: ");
        
        if(source_territory_number <= 0 
        || source_territory_number > source_territories->territories_count){
          sprintf(line_1,"[Invalid Territory Number] Territory Number has to be between %d and %d!"
          , 1,source_territories->territories_count);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_combat_2;
        }

        Territories* target_territories = get_attackable_territories(source_territories->territories[source_territory_number - 1].nation);
        print_char_line('+', 0);
        print_framed_text("Territories to attack ", '+', false, 0, 0);
        render_territories(target_territories);
        int target_territory_number = get_input_number("Insert Target Territory number: ");
        

        if(target_territory_number <= 0 
        || target_territory_number > target_territories->territories_count){
          sprintf(line_1,"[Invalid Territory Number] Territory Number has to be between %d and %d!"
          , 1,target_territories->territories_count);
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_combat_1;
        }

        if(strcmp(current_turn->player,current_user) != 0){
          sprintf(line_1,"[Turn Timeout] Your turn has passed before you took action!");
          print_framed_text_left(line_1,'+',true,STYLE_BOLD,RED_TXT);
          reset_color();
          goto no_combat_1;
        }

        action_combat(source_territories->territories[source_territory_number - 1].nation,
        target_territories->territories[target_territory_number - 1].nation);

      no_combat_1:
        free_safe(target_territories);
      no_combat_2:
        free_safe(source_territories);
      no_combat_3:
        free(line_1);
        // render_actions_menu(menu_mode);    
    }break;
    default:{}break;
    }
    pthread_mutex_unlock(&sync_lock);

  }

  clear_screen();
  pthread_cancel(tid);
}

void render_actions_menu(menu_mode_t new_menu_mode) {
  if (new_menu_mode == GENERAL_MENU) {
    if (menu_mode == GENERAL_MENU) {
      // move_up(3);
    } else {
      // move_up(4);
      // clear_line();
      // move_down(1);
    }
    print_char_line('+', 0);
    print_framed_text("[1] Show Personal Territory | [2] Show Scoreboard | [3] Show Unplaced Tanks"
      , '+', false, 0, 0);
    print_char_line('+', 0);
  } else {
    if (menu_mode == PERSONAL_MENU) {
      // move_up(4);
    } else {
      // move_up(3);
    }
    print_char_line('+', 0);
    print_framed_text("[1] Show Personal Territory | [2] Show Scoreboard | [3] Show Unplaced Tanks"
      , '+', false, 0, 0);
    print_framed_text("[4] Place Tanks |   [5] Move Tanks    | [6] Attack ", '+', false, 0, 0);
    print_char_line('+', 0);
  }

  menu_mode = new_menu_mode;
}

void render_match_start(Match* match) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "Match #%d has started!", match->match_id);
  set_color(STYLE_BOLD);
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_turn_start(Turn* turn) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  char* line_2 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "New Turn - %s", turn->turn_start_time);
  sprintf(line_2, "<%s>'s Turn ", turn->player);
  set_color(STYLE_BOLD);
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_2, '|', false, 0, 0);
  if(strcmp(turn->player, current_user) == 0){
    print_char_line('-', 0);
    print_framed_text("Your Turn!", '|', false, 0, 0);
  }
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
  free_safe(line_2);
}

void render_turn_end(Turn* turn) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<%s>'s Turn Ended", turn->player);
  set_color(STYLE_BOLD);
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_waiting_action(SpinnerConfig* spinner_config) {
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  while (spinner_config->is_loading) {
    print_spinner("Waiting for any action", spinner_config);
  }
  reset_color();
}

void render_players_info(Match* match) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<Dummy>'s tanks are moving");
  set_color(BLACK_BG);
  set_color(YELLOW_TXT);
  print_char_line('-', 0);
  print_framed_text_left(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_action(Action* action) {
  if (action == NULL) {
    return;
  }

  switch (action->details->action_type) {
  case PLACEMENT:
    render_placement(action);
    break;
  case MOVEMENT:
    render_movement(action);
    break;
  case COMBAT:
    render_combat(action);
    break;
  default:
    print_framed_text("[render_action] UNKNOWN ACTION TYPE!", 'X', true, STYLE_BOLD, RED_TXT);
    break;
  }


}

void render_movement(Action* action) {
  if (action->details == NULL || action->details->content == NULL) {
    print_error_text("Movement action missing details!");
    return;
  }
  Movement* movement = action->details->content;
  char* line_1 = malloc(TEXT_LINE_MEM);
  char* line_2 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "[%s]'s tanks are moving", action->player);
  sprintf(line_2, "< %d Tanks > - <%s> -> <%s>!", action->tanks_number, movement->source_nation, action->target_nation);
  set_color(STYLE_BOLD);
  set_color(BLACK_BG);
  set_color(GREEN_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_framed_text(line_2, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
  free_safe(line_2);
}

void render_placement(Action* action) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "<%s> placed <%d> tanks on <%s>!", action->player, action->tanks_number, action->target_nation);
  set_color(STYLE_BOLD);
  set_color(BLACK_BG);
  set_color(YELLOW_TXT);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
}

void render_combat(Action* action) {
   if (action->details == NULL || action->details->content == NULL) {
    print_error_text("Combat action missing details!");
    return;
  }
  Combat* combat = action->details->content;
  Colors text_color;
  char* line_1 = malloc(TEXT_LINE_MEM);
  char* line_2 = malloc(TEXT_LINE_MEM);
  char* line_3 = malloc(TEXT_LINE_MEM);
  char* line_4 = malloc(TEXT_LINE_MEM);
  sprintf(line_1, "[%s] is attacking [%s]", action->player,combat->defender_player);
  sprintf(line_2, "%s <%d Tanks> VS %s <%d Tanks>", combat->attacker_nation, action->tanks_number,
   action->target_nation, combat->defender_tanks_number);
  sprintf(line_3, " %s Lost %d Tanks | %s Lost %d Tanks ",
   action->player, combat->attacker_lost_tanks, combat->defender_player, combat->defender_lost_tanks);
  if(combat->succeded == 1){
    text_color = GREEN_TXT;
    sprintf(line_4, "%s has conquisted %s successfully! ", action->player, action->target_nation);
  }else{
    text_color = BLUE_TXT;
    sprintf(line_4, "%s has defended his land %s! ", combat->defender_player,  action->target_nation);
  }
  set_color(STYLE_BOLD);
  set_color(BLACK_BG);
  set_color(text_color);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_framed_text(line_2, '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_3, '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_4, '|', false, 0, 0);
  print_char_line('-', 0);
  reset_color();
  set_color(BLACK_BG);
  clear_line();
  printffn("");
  free_safe(line_1);
  free_safe(line_2);
  free_safe(line_3);
  free_safe(line_4);
}

void render_territories(Territories* territories) {
  char* line_1 = malloc(TEXT_LINE_MEM);
  set_color(STYLE_BOLD);
  print_char_line('+', 0);
  for (size_t i = 0; i < territories->territories_count; i++)
  {
    Territory current = territories->territories[i];
    if(i < 9){
     sprintf(line_1, "%d  | [%s] %s < %d Tanks >",
      i+1, current.occupier, current.nation, current.occupying_tanks_number);
    }else{
     sprintf(line_1, "%d | [%s] %s < %d Tanks >",
      i+1, current.occupier, current.nation, current.occupying_tanks_number);
    }
    print_framed_text_left(line_1,'|',0,0,0);
  }
  print_char_line('+', 0);
  free(line_1);
}

extern void render_scoreboard(Territories* territories){
  print_char_line('+', 0);
  print_framed_text("Scoreboard", '+', false, 0, 0);
  render_territories(territories);
}

extern void render_personal_territories(Territories* territories){
  print_char_line('+', 0);
  print_framed_text("Your Territories", '+', false, 0, 0);
  render_territories(territories);
}

void render_neighbour_nations(Territories* territories) {
  print_char_line('+', 0);
  print_framed_text("Neighbour Nations", '+', false, 0, 0);
  render_territories(territories);
}

void render_attackable_nations(Territories* territories) {
  print_char_line('+', 0);
  print_framed_text("Attackable Nations", '+', false, 0, 0);
  render_territories(territories);
}