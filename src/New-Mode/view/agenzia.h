#pragma once
#include "../model/db.h"

enum actions {
	BOOK_FLIGHT,
	BOOKING_REPORT,
	LIST_FLIGHTS,
	QUIT,
	END_OF_ACTIONS
};

extern int get_agency_action(void);
extern void get_agency_booking_information(struct booking *info);
extern void show_booking_report(struct booking_report *report);
