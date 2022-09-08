#pragma once
#include <mysql.h>

#define MATCH_STATUS_NUM 4

typedef enum {
  LOBBY = 0,
  COUNTDOWN = 1,
  STARTED = 2,
  ENDED = 3
} match_status_t;

typedef struct _match {
  int match_id;
  int room_id;
  int players_num;
  MYSQL_TIME* match_start_countdown;
  match_status_t match_status;
} Match;


typedef struct _matches {
  int matches_count;
  Match matches[];
} Matches_List;

char *get_match_status_string(match_status_t match_status);
char *match_status_strings[MATCH_STATUS_NUM];
