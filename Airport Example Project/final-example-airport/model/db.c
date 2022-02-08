#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mysql.h>
#include <assert.h>

#include "db.h"
#include "../utils/db.h"

static MYSQL *conn;

static MYSQL_STMT *login_procedure;
static MYSQL_STMT *register_flight;
static MYSQL_STMT *get_occupancy;
static MYSQL_STMT *booking;
static MYSQL_STMT *booking_report;

static void close_prepared_stmts(void)
{
	if(login_procedure) {
		mysql_stmt_close(login_procedure);
		login_procedure = NULL;
	}
	if(register_flight) {
		mysql_stmt_close(register_flight);
		register_flight = NULL;
	}
	if(get_occupancy) {
		mysql_stmt_close(get_occupancy);
		get_occupancy = NULL;
	}
	if(booking) {
		mysql_stmt_close(booking);
		booking = NULL;
	}
	if(booking_report) {
		mysql_stmt_close(booking_report);
		booking_report = NULL;
	}
}

static bool initialize_prepared_stmts(role_t for_role)
{
	switch(for_role) {

		case LOGIN_ROLE:
			if(!setup_prepared_stmt(&login_procedure, "call login(?, ?, ?)", conn)) {
				print_stmt_error(login_procedure, "Unable to initialize login statement\n");
				return false;
			}
			break;
		case AMMINISTRATORE:
			if(!setup_prepared_stmt(&register_flight, "call registra_volo(?, ?, ?, ?, ?, ?, ?)", conn)) {
				print_stmt_error(register_flight, "Unable to initialize register flight statement\n");
				return false;
			}
			if(!setup_prepared_stmt(&get_occupancy, "call report_occupazione_voli()", conn)) {
				print_stmt_error(register_flight, "Unable to initialize get occupancy statement\n");
				return false;
			}
			break;
		case AGENZIA:
			if(!setup_prepared_stmt(&booking, "call registra_prenotazione(?, ?, ?, ?, ?)", conn)) {
				print_stmt_error(booking, "Unable to initialize booking statement\n");
				return false;
			}
			if(!setup_prepared_stmt(&booking_report, "call report_prenotazioni()", conn)) {
				print_stmt_error(booking_report, "Unable to initialize booking report statement\n");
				return false;
			}
			break;
		default:
			fprintf(stderr, "[FATAL] Unexpected role to prepare statements.\n");
			exit(EXIT_FAILURE);
	}

	return true;
}

bool init_db(void)
{
	unsigned int timeout = 300;
	bool reconnect = true;

	conn = mysql_init(NULL);
	if(conn == NULL) {
		finish_with_error(conn, "mysql_init() failed (probably out of memory)\n");
	}

	if(mysql_real_connect(conn, getenv("HOST"), getenv("LOGIN_USER"), getenv("LOGIN_PASS"), getenv("DB"),
			      atoi(getenv("PORT")), NULL,
			      CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS | CLIENT_COMPRESS | CLIENT_INTERACTIVE | CLIENT_REMEMBER_OPTIONS) == NULL) {
		finish_with_error(conn, "mysql_real_connect() failed\n");
	}

	if (mysql_options(conn, MYSQL_OPT_CONNECT_TIMEOUT, &timeout)) {
		print_error(conn, "[mysql_options] failed.");
	}
	if(mysql_options(conn, MYSQL_OPT_RECONNECT, &reconnect)) {
		print_error(conn, "[mysql_options] failed.");
	}
#ifndef NDEBUG
	mysql_debug("d:t:O,/tmp/client.trace");
	if(mysql_dump_debug_info(conn)) {
		print_error(conn, "[debug_info] failed.");
	}
#endif

	return initialize_prepared_stmts(LOGIN_ROLE);
}


void fini_db(void)
{
	close_prepared_stmts();

	mysql_close(conn);
}


role_t attempt_login(struct credentials *cred)
{
	MYSQL_BIND param[3]; // Used both for input and output
	int role = 0;

	// Prepare parameters
	set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, cred->username, strlen(cred->username));
	set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, cred->password, strlen(cred->password));
	set_binding_param(&param[2], MYSQL_TYPE_LONG, &role, sizeof(role));

	if(mysql_stmt_bind_param(login_procedure, param) != 0) { // Note _param
		print_stmt_error(login_procedure, "Could not bind parameters for login");
		role = FAILED_LOGIN;
		goto out;
	}

	// Run procedure
	if(mysql_stmt_execute(login_procedure) != 0) {
		print_stmt_error(login_procedure, "Could not execute login procedure");
		role = FAILED_LOGIN;
		goto out;
	}

	// Prepare output parameters
	set_binding_param(&param[0], MYSQL_TYPE_LONG, &role, sizeof(role));

	if(mysql_stmt_bind_result(login_procedure, param)) {
		print_stmt_error(login_procedure, "Could not retrieve output parameter");
		role = FAILED_LOGIN;
		goto out;
	}

	// Retrieve output parameter
	if(mysql_stmt_fetch(login_procedure)) {
		print_stmt_error(login_procedure, "Could not buffer results");
		role = FAILED_LOGIN;
		goto out;
	}

    out:
	// Consume the possibly-returned table for the output parameter
	while(mysql_stmt_next_result(login_procedure) != -1) {}

	mysql_stmt_free_result(login_procedure);
	mysql_stmt_reset(login_procedure);
	return role;
}


