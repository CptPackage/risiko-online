#include "../view/login.h"
#include "../model/db.h"
#include "../utils/view.h"
#include "login.h"
#include <stdbool.h>

bool login(void) {
  Credentials creds;
  view_login(&creds);
  role_t role = attempt_login(&creds);

  switch (role) {
  case PLAYER:
    controller_player();
    break;
  case MODERATOR:
    print_info_text("Moderator logged in!");
    // controller_moderator();
    break;
  default:
    print_warning_text("Login Failed!");
    return false;
  }

  return true;
}
