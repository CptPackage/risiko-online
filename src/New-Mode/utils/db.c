#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <mysql.h>

#include "db.h"
#include "../model/db.h"

void print_stmt_error (MYSQL_STMT *stmt, char *message)
{
	fprintf (stderr, "%s\n", message);
	if (stmt != NULL) {
		fprintf (stderr, "Error %u (%s): %s\n",
			 mysql_stmt_errno (stmt),
			 mysql_stmt_sqlstate(stmt),
			 mysql_stmt_error (stmt));
	}
}

void print_error(MYSQL *conn, char *message)
{
	fprintf (stderr, "%s\n", message);
	if (conn != NULL) {
#if MYSQL_VERSION_ID >= 40101
		fprintf (stderr, "Error %u (%s): %s\n",
			 mysql_errno (conn), mysql_sqlstate(conn), mysql_error (conn));
#else
		fprintf (stderr, "Error %u: %s\n",
		mysql_errno (conn), mysql_error (conn));
#endif
	}
}


bool setup_prepared_stmt(MYSQL_STMT **stmt, char *statement, MYSQL *conn)
{
	bool update_length = true;

	*stmt = mysql_stmt_init(conn);
	if (*stmt == NULL)
	{
		print_error(conn, "Could not initialize statement handler");
		return false;
	}

	if (mysql_stmt_prepare (*stmt, statement, strlen(statement)) != 0) {
		print_stmt_error(*stmt, "Could not prepare statement");
		return false;
	}

	mysql_stmt_attr_set(*stmt, STMT_ATTR_UPDATE_MAX_LENGTH, &update_length);

	return true;
}


void finish_with_error(MYSQL *conn, char *message)
{
	print_error(conn, message);
	mysql_close(conn);
	exit(EXIT_FAILURE);
}


void finish_with_stmt_error(MYSQL *conn, MYSQL_STMT *stmt, char *message, bool close_stmt)
{
	print_stmt_error(stmt, message);
	if(close_stmt)
		mysql_stmt_close(stmt);
	mysql_close(conn);
	exit(EXIT_FAILURE);
}


void set_binding_param(MYSQL_BIND *param, enum enum_field_types type, void *buffer, unsigned long len)
{
	memset(param, 0, sizeof(*param));

	param->buffer_type = type;
	param->buffer = buffer;
	param->buffer_length = len;
}


void date_to_mysql_time(char *str, MYSQL_TIME *time)
{
	memset(time, 0, sizeof(*time));
	sscanf(str, "%4d-%2d-%2d", &time->year, &time->month, &time->day);
	time->time_type = MYSQL_TIMESTAMP_DATE;
}


void time_to_mysql_time(char *str, MYSQL_TIME *time)
{
	memset(time, 0, sizeof(*time));
	sscanf(str, "%02d:%02d", &time->hour, &time->minute);
	time->time_type = MYSQL_TIMESTAMP_TIME;
}

void init_mysql_timestamp(MYSQL_TIME *time)
{
	memset(time, 0, sizeof (*time));
	time->time_type = MYSQL_TIMESTAMP_DATETIME;
}

void mysql_timestamp_to_string(MYSQL_TIME *time, char *str)
{
	snprintf(str, DATETIME_LEN, "%4d-%02d-%02d %02d:%02d", time->year, time->month, time->day, time->hour, time->minute);
}

void mysql_date_to_string(MYSQL_TIME *date, char *str)
{
	snprintf(str, DATE_LEN, "%4d-%02d-%02d", date->year, date->month, date->day);
}