void db_switch_to_login(void)
{
	close_prepared_stmts();
	if(mysql_change_user(conn, getenv("LOGIN_USER"), getenv("LOGIN_PASS"), getenv("DB"))) {
		fprintf(stderr, "mysql_change_user() failed: %s\n", mysql_error(conn));
		exit(EXIT_FAILURE);
	}
	if(!initialize_prepared_stmts(LOGIN_ROLE)) {
		fprintf(stderr, "[FATAL] Cannot initialize prepared statements.\n");
		exit(EXIT_FAILURE);
	}
}


void db_switch_to_administrator(void)
{
	close_prepared_stmts();
	if(mysql_change_user(conn, getenv("ADMINISTRATOR_USER"), getenv("ADMINISTRATOR_PASS"), getenv("DB"))) {
		fprintf(stderr, "mysql_change_user() failed: %s\n", mysql_error(conn));
		exit(EXIT_FAILURE);
	}
	if(!initialize_prepared_stmts(AMMINISTRATORE)) {
		fprintf(stderr, "[FATAL] Cannot initialize prepared statements.\n");
		exit(EXIT_FAILURE);
	}
}


void do_register_flight(struct flight *flight)
{
	MYSQL_BIND param[7];
	MYSQL_TIME giorno;
	MYSQL_TIME oraPart;
	MYSQL_TIME oraArr;

	// Make proper type conversion
	date_to_mysql_time(flight->giorno, &giorno);
	time_to_mysql_time(flight->oraPart, &oraPart);
	time_to_mysql_time(flight->oraArr, &oraArr);

	// Bind parameters
	set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, flight->idVolo, strlen(flight->idVolo));
	set_binding_param(&param[1], MYSQL_TYPE_DATE, &giorno, sizeof(giorno));
	set_binding_param(&param[2], MYSQL_TYPE_VAR_STRING, flight->cittaPart, strlen(flight->cittaPart));
	set_binding_param(&param[3], MYSQL_TYPE_TIME, &oraPart, sizeof(oraPart));
	set_binding_param(&param[4], MYSQL_TYPE_VAR_STRING, flight->cittaArr, strlen(flight->cittaArr));
	set_binding_param(&param[5], MYSQL_TYPE_TIME, &oraArr, sizeof(oraArr));
	set_binding_param(&param[6], MYSQL_TYPE_VAR_STRING, flight->tipoAereo, strlen(flight->tipoAereo));

	if(mysql_stmt_bind_param(register_flight, param) != 0) {
		print_stmt_error(register_flight, "Could not bind parameters for do_register_flight");
		return;
	}

	// Run procedure
	if(mysql_stmt_execute(register_flight) != 0) {
		print_stmt_error(register_flight, "Could not execute register flight procedure");
		return;
	}

	mysql_stmt_free_result(register_flight);
	mysql_stmt_reset(register_flight);
}


struct occupancy *do_get_occupancy(void)
{
	int status;
	size_t row = 0;
	MYSQL_BIND param[8];
	MYSQL_TIME partenza;
	MYSQL_TIME arrivo;
	char idVolo[ID_LEN];
	char cittaPart[CITTA_LEN];
	char cittaArr[CITTA_LEN];
	int prenotati;
	int disponibili;
	double occupazione;
	struct occupancy *occupancy = NULL;

	// Initialize timestamps
	init_mysql_timestamp(&partenza);
	init_mysql_timestamp(&arrivo);

	// Run procedure
	if(mysql_stmt_execute(get_occupancy) != 0) {
		print_stmt_error(get_occupancy, "Could not execute get occupancy procedure");
		goto out;
	}

	mysql_stmt_store_result(get_occupancy);

	occupancy = malloc(sizeof(*occupancy) + sizeof(struct occupancy_entry) * mysql_stmt_num_rows(get_occupancy));
	if(occupancy == NULL)
		goto out;
	memset(occupancy, 0, sizeof(*occupancy) + sizeof(struct occupancy_entry) * mysql_stmt_num_rows(get_occupancy));
	occupancy->num_entries = mysql_stmt_num_rows(get_occupancy);

