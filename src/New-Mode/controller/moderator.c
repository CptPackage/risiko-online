#include "moderator.h"
#include "../utils/io.h"
#include "../model/db.h"
#include "../view/m_mainmenu.h"
#include "../utils/view.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "../model/session.h"
#include "../utils/mem.h"

static bool create_new_room(void) {
  int numberOfActivePlayers = get_active_players_count();
  int numberOfRooms = get_rooms_count();
  int numberOfRoomsNeeded = (int)ceil((float)numberOfActivePlayers / 6);
  int numberOfExtraRoomsNeeded = numberOfRoomsNeeded - numberOfRooms;
  if (numberOfExtraRoomsNeeded < 0) {
    numberOfExtraRoomsNeeded = 0;
  }
  char* stats_info = malloc(SMALL_MEM);
  sprintf(stats_info, "  Active Players: %d | Rooms Count: %d | Extra Rooms Needed: %d",
    numberOfActivePlayers, numberOfRooms, numberOfExtraRoomsNeeded);

  clear_screen();
  set_color(STYLE_BOLD);
  print_star_line(0);
  print_framed_text("CREATE NEW ROOMS", '*', false, 0, 0);
  print_star_line(0);
  print_framed_text_left(stats_info, '*', false, 0, 0);
  print_char_line('*', 0);
  int numberOfRoomsToCreate = get_input_number(" Number of new rooms to create:");
  if (numberOfRoomsToCreate <= 0) {
    return false;
  }
  int turnDuration = get_input_number(" Enter turn duration for new rooms [Seconds]:");
  if (numberOfRoomsToCreate <= 0) {
    return false;
  }
  char* resultBuffer = malloc(SMALL_MEM);
  int createdRoomNumber = 0;
  for (int i = 0;i < numberOfRoomsToCreate;i++) {
    createdRoomNumber = create_room(turnDuration);
    sprintf(resultBuffer,
      "[New Room Created] Room Number: %d | Turn Duration: %d | Creator: %s",
      createdRoomNumber, turnDuration, current_user);
    print_char_line('+', 0);
    print_framed_text_left(resultBuffer, '+', false, 0, 0);
    print_char_line('+', 0);
  }
  press_anykey();
  free(stats_info);
  return false;
}

static bool display_analytical_report(void) {
  int recentlyActivePlayersCount = get_recently_active_players_count();
  ActiveMatchesStats* activeStats = get_ingame_matches_and_players();
  char* line_1 = malloc(TINY_MEM);
  char* line_2 = malloc(TINY_MEM);
  char* line_3 = malloc(TINY_MEM);
  sprintf(line_1, " Ingame Matches: %d ", activeStats->numberOfStartedMatches);
  sprintf(line_2, " Ingame Players: %d", activeStats->numberOfIngamePlayers);
  sprintf(line_3, " Recently Active Players: %d", recentlyActivePlayersCount);


  clear_screen();
  set_color(STYLE_BOLD);
  print_star_line(0);
  print_framed_text("ANALYTICAL REPORT", '*', false, 0, 0);
  print_star_line(0);
  print_char_line('+', 0);
  print_framed_text_left(line_1, '|', false, 0, 0);
  print_framed_text_left(line_2, '|', false, 0, 0);
  print_framed_text_left(line_3, '|', false, 0, 0);
  print_char_line('+', 0);
  free(activeStats);
  free(line_1);
  free(line_2);
  free(line_3);
  press_anykey();
  return false;
}


static bool exit_game(void) {
  logout();
  return true;
}

static struct {
  enum actions action;
  bool (*control)(void);
} controls[END_OF_ACTIONS] = {
    {.action = CREATE_ROOM, .control = create_new_room},
    {.action = DISPLAY_ANALYTICAL_REPORT, .control = display_analytical_report},
    {.action = EXIT, .control = exit_game} };

void controller_moderator(void) {
  db_switch_to_moderator();

  while (true) {
    int action = view_main_menu_mod();
    if (action >= END_OF_ACTIONS) {
      fprintf(stderr, "Error: unknown action\n");
      continue;
    }
    if (controls[action].control())
      break;

  }
}
