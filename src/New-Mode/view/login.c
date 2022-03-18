#include "login.h"
#include "../model/db.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

void view_login(Credentials *cred) {
  char *username = malloc(sizeof(char) * USERNAME_LEN);
  char *password = malloc(sizeof(char) * PASSWORD_LEN);
  clear_screen();
  print_star_line();
  print_padded_text("Risiko Online", '*');
  print_star_line();
  get_input("Username:", USERNAME_LEN, username, false, true);
  get_input("Password:", PASSWORD_LEN, username, true, true);
  get_input(NULL, PASSWORD_LEN, username, true, true);
}

bool ask_for_relogin(void) {
  return yes_or_no("Do you want to log in as a different user?", 'y', 'n',
                   false, true);
}
