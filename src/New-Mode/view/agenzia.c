#include <stdio.h>

#include "agenzia.h"
#include "../utils/io.h"
#include "../utils/validation.h"

int get_agency_action(void)
{
	char options[4] = {'1','2', '3', '4'};
	char op;

	clear_screen();
	puts("*********************************");
	puts("*    TRAVEL AGENCY DASHBOARD    *");
	puts("*********************************\n");
	puts("*** What should I do for you? ***\n");
	puts("1) Book flight");
	puts("2) Booking list");
	puts("3) List flights");
	puts("4) Quit");

	op = multi_choice("Select an option", options, 4);
	return op - '1';
}


void get_agency_booking_information(struct booking *info)
{
	clear_screen();
	puts("** Book a Seat on a Flight **\n");

	get_input("Insert flight ID: ", ID_LEN, info->idVolo, false);

	while(true) {
		if(validate_date(get_input("Insert day [YYYY-MM-DD]: ", DATE_LEN, info->giorno, false)))
			break;
		fprintf(stderr, "Invalid date!\n");
	}

	get_input("Name: ", NAME_SURNAME_LEN, info->name, false);
	get_input("Surname: ", NAME_SURNAME_LEN, info->surname, false);
}


void show_booking_report(struct booking_report *report)
{
	clear_screen();
	puts("** FLIGHT BOOKING INFORMATION **\n");

	for(size_t i = 0; i < report->num_flights; i++) {
		printf("\n%s (%s -> %s), %s\n", report->flights[i].idVolo, report->flights[i].cittaPart,
				report->flights[i].cittaArr, report->flights[i].giorno);

		for(size_t j = 0; j < report->flights[i].num_bookings; j++) {
			printf("\t%03zu) %s %s\n", j, report->flights[i].bookings[j].surname, report->flights[i].bookings[j].name);
		}
	}
}