	// Get bound parameters
	mysql_stmt_store_result(get_occupancy);

	set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, idVolo, ID_LEN);
	set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, cittaPart, CITTA_LEN);
	set_binding_param(&param[2], MYSQL_TYPE_TIMESTAMP, &partenza, sizeof(partenza));
	set_binding_param(&param[3], MYSQL_TYPE_VAR_STRING, cittaArr, CITTA_LEN);
	set_binding_param(&param[4], MYSQL_TYPE_TIMESTAMP, &arrivo, sizeof(arrivo));
	set_binding_param(&param[5], MYSQL_TYPE_LONG, &prenotati, sizeof(prenotati));
	set_binding_param(&param[6], MYSQL_TYPE_LONG, &disponibili, sizeof(disponibili));
	set_binding_param(&param[7], MYSQL_TYPE_DOUBLE, &occupazione, sizeof(occupazione));

	if(mysql_stmt_bind_result(get_occupancy, param)) {
		print_stmt_error(get_occupancy, "Unable to bind output parameters for get occupancy\n");
		free(occupancy);
		occupancy = NULL;
		goto out;
	}

	/* assemble occupancy general information */
	while (true) {
		status = mysql_stmt_fetch(get_occupancy);

		if (status == 1 || status == MYSQL_NO_DATA)
			break;

		strcpy(occupancy->occupancy[row].idVolo, idVolo);
		strcpy(occupancy->occupancy[row].cittaPart, cittaPart);
		strcpy(occupancy->occupancy[row].cittaArr, cittaArr);
		mysql_timestamp_to_string(&partenza, occupancy->occupancy[row].partenza);
		mysql_timestamp_to_string(&arrivo, occupancy->occupancy[row].arrivo);
		occupancy->occupancy[row].prenotati = prenotati;
		occupancy->occupancy[row].disponibili = disponibili;
		occupancy->occupancy[row].occupazione = occupazione;

		row++;
	}
    out:
	mysql_stmt_free_result(get_occupancy);
	mysql_stmt_reset(get_occupancy);
	return occupancy;
}


void occupancy_dispose(struct occupancy *occupancy)
{
	free(occupancy);
}


void db_switch_to_agency(void)
{
	close_prepared_stmts();
	if(mysql_change_user(conn, getenv("AGENCY_USER"), getenv("AGENCY_PASS"), getenv("DB"))) {
		fprintf(stderr, "mysql_change_user() failed: %s\n", mysql_error(conn));
		exit(EXIT_FAILURE);
	}
	if(!initialize_prepared_stmts(AGENZIA)) {
		fprintf(stderr, "[FATAL] Cannot initialize prepared statements.\n");
		exit(EXIT_FAILURE);
	}
}


int do_booking(struct booking *info)
{
	MYSQL_BIND param[5];
	MYSQL_TIME giorno;
	int reservation;

	date_to_mysql_time(info->giorno, &giorno);

	set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, info->idVolo, strlen(info->idVolo));
	set_binding_param(&param[1], MYSQL_TYPE_DATE, &giorno, sizeof(giorno));
	set_binding_param(&param[2], MYSQL_TYPE_VAR_STRING, info->name, strlen(info->name));
	set_binding_param(&param[3], MYSQL_TYPE_VAR_STRING, info->surname, strlen(info->surname));
	set_binding_param(&param[4], MYSQL_TYPE_LONG, &reservation, sizeof(reservation));

	if(mysql_stmt_bind_param(booking, param)) {
		print_stmt_error(booking, "Could not bind input parameters");
		reservation = -1;
		goto out;
	}

	// Run procedure
	if(mysql_stmt_execute(booking) != 0) {
		print_stmt_error(booking, "Could not execute get occupancy procedure");
		reservation = -1;
		goto out;
	}

	// Prepare output parameters
	set_binding_param(&param[0], MYSQL_TYPE_LONG, &reservation, sizeof(reservation));

	if(mysql_stmt_bind_result(booking, param)) {
		print_stmt_error(booking, "Could not retrieve output parameter");
		reservation = -1;
		goto out;
	}

	// Retrieve output parameter
	if(mysql_stmt_fetch(booking)) {
		print_stmt_error(booking, "Could not buffer results");
		reservation = -1;
		goto out;
	}

    out:
	// Consume the possibly-returned table for the output parameter
	while(mysql_stmt_next_result(booking) != -1) {}

	mysql_stmt_free_result(booking);
	mysql_stmt_reset(booking);
	return reservation;
}

