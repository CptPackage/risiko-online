#include "p_game_waiting.h"
#include "../model/p_match.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "../utils/view.h"
#include "../model/db.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct _poll_thread_config {
  char *spinner_text;
  Match *match;
} WaitingPollThreadConfig;

SpinnerConfig *spinner_config;

void *waiting_poll_match_thread(void *args) {
  WaitingPollThreadConfig *config = (WaitingPollThreadConfig *)args;
  int i = 0;
  while (config->match->match_status != STARTED) {
    if (config->match->match_status == LOBBY) {
      spinner_config->is_loading = false;
    }else if (config->match->match_status == COUNTDOWN) {
      spinner_config->is_loading = true;
      sprintf(config->spinner_text, "# of players: %d", i);
      sleep(2);
    }
  }
}

void view_game_waiting(Match *match) {
  clear_screen();
  char *line_1 = malloc(TEXT_LINE_MEM);
  char *line_2 = malloc(TEXT_LINE_MEM);
  char *spinner_text = malloc(TEXT_LINE_MEM);
  sprintf(spinner_text, "Waiting for match to start...");
  bool left_room = false;
  match_status_t initial_status = match->match_status;
  pthread_t tid;
  sprintf(line_1, "Status: %s", get_match_status_string(match->match_status));
  sprintf(line_2, "Room #%d", match->room_id);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_2, '|', false, 0, 0);
  print_char_line('-', 0);

  WaitingPollThreadConfig thread_config = {spinner_text, match};

  if (pthread_create(&tid, NULL, waiting_poll_match_thread, &thread_config)) {
    printffn("Error: Failed to create Thread!\n");
    exit(-1);
  }

  while (match->match_status != STARTED && left_room == false ) {
    if (match->match_status != initial_status) {
      initial_status = match->match_status;
      move_to(2, 0);
      sprintf(line_1, "Status: %s",
              get_match_status_string(match->match_status));
      set_color(STYLE_BOLD);
      print_framed_text(line_1, '|', false, YELLOW_TXT, 0);
      move_down(3);
    }

    if (match->match_status == LOBBY) {
      char* choices;
      init_choices_array(&choices,1,0);
      print_char_line('-',0);
      print_framed_text_left("[0] Exit Room",'|',false,0,0);
      print_char_line('-',0);
      char choice = multi_choice(NULL,choices,1);
      if(choice == '0'){
        exit_room(match->room_id);
        if(did_player_leave()){
          break;
        }else{
          update_match_details();
        }
      }
      move_up(1);
      clear_line();
    } else if (match->match_status == COUNTDOWN) {
      set_can_exit_flag(0,"Can't exit while waiting for the match to start!");
      spinner_config = get_spinner_config();
      print_spinner(spinner_text, spinner_config);
      destroy_spinner_config(spinner_config);
    } 
  }

 exit_match:
  clear_screen();

  free(line_1);
  free(line_2);
  free(spinner_text);
}
