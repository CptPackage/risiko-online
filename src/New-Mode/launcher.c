#include "controller/login.h"
#include "signal.h"
#include "utils/dotenv.h"
#include "utils/io.h"
#include "utils/validation.h"
#include "utils/view.h"
#include "view/calibrate.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <math.h>
#include "model/session.h"


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

int main(int argc, char** argv) {
  if (startup()) {
    printff("Error: Failed during startup procedure!\n");
    return -1;
  }


  // Init
  if (initialize_io()) {
    clear_screen();
    view_calibrate(); 
    initApp(); 
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
