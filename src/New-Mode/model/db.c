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


void db_switch_user_to_moderator(void)
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


