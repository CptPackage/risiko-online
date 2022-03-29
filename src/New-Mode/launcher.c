#include "model/db.h"
#include "model/p_match.h"
#include "model/p_match_history.h"
#include "utils/dotenv.h"
#include "utils/io.h"
#include "utils/validation.h"
#include "utils/view.h"
#include "view/calibrate.h"
#include "view/login.h"
#include "view/m_mainmenu.h"
#include "view/p_game_ingame.h"
#include "view/p_game_waiting.h"
#include "view/p_lobby.h"
#include "view/p_mainmenu.h"
#include "view/p_match_history.h"
#include "view/p_match_result.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

  check_env_failing("GUEST_USER");
  check_env_failing("GUEST_PASS");
  check_env_failing("MODERATOR_USER");
  check_env_failing("MODERATOR_PASS");
  check_env_failing("PLAYER_USER");
  check_env_failing("PLAYER_PASS");
  return ret;
}
#undef set_env_failing

#define PLAYER_MODE "P-MODE"
#define MODERATOR_MODE "M-MODE"
#define MOD_FLAG "--moderator"

void initApp(char *gameMode);
int startup();

int main(int argc, char **argv) {
  // int startup_status = startup();
  // if (startup_status) {
  //   printff("Error: Failed during startup procedure!\n");
  //   return -1;
  // }
  //
  // if (initialize_io()) {
  //   if (argc < 2) {
  //     initApp(PLAYER_MODE);
  //   } else if (argc == 2 && strcmp(argv[1], MOD_FLAG) == 0) {
  //     initApp(MODERATOR_MODE);
  //   } else {
  //     return -1;
  //   }
  // }
  // view_calibrate();
  // Credentials creds;
  // view_login(&creds);
  // printff("Username: %s\n", creds.username);
  // printff("Password: %s\n", creds.password);
  // view_main_menu_player();
  // view_main_menu_mod();
  // int logs_size = 3;
  // MatchLog **logs = malloc(sizeof(MatchLog *) * logs_size);
  // MatchLog log1 = {1, 1, "27/5/2012 - 05:00", "27/5/2012 - 05:30", WON};
  // MatchLog log2 = {2, 2, "27/5/2012 - 07:00", "27/5/2012 - 07:30", QUIT};
  // MatchLog log3 = {3, 3, "27/5/2012 - 07:00", "27/5/2012 - 08:30", LOST};
  // logs[0] = &log1;
  // logs[1] = &log2;
  // logs[2] = &log3;
  // view_match_history_list(logs, logs_size);
  // clear_screen();
  // print_logo(BLUE_TXT, CYAN_TXT, BLACK_BG);
  Match match_1 = {1, 1, 4, LOBBY};
  // view_game_waiting(&match_1);
  view_game_ingame(&match_1);

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

  pause();
  // fini_db();
  // fini_validation();
  return 0;
}

void initApp(char *gameMode) {
  if (strcmp(gameMode, MODERATOR_MODE) == 0) {
    // view_m_login(); // Attempt login, if successful then switch user to
    // Moderator Mode
  } else {
    // view_p_login(); // Attempt login, if successful then switch user to
    // Player Mode
  }
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

  return 0;
}
