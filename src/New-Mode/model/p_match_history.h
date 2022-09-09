#pragma once

typedef enum { ELIMINATED = 0, WON = 1 } match_result_t;

typedef struct _match_log {
  int match_id;
  int room_id;
  char start_time[17];
  char end_time[17];
  match_result_t result;
} Match_Log;



typedef struct _matches_logs_list {
  int logs_count;
  Match_Log logs[];
} Matches_Logs_List;