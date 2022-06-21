#pragma once

typedef enum { QUIT = 0, LOST = 1, WON = 2 } match_result_t;

typedef struct _match_log {
  int match_id;
  int room_id;
  char *start_time;
  char *end_time;
  match_result_t result;
} MatchLog;
