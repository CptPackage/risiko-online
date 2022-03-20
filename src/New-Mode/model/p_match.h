#pragma once

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
  match_status_t match_status;
} Match;

char *match_status_strings[MATCH_STATUS_NUM];
