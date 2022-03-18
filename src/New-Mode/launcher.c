#include "model/db.h"
#include "utils/dotenv.h"
#include "utils/io.h"
#include "utils/validation.h"
#include "utils/view.h"
#include "view/calibrate.h"
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
  // view_login();
  print_star_line();
  print_dash_line();
  print_char_line('_');
  print_char_line('~');
  print_char_line('|');
  print_char_line('>');
  print_char_line('+');
  print_tabs(5);
  printffn("Hello mate!");
  int labels_num = 4;
  char **labels = malloc(sizeof(char *) * labels_num);
  char *choices = malloc(sizeof(char) * labels_num);
  memset(choices, 0, labels_num);
  labels[0] = "USA";
  labels[1] = "UK";
  labels[2] = "Afghanistan";
  labels[3] = "The Great Empire of Old Britian";
  choices[0] = 'A';
  choices[1] = 'B';
  choices[2] = 'C';
  choices[3] = 'D';
  print_menu("Welcome Menu", labels, choices, labels_num, 'o');
  free(labels);
  free(choices);
  // while (1) {
  //   scanf("%s", buffer);
  //   print_padded_text(buffer, DEFAULT_PADDING_CHAR);
  // }

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
