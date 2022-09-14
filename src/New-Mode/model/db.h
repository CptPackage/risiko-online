#pragma once
#include <stdbool.h>
#include <stdlib.h>
#include "p_match.h"
#include "p_match_history.h"

extern bool init_db(void);
extern void fini_db(void);

#define DATE_LEN 11
#define TIME_LEN 6
#define DATETIME_LEN (DATE_LEN + TIME_LEN)

#define USERNAME_LEN 45
#define PASSWORD_LEN 45

typedef struct _credentials {
  char username[USERNAME_LEN];
  char password[PASSWORD_LEN];
} Credentials;

typedef enum { LOGIN_ROLE, PLAYER, MODERATOR, FAILED_LOGIN } role_t;

extern void db_switch_to_login(void);
extern role_t attempt_login(Credentials *cred);
extern void db_switch_to_moderator(void);
extern void db_switch_to_player(void);
extern void logout(void);


/*                                 Moderator Data Structures                          */
typedef struct _active_matches_stats {
  int numberOfStartedMatches;
  int numberOfIngamePlayers;
} ActiveMatchesStats;


/*                                  Player Functions                                  */
extern Matches_List* get_joinable_rooms(int page_size);
extern Matches_Logs_List* get_player_history(void);
extern bool join_room(int roomNumber);
extern void exit_room(int roomNumber);
extern bool did_player_leave(void);
extern void update_match_details(void); //Last Impl.
extern PlayersList* get_match_players(void);
extern Turn* get_latest_turn(void);
extern bool does_turn_have_action(Turn* turn);
extern Action* get_turn_action(Turn* turn);
extern void get_action_details(Action* action);
extern player_status_t did_player_win_or_lose(void);
extern int get_player_unplaced_tanks(void);
extern Territories* get_personal_territories(void);
extern Territories* get_scoreboard(void);
extern Territories* get_actionable_territories(void); //Nations with tanks number > 1
extern Territories* get_neighbour_territories(char territory_nation[NATION_NAME_SIZE]);
extern Territories* get_attackable_territories(char territory_nation[NATION_NAME_SIZE]);
extern void action_placement(char territory_nation[NATION_NAME_SIZE], int tanks_number);
extern void action_movement(char source_territory_nation[NATION_NAME_SIZE],char target_territory_nation[NATION_NAME_SIZE], int tanks_number);
extern void action_combat(char attacker_territory_nation[NATION_NAME_SIZE],char defender_territory_nation[NATION_NAME_SIZE]);



/*                                  Moderator Functions                                  */
extern int get_active_players_count(void);
extern int create_room(int turnDuration);
extern int get_recently_active_players_count(void);
extern ActiveMatchesStats* get_ingame_matches_and_players(void);
extern int get_rooms_count(void);