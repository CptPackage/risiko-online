#include <stdio.h>

#include "login.h"
#include "../utils/io.h"

void view_login(struct credentials *cred)
{
	clear_screen();
	puts("*********************************");
	puts("*   AIRPORT MANAGEMENT SYSTEM   *");
	puts("*********************************\n");
	get_input("Username: ", USERNAME_LEN, cred->username, false);
	get_input("Password: ", PASSWORD_LEN, cred->password, true);
}

bool ask_for_relogin(void)
{
	return yes_or_no("Do you want to log in as a different user?", 'y', 'n', false, true);
}
