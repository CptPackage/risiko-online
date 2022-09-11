#include "p_game_waiting.h"
#include "../model/p_match.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "../utils/view.h"
#include "../model/db.h"
#include "../model/session.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

typedef struct _poll_thread_config {
  char* spinner_text;
  Match* match;
} WaitingPollThreadConfig;

SpinnerConfig* spinner_config = NULL;
match_status_t initial_status;
char choice;

void* waiting_poll_match_thread(void* args) {
  WaitingPollThreadConfig* config = (WaitingPollThreadConfig*)args;
  while (config->match && config->match->match_status != STARTED) {
    update_match_details();
    if (config->match->match_status == LOBBY) {
      spinner_config->is_loading = false;
    } else if (config->match->match_status == COUNTDOWN) {
      spinner_config->is_loading = true;
    }
    sleep(2);
  }
  spinner_config->is_loading = false;
}


void* lobby_waiting_input(void* args) {
  WaitingPollThreadConfig* config = (WaitingPollThreadConfig*)args;
  char* choices;
  init_choices_array(&choices, 1, 0);
  while (config->match && config->match->match_status == LOBBY) {
    print_char_line('-', 0);
    print_framed_text_left("[0] Exit Room", '|', false, 0, 0);
    print_char_line('-', 0);
    choice = multi_choice(NULL, choices, 1);
    move_up(1);
    clear_line();
  }
  free_safe(choices);
}

void view_game_waiting(Match* match) {
  clear_screen();
  char* line_1 = malloc(TEXT_LINE_MEM);
  char* line_2 = malloc(TEXT_LINE_MEM);
  char* spinner_text = malloc(TEXT_LINE_MEM);

  sprintf(spinner_text, "Waiting for match to start...");
  initial_status = match->match_status;
  pthread_t tid_1;
  pthread_t tid_2;
  sprintf(line_1, "Status: %s", get_match_status_string(match->match_status));
  sprintf(line_2, "Room #%d", match->room_id);
  print_char_line('-', 0);
  print_framed_text(line_1, '|', false, 0, 0);
  print_char_line('-', 0);
  print_framed_text(line_2, '|', false, 0, 0);
  print_char_line('-', 0);

  WaitingPollThreadConfig* thread_config = malloc(sizeof(WaitingPollThreadConfig));
  thread_config->match = match;
  thread_config->spinner_text = spinner_text;
  if (spinner_config == NULL) {
    spinner_config = get_spinner_config();
  }

  if (pthread_create(&tid_1, NULL, waiting_poll_match_thread, thread_config)) {
    printffn("Error: Failed to create Thread!\n");
    exit(-1);
  }

  if (pthread_create(&tid_2, NULL, lobby_waiting_input, thread_config)) {
    printffn("Error: Failed to create Thread!\n");
    exit(-1);
  }

  while (match->match_status != STARTED) {
    if (match->match_status != initial_status) {
      initial_status = match->match_status;
      move_to(2, 0);
      sprintf(line_1, "Status: %s",
        get_match_status_string(match->match_status));
      set_color(STYLE_BOLD);
      print_framed_text(line_1, '|', false, YELLOW_TXT, 0);
      move_down(3);
      clear_line();
      move_down(1);
      clear_line();
      move_down(1);
      clear_line();
      move_down(1);
      clear_line();
      move_up(3);
    }

    if (match->match_status == LOBBY) {
      set_can_exit_flag(0, "Can't quit game while inside a lobby!");
      if (choice == '0') {
        initial_status = match->match_status;
        update_match_details();
        exit_room(match->room_id);
        bool can_leave = did_player_leave();
        printf("Result of can leave: %d - Match Status: %s \n\n", can_leave, get_match_status_string(match->match_status));
        if (can_leave == 1) {
          thread_config->match = NULL;
          set_current_match(NULL);
          goto exit_match;
        }
      }
    } else if (match->match_status == COUNTDOWN) {
      set_can_exit_flag(0, "Can't quit game while waiting for the match to start!");
      sprintf(spinner_text, "Number of players in room: %d", match->players_num);
      print_spinner(spinner_text, spinner_config);
    }
  }

exit_match:
  clear_screen();
  pthread_cancel(tid_1);
  pthread_cancel(tid_2);
  free_safe(spinner_text);
  free_safe(line_1);
  free_safe(line_2);
  set_can_exit_flag(1, NULL);
}
