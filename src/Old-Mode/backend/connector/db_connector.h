#ifndef DB_CONNECTOR
#define DB_CONNECTOR

#include <stdio.h>
#include "../../clients/initiator.h"
#include <mysql>

MYSQL *DBConnect(AppConfig config);
#endif