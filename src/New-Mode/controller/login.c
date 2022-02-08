#include <stdbool.h>

#include "login.h"
#include "amministratore.h"
#include "agenzia.h"
#include "../view/login.h"
#include "../model/db.h"


bool login(void)
{
	struct credentials cred;
	view_login(&cred);
	role_t role = attempt_login(&cred);

	switch(role) {
		case AMMINISTRATORE:
			administrator_controller();
			break;
		case AGENZIA:
			controller_agenzia();
			break;
		default:
			return false;
	}

	return true;
}
