#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "amministratore.h"
#include "../model/db.h"
#include "../view/amministratore.h"
#include "../utils/io.h"

static bool register_flight(void)
{
	struct flight flight;
	memset(&flight, 0, sizeof(flight));
	get_administrator_register_flight_information(&flight);
	do_register_flight(&flight);
	return false;
}


static bool report_occupancy(void)
{
	struct occupancy *occupancy = do_get_occupancy();
	if(occupancy != NULL) {
		print_occupancy(occupancy);
		occupancy_dispose(occupancy);
	}
	return false;
}


static bool quit(void) {
	return true;
}


static struct {
	enum actions action;
	bool (*control)(void);
} controls[END_OF_ACTIONS] = {
	{.action = REGISTER_FLIGHT, .control = register_flight},
	{.action = REPORT_OCCUPANCY, .control = report_occupancy},
	{.action = QUIT, .control = quit}
};


void administrator_controller(void)
{
	db_switch_to_administrator();

	while(true) {
		int action = get_administrator_action();
		if(action >= END_OF_ACTIONS) {
			fprintf(stderr, "Error: unknown action\n");
			continue;
		}
		if (controls[action].control())
			break;

		press_anykey();
	}
}
