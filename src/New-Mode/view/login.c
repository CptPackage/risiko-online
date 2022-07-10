#include "login.h"
#include "../model/db.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

void view_login(Credentials *cred) {
  Colors risiko_color = CYAN_TXT;
  Colors online_color = BLUE_TXT;
  Colors container_color = BLACK_BG;
  clear_screen();
  print_logo(risiko_color, online_color, container_color);
  set_color(STYLE_NORMAL);
  set_color(STYLE_ITALIC);
  set_color(BLACK_BG);
  clear_line();
  set_color(risiko_color);
  get_input("Username:", USERNAME_LEN, cred->username, false, false);
  clear_line();
  set_color(online_color);
  *can_exit_flag = 0;
  get_input("Password:", PASSWORD_LEN, cred->password, true, false);
  *can_exit_flag = 1;
  reset_color();
}

bool ask_for_relogin(void) {
  return yes_or_no("Do you want to log in as a different user?", 'y', 'n',
                   false, true);
}
