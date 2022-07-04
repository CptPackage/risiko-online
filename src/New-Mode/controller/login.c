#include "../controller/player.h"
#include "../controller/moderator.h"
#include "../view/login.h"
#include "../utils/view.h"
#include "login.h"
#include <stdbool.h>
#include <unistd.h>

bool login(void) {
  role_t role;
  while(role != PLAYER && role != MODERATOR){
  Credentials creds;
  view_login(&creds);
   role = attempt_login(&creds);
    switch (role) {
    case PLAYER:
      controller_player();
      break;
    case MODERATOR:
      controller_moderator();
      break;
    default:
      print_warning_text("Login Failed!");
      sleep(1);
    }
  }

  return true;
}
