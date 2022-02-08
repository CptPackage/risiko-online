#include <stdio.h>

#include "amministratore.h"
#include "../utils/io.h"
#include "../utils/validation.h"

int get_administrator_action(void)
{
	char options[3] = {'1','2', '3'};
	char op;

	clear_screen();
	puts("*********************************");
	puts("*    ADMINISTRATOR DASHBOARD    *");
	puts("*********************************\n");
	puts("*** What should I do for you? ***\n");
	puts("1) Register flight");
	puts("2) Print occupancy report");
	puts("3) Quit");

	op = multi_choice("Select an option", options, 3);
	return op - '1';
}


void get_administrator_register_flight_information(struct flight *flight)
{
	clear_screen();
	printf("** Flight Details Registration **\n\n");
	get_input("Insert flight ID: ", ID_LEN, flight->idVolo, false);
	get_input("Insert departure city: ", CITTA_LEN, flight->cittaPart, false);
	get_input("Insert arrival city: ", CITTA_LEN, flight->cittaArr, false);

	while(true) {
		get_input("Insert day [YYYY-MM-DD]: ", DATE_LEN, flight->giorno, false);
		if(validate_date(flight->giorno))
			break;
		fprintf(stderr, "Invalid date!\n");
	}

	while(true) {
		get_input("Insert departure time [HH:MM]: ", TIME_LEN, flight->oraPart, false);
		if(validate_time(flight->oraPart))
			break;
		fprintf(stderr, "Invalid time!\n");
	}

	while(true) {
		get_input("Insert arrival time [HH:MM]: ", TIME_LEN, flight->oraArr, false);
		if(validate_time(flight->oraPart))
			break;
		fprintf(stderr, "Invalid time!\n");
	}

	get_input("Aircraft type: ", TIPO_LEN, flight->tipoAereo, false);
}

void print_occupancy(struct occupancy *occupancy)
{
	clear_screen();
	printf("** Current Flight Occupancy **\n\n");

	for(size_t i = 0; i < occupancy->num_entries; i++) {
		printf("%s: %s (%s) -> %s (%s): booked %d/%d (%f%%)\n",
			occupancy->occupancy[i].idVolo,
			occupancy->occupancy[i].cittaPart,
			occupancy->occupancy[i].partenza,
			occupancy->occupancy[i].cittaArr,
			occupancy->occupancy[i].arrivo,
			occupancy->occupancy[i].prenotati,
			occupancy->occupancy[i].disponibili,
			occupancy->occupancy[i].occupazione);
	}
}
