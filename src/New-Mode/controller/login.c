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
    case PLAYER: // LOGIN IN AS PLAYER
      controller_player();
      break;
    case MODERATOR: // LOGGED IN AS MODERATOR
      controller_moderator();
      break;
    default: // LOGIN FAILED
      print_warning_text("Incorrect username or password!");
      sleep(3);
    }
  }

  return true;
}
