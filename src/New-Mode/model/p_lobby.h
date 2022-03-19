#pragma once

typedef enum {
  LOBBY = 0,
  COUNTDOWN = 1,
  STARTED = 2,
  ENDED = 3
} lobby_match_status;

typedef struct _lobby_match {
  int match_id;
  int room_id;
  int players_num;
  lobby_match_status match_status;
} LobbyMatch;