static struct booking_report *extract_flight_information(void)
{
	struct booking_report *report = NULL;
	int status;
	size_t row = 0;
	MYSQL_BIND param[4];
	char idVolo[ID_LEN];
	char cittaPart[CITTA_LEN];
	char cittaArr[CITTA_LEN];
	MYSQL_TIME giorno;

	set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, idVolo, ID_LEN);
	set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, cittaPart, CITTA_LEN);
	set_binding_param(&param[2], MYSQL_TYPE_VAR_STRING, cittaArr, CITTA_LEN);
	set_binding_param(&param[3], MYSQL_TYPE_DATE, &giorno, sizeof(giorno));

	if(mysql_stmt_bind_result(booking_report, param)) {
		print_stmt_error(booking_report, "Unable to bind column parameters\n");
		free(report);
		report = NULL;
		goto out;
	}

	// store_results should be called *after* binding and *before* fetching rows.
	if (mysql_stmt_store_result(booking_report)) {
		print_stmt_error(booking_report, "Unable to store booking information result set.");
		goto out;
	}

	report = malloc(sizeof(*report) + sizeof(struct flight_info) * mysql_stmt_num_rows(booking_report));
	if(report == NULL)
		goto out;
	memset(report, 0, sizeof(*report) + sizeof(struct flight_info) * mysql_stmt_num_rows(booking_report));
	report->num_flights = mysql_stmt_num_rows(booking_report);

	/* assemble flight general information */
	while (true) {
		status = mysql_stmt_fetch(booking_report);

		if (status == 1 || status == MYSQL_NO_DATA)
			break;

		strcpy(report->flights[row].idVolo, idVolo);
		strcpy(report->flights[row].cittaPart, cittaPart);
		strcpy(report->flights[row].cittaArr, cittaArr);
		mysql_date_to_string(&giorno, report->flights[row].giorno);

		row++;
	}
    out:
	return report;
}


static void extract_booking_information(struct booking_report *report, size_t i)
{
	MYSQL_BIND param[4];
	size_t row = 0;
	int status;
	char name[NAME_SURNAME_LEN];
	char surname[NAME_SURNAME_LEN];

	assert(i < report->num_flights);

	set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, surname, NAME_SURNAME_LEN);
	set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, name, NAME_SURNAME_LEN);

	if(mysql_stmt_bind_result(booking_report, param)) {
		/* TODO: better handling of the error: shall free only memory that was correctly allocated
		         so far, and return silently to the user interface... */
		finish_with_stmt_error(conn, booking_report, "[FATAL] Unable to bind column parameters\n", false);
	}

	// store_results should be called *after* binding and *before* fetching rows.
	mysql_stmt_store_result(booking_report);
	report->flights[i].bookings = malloc(sizeof(*report->flights[i].bookings) * mysql_stmt_num_rows(booking_report));
	report->flights[i].num_bookings = mysql_stmt_num_rows(booking_report);

	/* assemble booking general information */
	while (true) {
		status = mysql_stmt_fetch(booking_report);

		if (status == 1 || status == MYSQL_NO_DATA)
			break;

		strcpy(report->flights[i].bookings[row].name, name);
		strcpy(report->flights[i].bookings[row].surname, surname);

		row++;
	}
}


struct booking_report *do_booking_report(void)
{
	struct booking_report *report = NULL;
	unsigned count = 0;
	int status;

	if (mysql_stmt_execute(booking_report) != 0) {
		print_stmt_error(booking_report, "An error occurred while retrieving booking information for report.");
		goto out;
	}

	// We have multiple result sets here!
	do {
		// Skip OUT variables (although they are not present in the procedure...)
		if(conn->server_status & SERVER_PS_OUT_PARAMS) {
			goto next;
		}

		if(count == 0) {
			report = extract_flight_information();
			if(report == NULL)
				goto out;
		} else if(count - 1 < report->num_flights) {
			extract_booking_information(report, count - 1);
		}

    next:
		mysql_stmt_free_result(booking_report);
		// more results? -1 = no, >0 = error, 0 = yes (keep looking)
		status = mysql_stmt_next_result(booking_report);
		if (status > 0)
			// TODO: better handling, with memory reclaim, silent return to user, etc...
			finish_with_stmt_error(conn, booking_report, "Unexpected condition", false);

		count++;

	} while (status == 0);

    out:
	mysql_stmt_free_result(booking);
	mysql_stmt_reset(booking);
	return report;
}


void booking_report_dispose(struct booking_report *report)
{
	for(size_t i = 0; i < report->num_flights; i++) {
		free(report->flights[i].bookings);
	}
	free(report);
}
