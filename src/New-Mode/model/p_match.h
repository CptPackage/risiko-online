#pragma once
#include <mysql.h>
#include <stdbool.h>

#define MATCH_STATUS_NUM 4
#define TIMESTAMP_SIZE 17
#define USERNAME_SIZE 45
#define NATION_NAME_SIZE 32

typedef enum {
  LOBBY = 0,
  COUNTDOWN = 1,
  STARTED = 2,
  ENDED = 3
} match_status_t;

typedef enum {
  PLACEMENT = 0,
  MOVEMENT = 1,
  COMBAT = 2
} action_types_t;

typedef enum {
  INGAME = 0,
  LOSS = 1,
  WIN = 2,
} player_status_t;

typedef struct _match {
  int match_id;
  int room_id;
  int players_num;
  char match_start_countdown[TIMESTAMP_SIZE];
  match_status_t match_status;
} Match;

typedef struct _matches {
  int matches_count;
  Match matches[];
} Matches_List;

typedef struct _turn {
  int match_id;
  int turn_id;
  char player[USERNAME_SIZE];
  char turn_start_time[TIMESTAMP_SIZE];
} Turn;

typedef struct _action_details {
  action_types_t action_type;
  void* content;
} ActionDetails;

typedef struct _movement {
  char source_nation[NATION_NAME_SIZE];
} Movement;

typedef struct _combat {
  char attacker_nation[NATION_NAME_SIZE];
  char defender_player[USERNAME_SIZE];
  int defender_tanks_number;
  int attaker_lost_tanks;
  int defender_lost_tanks;
  bool succeded;
} Combat;


typedef struct _action {
  int match_id;
  int turn_id;
  int action_id;
  char player[USERNAME_SIZE];
  char target_nation[NATION_NAME_SIZE];
  int tanks_number;
  ActionDetails* details;
} Action;


typedef struct _territory {
  int match_id;
  char nation[NATION_NAME_SIZE];
  char occupier[USERNAME_SIZE];
  int occupying_tanks_number;
} Territory;

typedef struct _territories {
  int territories_count;
  Territory** territories;
} Territories;


typedef struct _players_list {
  int players_count;
  char players[6][USERNAME_SIZE];
} PlayersList;

char *get_match_status_string(match_status_t match_status);
char *match_status_strings[MATCH_STATUS_NUM];
