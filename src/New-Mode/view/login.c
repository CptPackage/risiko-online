#include "login.h"
#include "../model/db.h"
#include "../utils/io.h"
#include "../utils/view.h"
#include <stdio.h>

void view_login(Credentials *cred) {
  clear_screen();
  print_star_line();
  print_framed_text(" :::====  ::: :::===  ::: :::  === :::==== ", '*', false);
  print_framed_text(" :::  === ::: :::     ::: ::: ===  :::  ===", '*', false);
  print_framed_text(" =======  ===  =====  === ======   ===  ===", '*', false);
  print_framed_text(" === ===  ===     === === === ===  ===  ===", '*', false);
  print_framed_text(" ===  === === ======  === ===  ===  ====== ", '*', false);
  print_framed_text(" ", '*', false);
  print_framed_text(" :::====  :::= === :::      ::: :::= === :::=====", '*',
                    false);
  print_framed_text(" :::  === :::===== :::      ::: :::===== :::     ", '*',
                    false);
  print_framed_text(" ===  === ======== ===      === ======== ======  ", '*',
                    false);
  print_framed_text(" ===  === ======== ===      === ======== ======  ", '*',
                    false);
  print_framed_text(" ===  === === ==== ===      === === ==== ===     ", '*',
                    false);
  print_framed_text("  ======  ===  === ======== === ===  === ========", '*',
                    false);
  print_star_line();
  get_input("Username:", USERNAME_LEN, cred->username, false, false);
  get_input("Password:", PASSWORD_LEN, cred->password, true, false);
}

bool ask_for_relogin(void) {
  return yes_or_no("Do you want to log in as a different user?", 'y', 'n',
                   false, true);
}
