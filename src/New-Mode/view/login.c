#include "login.h"
#include "../utils/io.h"
#include <stdio.h>

void view_login(Credentials *cred) {
  clear_screen();
  puts("*********************************");
  puts("*   AIRPORT MANAGEMENT SYSTEM   *");
  puts("*********************************\n");
}

bool ask_for_relogin(void) {
  return yes_or_no("Do you want to log in as a different user?", 'y', 'n',
                   false, true);
}
