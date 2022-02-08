#pragma once
#include "../model/db.h"

enum actions {
	REGISTER_FLIGHT,
	REPORT_OCCUPANCY,
	QUIT,
	END_OF_ACTIONS
};

extern int get_administrator_action(void);
extern void get_administrator_register_flight_information(struct flight *flight);
extern void print_occupancy(struct occupancy *occupancy);
