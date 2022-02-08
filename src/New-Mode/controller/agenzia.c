#include <stdio.h>
#include <string.h>
#include "agenzia.h"

#include "../model/db.h"
#include "../view/agenzia.h"
#include "../utils/io.h"

static bool book_flight(void)
{
	int reservation;
	struct booking booking_info;
	memset(&booking_info, 0, sizeof(booking_info));
	get_agency_booking_information(&booking_info);
	reservation = do_booking(&booking_info);

	if(reservation > 0)
		printf("Reserved seat with reservation number: %d\n", reservation);
	return false;
}


static bool booking_report(void)
{
	struct booking_report *report = do_booking_report();
	if(report != NULL) {
		show_booking_report(report);
		booking_report_dispose(report);
	}
	return false;
}


static bool list_flights(void)
{
	puts("Sorry, unimplemented!");
	return false;
}


static bool quit(void)
{
	return true;
}

static struct {
	enum actions action;
	bool (*control)(void);
} controls[END_OF_ACTIONS] = {
	{.action = BOOK_FLIGHT, .control = book_flight},
	{.action = BOOKING_REPORT, .control = booking_report},
	{.action = LIST_FLIGHTS, .control = list_flights},
	{.action = QUIT, .control = quit}
};

void controller_agenzia(void)
{
	db_switch_to_agency();

	while(true) {
		int action = get_agency_action();
		if(action >= END_OF_ACTIONS) {
			fprintf(stderr, "Error: unknown action\n");
			continue;
		}
		if (controls[action].control())
			break;

		press_anykey();
	}
}
