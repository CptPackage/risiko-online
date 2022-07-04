#include "controller/login.h"
#include "controller/player.h"
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

int main(int argc, char **argv) {
  if (startup()) {
    printff("Error: Failed during startup procedure!\n");
    return -1;
  }

  /*                      [TEMP] TEST AREA                       */

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
    // view_calibrate(); // CALIBRATION DISABLED DURING DEVELOPMENT
    
    initApp();
  }

  fini_db();
  fini_validation();
  return 0;
}

void initApp() {
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
  return 0;
}
