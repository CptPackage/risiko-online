#include "../utils/db.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "p_match.h"
#include "p_match_history.h"
#include "db.h"
#include "session.h"
#include <assert.h>
#include <mysql.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


static MYSQL* conn;

static MYSQL_STMT* login_procedure;
static MYSQL_STMT* logout_procedure;

/*                                 Moderator Statements                                */
static MYSQL_STMT* get_active_players_count_procedure;
static MYSQL_STMT* create_room_procedure;
static MYSQL_STMT* get_started_matches_and_players_procedure;
static MYSQL_STMT* get_recently_active_players_procedure;
static MYSQL_STMT* get_rooms_count_procedure;

/*                                  Player Statements                                  */
static MYSQL_STMT* get_joinable_rooms_procedure;
static MYSQL_STMT* get_player_history_procedure;
static MYSQL_STMT* join_room_procedure;
static MYSQL_STMT* exit_room_procedure;
static MYSQL_STMT* did_player_leave_procedure;
static MYSQL_STMT* get_match_details_procedure;
static MYSQL_STMT* get_match_players_procedure;
static MYSQL_STMT* get_latest_turn_procedure;
static MYSQL_STMT* does_turn_have_action_procedure;
static MYSQL_STMT* get_turn_action_procedure;
static MYSQL_STMT* get_action_details_procedure;
static MYSQL_STMT* did_player_win_or_lose_procedure;
static MYSQL_STMT* get_unplaced_tanks_procedure;
static MYSQL_STMT* get_personal_territories_procedure;
static MYSQL_STMT* get_scoreboard_procedure;
static MYSQL_STMT* get_actionable_territories_procedure;
static MYSQL_STMT* get_neighbour_territories_procedure;
static MYSQL_STMT* get_attackable_territories_procedure;
static MYSQL_STMT* action_placement_procedure;
static MYSQL_STMT* action_movement_procedure;
static MYSQL_STMT* action_combat_procedure;


static void close_prepared_stmts(void) {
  if (login_procedure) {
    mysql_stmt_close(login_procedure);
    login_procedure = NULL;
  }

  if (get_active_players_count_procedure) {
    mysql_stmt_close(get_active_players_count_procedure);
    get_active_players_count_procedure = NULL;
  }

  if (create_room_procedure) {
    mysql_stmt_close(create_room_procedure);
    create_room_procedure = NULL;
  }

  if (get_started_matches_and_players_procedure) {
    mysql_stmt_close(get_started_matches_and_players_procedure);
    get_started_matches_and_players_procedure = NULL;
  }

  if (get_recently_active_players_procedure) {
    mysql_stmt_close(get_recently_active_players_procedure);
    get_recently_active_players_procedure = NULL;
  }

  if (get_rooms_count_procedure) {
    mysql_stmt_close(get_rooms_count_procedure);
    get_rooms_count_procedure = NULL;
  }


  if (get_joinable_rooms_procedure) {
    mysql_stmt_close(get_joinable_rooms_procedure);
    get_joinable_rooms_procedure = NULL;
  }

  if (get_player_history_procedure) {
    mysql_stmt_close(get_player_history_procedure);
    get_player_history_procedure = NULL;
  }

  if (join_room_procedure) {
    mysql_stmt_close(join_room_procedure);
    join_room_procedure = NULL;
  }

  if (exit_room_procedure) {
    mysql_stmt_close(exit_room_procedure);
    exit_room_procedure = NULL;
  }

  if (did_player_leave_procedure) {
    mysql_stmt_close(did_player_leave_procedure);
    did_player_leave_procedure = NULL;
  }

  if (get_match_details_procedure) {
    mysql_stmt_close(get_match_details_procedure);
    get_match_details_procedure = NULL;
  }

  if (get_match_players_procedure) {
    mysql_stmt_close(get_match_players_procedure);
    get_match_players_procedure = NULL;
  }

  if (get_latest_turn_procedure) {
    mysql_stmt_close(get_latest_turn_procedure);
    get_latest_turn_procedure = NULL;
  }

  if (does_turn_have_action_procedure) {
    mysql_stmt_close(does_turn_have_action_procedure);
    does_turn_have_action_procedure = NULL;
  }

  if (get_turn_action_procedure) {
    mysql_stmt_close(get_turn_action_procedure);
    get_turn_action_procedure = NULL;
  }

  if (did_player_win_or_lose_procedure) {
    mysql_stmt_close(did_player_win_or_lose_procedure);
    did_player_win_or_lose_procedure = NULL;
  }

  if (get_unplaced_tanks_procedure) {
    mysql_stmt_close(get_unplaced_tanks_procedure);
    get_unplaced_tanks_procedure = NULL;
  }

  if (get_personal_territories_procedure) {
    mysql_stmt_close(get_personal_territories_procedure);
    get_personal_territories_procedure = NULL;
  }

  if (get_scoreboard_procedure) {
    mysql_stmt_close(get_scoreboard_procedure);
    get_scoreboard_procedure = NULL;
  }

  if (get_actionable_territories_procedure) {
    mysql_stmt_close(get_actionable_territories_procedure);
    get_actionable_territories_procedure = NULL;
  }

  if (get_neighbour_territories_procedure) {
    mysql_stmt_close(get_neighbour_territories_procedure);
    get_neighbour_territories_procedure = NULL;
  }

  if (get_attackable_territories_procedure) {
    mysql_stmt_close(get_attackable_territories_procedure);
    get_attackable_territories_procedure = NULL;
  }

  if (action_placement_procedure) {
    mysql_stmt_close(action_placement_procedure);
    action_placement_procedure = NULL;
  }

  if (action_movement_procedure) {
    mysql_stmt_close(action_movement_procedure);
    action_movement_procedure = NULL;
  }

  if (action_combat_procedure) {
    mysql_stmt_close(action_combat_procedure);
    action_combat_procedure = NULL;
  }

  if (get_action_details_procedure) {
    mysql_stmt_close(get_action_details_procedure);
    get_action_details_procedure = NULL;
  }
}

static bool initialize_prepared_stmts(role_t for_role) {
  switch (for_role) {
  case LOGIN_ROLE:
    if (!setup_prepared_stmt(&login_procedure, "call login(?, ?, ?, ?)",
      conn)) {
      print_stmt_error(login_procedure,
        "Unable to initialize login statement\n");
      return false;
    }

    if (!setup_prepared_stmt(&logout_procedure, "call logout(?)",
      conn)) {
      print_stmt_error(logout_procedure,
        "Unable to initialize login statement\n");
      return false;
    }
    break;
  case PLAYER:
    if (!setup_prepared_stmt(&logout_procedure, "call Logout(?)",
      conn)) {
      print_stmt_error(logout_procedure,
        "Unable to initialize logout statement\n");
      return false;
    }
    if (!setup_prepared_stmt(&get_joinable_rooms_procedure,
      "call GetJoinableRooms(?)", conn)) {
      print_stmt_error(get_joinable_rooms_procedure,
        "Unable to initialize get_joinable_rooms_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&get_player_history_procedure,
      "call GetPlayerHistory(?)", conn)) {
      print_stmt_error(get_player_history_procedure,
        "Unable to initialize get_player_history_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&join_room_procedure,
      "call JoinRoom(?,?,?)", conn)) {
      print_stmt_error(join_room_procedure,
        "Unable to initialize join_room_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&exit_room_procedure, "call ExitRoom(?,?)", conn)) {
      print_stmt_error(exit_room_procedure,
        "Unable to initialize exit_room_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&did_player_leave_procedure, "call DidPlayerLeave(?,?,?)", conn)) {
      print_stmt_error(did_player_leave_procedure,
        "Unable to initialize did_player_leave_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&get_match_details_procedure, "call GetMatchDetails(?)", conn)) {
      print_stmt_error(get_match_details_procedure,
        "Unable to initialize get_match_details_procedure\n");
      return false;
    }


    if (!setup_prepared_stmt(&get_match_players_procedure, "call GetMatchPlayers(?)", conn)) {
      print_stmt_error(get_match_players_procedure,
        "Unable to initialize get_match_players_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&get_latest_turn_procedure, "call GetLatestTurn(?)", conn)) {
      print_stmt_error(get_latest_turn_procedure,
        "Unable to initialize get_latest_turn_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&did_player_win_or_lose_procedure, "call GetPlayerCurrentStatus(?,?,?)", conn)) {
      print_stmt_error(did_player_win_or_lose_procedure,
        "Unable to initialize did_player_win_or_lose_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&get_unplaced_tanks_procedure, "call GetPlayerUnplacedTanks(?,?,?)", conn)) {
      print_stmt_error(get_unplaced_tanks_procedure,
        "Unable to initialize get_unplaced_tanks_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&does_turn_have_action_procedure, "call DoesTurnHaveAction(?,?,?)", conn)) {
      print_stmt_error(does_turn_have_action_procedure,
        "Unable to initialize does_turn_have_action_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&get_turn_action_procedure, "call GetTurnAction(?,?)", conn)) {
      print_stmt_error(get_turn_action_procedure,
        "Unable to initialize get_turn_action_procedure\n");
      return false;
    }

    if (!setup_prepared_stmt(&get_action_details_procedure, "call GetActionDetails(?,?,?,?)", conn)) {
      print_stmt_error(get_action_details_procedure,
        "Unable to initialize get_action_details_procedure\n");
      return false;
    }
    break;
  case MODERATOR:
    if (!setup_prepared_stmt(&logout_procedure, "call Logout(?)",
      conn)) {
      print_stmt_error(logout_procedure,
        "Unable to initialize logout statement\n");
      return false;
    }
    if (!setup_prepared_stmt(&get_active_players_count_procedure, "call GetActivePlayersCount(?)",
      conn)) {
      print_stmt_error(get_active_players_count_procedure,
        "Unable to initialize get_active_players_count_procedure statement\n");
      return false;
    }
    if (!setup_prepared_stmt(&create_room_procedure, "call CreateRoom(?,?,?)",
      conn)) {
      print_stmt_error(create_room_procedure,
        "Unable to initialize create_room_procedure statement\n");
      return false;
    }
    if (!setup_prepared_stmt(&get_started_matches_and_players_procedure, "call GetStartedMatchesAndPlayers(?,?)",
      conn)) {
      print_stmt_error(get_started_matches_and_players_procedure,
        "Unable to initialize get_started_matches_and_players_procedure statement\n");
      return false;
    }
    if (!setup_prepared_stmt(&get_recently_active_players_procedure, "call GetRecentlyActivePlayers(?)",
      conn)) {
      print_stmt_error(get_recently_active_players_procedure,
        "Unable to initialize get_recently_active_players_procedure statement\n");
      return false;
    }
    if (!setup_prepared_stmt(&get_rooms_count_procedure, "call GetRoomsCount(?)",
      conn)) {
      print_stmt_error(get_rooms_count_procedure,
        "Unable to initialize get_rooms_count_procedure statement\n");
      return false;
    }
    break;
  default:
    fprintf(stderr, "[FATAL] Unexpected role to prepare statements.\n");
    exit(EXIT_FAILURE);
  }

  return true;
}

bool init_db(void) {
  unsigned int timeout = 300;
  bool reconnect = true;

  conn = mysql_init(NULL);
  if (conn == NULL) {
    finish_with_error(conn, "mysql_init() failed (probably out of memory)\n");
  }

  if (mysql_real_connect(
    conn, getenv("HOST"), getenv("LOGIN_USER"), getenv("LOGIN_PASS"),
    getenv("DB"), atoi(getenv("PORT")), NULL,
    CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS | CLIENT_COMPRESS |
    CLIENT_INTERACTIVE | CLIENT_REMEMBER_OPTIONS) == NULL) {
    finish_with_error(conn, "mysql_real_connect() failed\n");
  }

  if (mysql_options(conn, MYSQL_OPT_CONNECT_TIMEOUT, &timeout)) {
    print_error(conn, "[mysql_options] failed.");
  }
  if (mysql_options(conn, MYSQL_OPT_RECONNECT, &reconnect)) {
    print_error(conn, "[mysql_options] failed.");
  }
#ifndef NDEBUG
  mysql_debug("d:t:O,/tmp/client.trace");
  if (mysql_dump_debug_info(conn)) {
    print_error(conn, "[debug_info] failed.");
  }
#endif

  return initialize_prepared_stmts(LOGIN_ROLE);
}

void fini_db(void) {
  close_prepared_stmts();

  mysql_close(conn);
}

void db_switch_to_login(void) {
  close_prepared_stmts();
  if (mysql_change_user(conn, getenv("LOGIN_USER"), getenv("LOGIN_PASS"),
    getenv("DB"))) {
    fprintf(stderr, "mysql_change_user() failed: %s\n", mysql_error(conn));
    exit(EXIT_FAILURE);
  }
  if (!initialize_prepared_stmts(LOGIN_ROLE)) {
    fprintf(stderr, "[FATAL] Cannot initialize prepared statements.\n");
    exit(EXIT_FAILURE);
  }
}

void db_switch_to_moderator(void) {
  close_prepared_stmts();
  if (mysql_change_user(conn, getenv("MODERATOR_USER"),
    getenv("MODERATOR_PASS"), getenv("DB"))) {
    fprintf(stderr, "mysql_change_user() failed: %s\n", mysql_error(conn));
    exit(EXIT_FAILURE);
  }
  if (!initialize_prepared_stmts(MODERATOR)) {
    fprintf(stderr, "[FATAL] Cannot initialize prepared statements.\n");
    exit(EXIT_FAILURE);
  }
}

void db_switch_to_player(void) {
  close_prepared_stmts();
  if (mysql_change_user(conn, getenv("PLAYER_USER"), getenv("PLAYER_PASS"),
    getenv("DB"))) {
    fprintf(stderr, "mysql_change_user() failed: %s\n", mysql_error(conn));
    exit(EXIT_FAILURE);
  }
  if (!initialize_prepared_stmts(PLAYER)) {
    fprintf(stderr, "[FATAL] Cannot initialize prepared statements.\n");
    exit(EXIT_FAILURE);
  }
}

role_t attempt_login(Credentials* cred) {
  MYSQL_BIND param[4]; // Used both for input and output
  int result;
  int role;

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, cred->username,
    strlen(cred->username));
  set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, cred->password,
    strlen(cred->password));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &result, sizeof(result));
  set_binding_param(&param[3], MYSQL_TYPE_LONG, &role, sizeof(role));

  if (mysql_stmt_bind_param(login_procedure, param) != 0) { // Note _param
    print_stmt_error(login_procedure, "Could not bind parameters for login");
    role = FAILED_LOGIN;
    goto out;
  }

  // Run procedure
  if (mysql_stmt_execute(login_procedure) != 0) {
    print_stmt_error(login_procedure, "Could not execute login procedure");
    role = FAILED_LOGIN;
    goto out;
  }

  // Prepare output parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &result, sizeof(result));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &role, sizeof(role));

  if (mysql_stmt_bind_result(login_procedure, param)) {
    print_stmt_error(login_procedure, "Could not retrieve output parameter");
    role = FAILED_LOGIN;
    goto out;
  }

  // Retrieve output parameter
  if (mysql_stmt_fetch(login_procedure)) {
    print_stmt_error(login_procedure, "Could not buffer results");
    role = FAILED_LOGIN;
    goto out;
  }

  // sprintf(current_user, "%s",cred->username);
  set_current_user(cred->username);

out:
  mysql_stmt_free_result(login_procedure);
  mysql_stmt_reset(login_procedure);
  return role;
}



void logout(void) {
  if (strlen(current_user) == 0) { //To avoid crash when exiting before Login
    return;
  }

  MYSQL_BIND param[1];

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, current_user,
    strlen(current_user));


  if (mysql_stmt_bind_param(logout_procedure, param) != 0) { // Note _param
    print_stmt_error(logout_procedure, "Could not bind parameters for logout");
    goto out;
  }

  // Run procedure
  if (mysql_stmt_execute(logout_procedure) != 0) {
    print_stmt_error(logout_procedure, "Could not execute logout procedure");
    goto out;
  }


  // Consume the possibly-returned table for the output parameter
  while (mysql_stmt_next_result(logout_procedure) != -1) {
  }


out:
  mysql_stmt_free_result(logout_procedure);
  mysql_stmt_reset(logout_procedure);
}

/*                                  Moderator Functions                                  */
int get_active_players_count(void) {
  int numberOfActivePlayers;
  MYSQL_BIND param[1];

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &numberOfActivePlayers, sizeof(numberOfActivePlayers));


  if (mysql_stmt_bind_param(get_active_players_count_procedure, param) != 0) { // Note _param
    print_stmt_error(get_active_players_count_procedure, "Could not bind parameters for get_active_players_count_procedure");
    goto out;
  }

  if (mysql_stmt_execute(get_active_players_count_procedure) != 0) {
    print_stmt_error(get_active_players_count_procedure, "Could not execute get_active_players_count procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &numberOfActivePlayers, sizeof(numberOfActivePlayers));
  if (mysql_stmt_bind_result(get_active_players_count_procedure, param)) {
    print_stmt_error(get_active_players_count_procedure, "Unable to bind output parameters get_active_players_count\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(get_active_players_count_procedure)) {
    print_stmt_error(get_active_players_count_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(get_active_players_count_procedure);
  mysql_stmt_reset(get_active_players_count_procedure);


  return numberOfActivePlayers;
}


int create_room(int turnDuration) {
  int roomNumber;
  MYSQL_BIND param[3];

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &turnDuration, sizeof(turnDuration));
  set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &roomNumber, sizeof(roomNumber));


  if (mysql_stmt_bind_param(create_room_procedure, param) != 0) { // Note _param
    print_stmt_error(create_room_procedure, "Could not bind parameters for create_room_procedure");
    goto out;
  }

  if (mysql_stmt_execute(create_room_procedure) != 0) {
    print_stmt_error(create_room_procedure, "Could not execute create_room_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &roomNumber, sizeof(roomNumber));
  if (mysql_stmt_bind_result(create_room_procedure, param)) {
    print_stmt_error(create_room_procedure, "Unable to bind output parameters get_active_players_count\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(create_room_procedure)) {
    print_stmt_error(create_room_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(create_room_procedure);
  mysql_stmt_reset(create_room_procedure);

  return roomNumber;
}


int get_recently_active_players_count(void) {
  MYSQL_BIND param[1]; // Used both for input and output
  int recentlyActiveCount;

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &recentlyActiveCount, sizeof(recentlyActiveCount));


  if (mysql_stmt_bind_param(get_recently_active_players_procedure, param) != 0) { // Note _param
    print_stmt_error(get_recently_active_players_procedure, "Could not bind parameters for get_recently_active_players_procedure");
    goto out;
  }

  if (mysql_stmt_execute(get_recently_active_players_procedure) != 0) {
    print_stmt_error(get_recently_active_players_procedure, "Could not execute get_recently_active_players_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &recentlyActiveCount, sizeof(recentlyActiveCount));
  if (mysql_stmt_bind_result(get_recently_active_players_procedure, param)) {
    print_stmt_error(get_recently_active_players_procedure, "Unable to bind output parameters get_recently_active_players_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(get_recently_active_players_procedure)) {
    print_stmt_error(get_recently_active_players_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(get_recently_active_players_procedure);
  mysql_stmt_reset(get_recently_active_players_procedure);


  return recentlyActiveCount;
}

ActiveMatchesStats* get_ingame_matches_and_players(void) {
  MYSQL_BIND param[2]; // Used both for input and output
  ActiveMatchesStats* matchesStats;

  matchesStats = malloc(sizeof(ActiveMatchesStats));

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &matchesStats->numberOfStartedMatches, sizeof(matchesStats->numberOfStartedMatches));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &matchesStats->numberOfIngamePlayers, sizeof(matchesStats->numberOfIngamePlayers));


  if (mysql_stmt_bind_param(get_started_matches_and_players_procedure, param) != 0) { // Note _param
    print_stmt_error(get_started_matches_and_players_procedure, "Could not bind parameters for get_started_matches_and_players_procedure");
    goto out;
  }

  if (mysql_stmt_execute(get_started_matches_and_players_procedure) != 0) {
    print_stmt_error(get_started_matches_and_players_procedure, "Could not execute get_started_matches_and_players_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &matchesStats->numberOfStartedMatches, sizeof(matchesStats->numberOfStartedMatches));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &matchesStats->numberOfIngamePlayers, sizeof(matchesStats->numberOfIngamePlayers));
  if (mysql_stmt_bind_result(get_started_matches_and_players_procedure, param)) {
    print_stmt_error(get_started_matches_and_players_procedure, "Unable to bind output parameters get_started_matches_and_players_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(get_started_matches_and_players_procedure)) {
    print_stmt_error(get_started_matches_and_players_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(get_started_matches_and_players_procedure);
  mysql_stmt_reset(get_started_matches_and_players_procedure);

  return matchesStats;
}



int get_rooms_count(void) {
  MYSQL_BIND param[1]; // Used both for input and output
  int roomsCount;

  // Prepare parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &roomsCount, sizeof(roomsCount));


  if (mysql_stmt_bind_param(get_rooms_count_procedure, param) != 0) { // Note _param
    print_stmt_error(get_rooms_count_procedure, "Could not bind parameters for get_rooms_count_procedure");
    goto out;
  }

  if (mysql_stmt_execute(get_rooms_count_procedure) != 0) {
    print_stmt_error(get_rooms_count_procedure, "Could not execute get_rooms_count_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &roomsCount, sizeof(roomsCount));
  if (mysql_stmt_bind_result(get_rooms_count_procedure, param)) {
    print_stmt_error(get_rooms_count_procedure, "Unable to bind output parameters get_rooms_count_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(get_rooms_count_procedure)) {
    print_stmt_error(get_rooms_count_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(get_rooms_count_procedure);
  mysql_stmt_reset(get_rooms_count_procedure);


  return roomsCount;
}


/*                                  Player Functions                                  */
Matches_List* get_joinable_rooms(int page_size) {
  MYSQL_BIND param[4];
  MYSQL_BIND in_param[1];
  int status;
  int matches_count = 0;
  int match_number = 0;
  int room_number = 0;
  int number_of_players = 0;
  int state = 0;
  size_t row = 0;
  Matches_List* matches;


  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &page_size, sizeof(page_size));


  if (mysql_stmt_bind_param(get_joinable_rooms_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_joinable_rooms_procedure, "Could not bind parameters for get joinable rooms!");
    goto out;
  }

  if (mysql_stmt_execute(get_joinable_rooms_procedure) != 0) {
    print_stmt_error(get_joinable_rooms_procedure, "Could not execute login procedure");
    goto out;
  }

  mysql_stmt_store_result(get_joinable_rooms_procedure);

  matches_count = mysql_stmt_num_rows(get_joinable_rooms_procedure);
  matches = malloc(sizeof(*matches) + sizeof(Match) * matches_count);

  if (matches == NULL) {
    goto out;
  }

  memset(matches, 0, sizeof(*matches) + sizeof(Match) * matches_count);
  matches->matches_count = matches_count;

  set_binding_param(&param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &room_number, sizeof(room_number));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &number_of_players, sizeof(number_of_players));
  set_binding_param(&param[3], MYSQL_TYPE_LONG, &state, sizeof(state));


  if (mysql_stmt_bind_result(get_joinable_rooms_procedure, param)) {
    print_stmt_error(get_joinable_rooms_procedure, "Unable to bind output parameters for get joinable rooms\n");
    free_safe(matches);
    goto out;
  }


  while (true) {
    status = mysql_stmt_fetch(get_joinable_rooms_procedure);
    if (status == 1 || status == MYSQL_NO_DATA)
      break;

    matches->matches[row].match_id = match_number;
    matches->matches[row].room_id = room_number;
    matches->matches[row].players_num = number_of_players;
    matches->matches[row].match_status = state;
    row++;
  }

out:
  mysql_stmt_free_result(get_joinable_rooms_procedure);
  mysql_stmt_reset(get_joinable_rooms_procedure);

  return matches;
}

Matches_Logs_List* get_player_history(void) {
  MYSQL_BIND param[5];
  MYSQL_BIND in_param[1];
  int status;
  int logs_count = 0;
  int match_number = 0;
  int room_number = 0;
  MYSQL_TIME match_start_time;
  MYSQL_TIME match_exit_time;
  int match_result = 0;
  size_t row = 0;
  Matches_Logs_List* matches;


  // Initialize timestamps
  init_mysql_timestamp(&match_start_time);
  init_mysql_timestamp(&match_exit_time);

  set_binding_param(&in_param[0], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));

  if (mysql_stmt_bind_param(get_player_history_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_player_history_procedure, "Could not bind parameters for get_player_history_procedure!");
    goto out;
  }

  if (mysql_stmt_execute(get_player_history_procedure) != 0) {
    print_stmt_error(get_player_history_procedure, "Could not execute get_player_history_procedure");
    goto out;
  }

  mysql_stmt_store_result(get_player_history_procedure);

  logs_count = mysql_stmt_num_rows(get_player_history_procedure);
  matches = malloc(sizeof(*matches) + sizeof(Match_Log) * logs_count);

  if (matches == NULL) {
    goto out;
  }

  memset(matches, 0, sizeof(*matches) + sizeof(Match_Log) * logs_count);
  matches->logs_count = logs_count;

  set_binding_param(&param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &room_number, sizeof(room_number));
  set_binding_param(&param[2], MYSQL_TYPE_TIMESTAMP, &match_start_time, sizeof(match_start_time));
  set_binding_param(&param[3], MYSQL_TYPE_TIMESTAMP, &match_exit_time, sizeof(match_exit_time));
  set_binding_param(&param[4], MYSQL_TYPE_LONG, &match_result, sizeof(match_result));


  if (mysql_stmt_bind_result(get_player_history_procedure, param)) {
    print_stmt_error(get_player_history_procedure, "Unable to bind output parameters for get_player_history_procedure\n");
    free_safe(matches);
    goto out;
  }


  while (true) {
    status = mysql_stmt_fetch(get_player_history_procedure);
    if (status == 1 || status == MYSQL_NO_DATA)
      break;
    matches->logs[row].match_id = match_number;
    matches->logs[row].room_id = room_number;
    mysql_timestamp_to_string(&match_start_time, matches->logs[row].start_time);
    mysql_timestamp_to_string(&match_exit_time, matches->logs[row].end_time);
    matches->logs[row].result = match_result;
    row++;
  }

out:
  mysql_stmt_free_result(get_player_history_procedure);
  mysql_stmt_reset(get_player_history_procedure);
  return matches;
}

bool join_room(int roomNumber) {
  MYSQL_BIND param[3];
  int joinedRoom = 0;
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &roomNumber, sizeof(roomNumber));
  set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &joinedRoom, sizeof(joinedRoom));

  if (mysql_stmt_bind_param(join_room_procedure, param) != 0) { // Note _param
    print_stmt_error(join_room_procedure, "Could not bind parameters for create_room_procedure");
    goto out;
  }

  if (mysql_stmt_execute(join_room_procedure) != 0) {
    print_stmt_error(join_room_procedure, "Could not execute join_room_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &joinedRoom, sizeof(joinedRoom));
  if (mysql_stmt_bind_result(join_room_procedure, param)) {
    print_stmt_error(join_room_procedure, "Unable to bind output parameters join_room_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(join_room_procedure)) {
    print_stmt_error(join_room_procedure, "Could not buffer results");
    goto out;
  }


  while (mysql_stmt_next_result(join_room_procedure) != -1) {}

out:
  mysql_stmt_free_result(join_room_procedure);
  mysql_stmt_reset(join_room_procedure);


  if (joinedRoom == 0) {
    return false;
  }

  return true;
}



void exit_room(int roomNumber) {
  MYSQL_BIND param[2];
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &roomNumber, sizeof(roomNumber));
  set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));

  if (mysql_stmt_bind_param(exit_room_procedure, param) != 0) { // Note _param
    print_stmt_error(exit_room_procedure, "Could not bind parameters for exit_room_procedure");
    goto out;
  }


  if (mysql_stmt_execute(exit_room_procedure) != 0) {
    print_stmt_error(exit_room_procedure, "Could not execute exit_room_procedure procedure");
    goto out;
  }

out:
  mysql_stmt_free_result(exit_room_procedure);
  mysql_stmt_reset(exit_room_procedure);

}


bool did_player_leave(void) {
  int leftRoom = 0;
  int matchNumber = current_match->match_id;
  MYSQL_BIND param[3];
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &matchNumber, sizeof(matchNumber));
  set_binding_param(&param[1], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &leftRoom, sizeof(leftRoom));

  if (mysql_stmt_bind_param(did_player_leave_procedure, param) != 0) { // Note _param
    print_stmt_error(did_player_leave_procedure, "Could not bind parameters for did_player_leave_procedure");
    goto out;
  }

  if (mysql_stmt_execute(did_player_leave_procedure) != 0) {
    print_stmt_error(did_player_leave_procedure, "Could not execute did_player_leave_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &leftRoom, sizeof(leftRoom));
  if (mysql_stmt_bind_result(did_player_leave_procedure, param)) {
    print_stmt_error(did_player_leave_procedure, "Unable to bind output parameters did_player_leave_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(did_player_leave_procedure)) {
    print_stmt_error(did_player_leave_procedure, "Could not buffer results");
    goto out;
  }


out:
  mysql_stmt_free_result(did_player_leave_procedure);
  mysql_stmt_reset(did_player_leave_procedure);

  return leftRoom;
}

void update_match_details(void) {
  MYSQL_BIND param[5];
  MYSQL_BIND in_param[1];
  int status;
  int match_number = 0;
  int room_number = 0;
  int number_of_players = 0;
  int state = 0;
  MYSQL_TIME match_start_countdown;
  int current_match_number = current_match->match_id;

  // Initialize timestamps
  init_mysql_timestamp(&match_start_countdown);

  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &current_match_number, sizeof(current_match_number));

  if (mysql_stmt_bind_param(get_match_details_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_match_details_procedure, "Could not bind parameters for get_match_details_procedure!");
    goto out;
  }

  if (mysql_stmt_execute(get_match_details_procedure) != 0) {
    print_stmt_error(get_match_details_procedure, "Could not execute get_match_details_procedure");
    goto out;
  }

  mysql_stmt_store_result(get_match_details_procedure);

  set_binding_param(&param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &room_number, sizeof(room_number));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &number_of_players, sizeof(number_of_players));
  set_binding_param(&param[3], MYSQL_TYPE_TIMESTAMP, &match_start_countdown, sizeof(match_start_countdown));
  set_binding_param(&param[4], MYSQL_TYPE_LONG, &state, sizeof(state));


  if (mysql_stmt_bind_result(get_match_details_procedure, param)) {
    print_stmt_error(get_match_details_procedure, "Unable to bind output parameters for get_match_details_procedure\n");
    goto out;
  }

  if (current_match == NULL) {
    goto out;
  }

  while (true) {
    status = mysql_stmt_fetch(get_match_details_procedure);
    if (status == 1 || status == MYSQL_NO_DATA)
      break;
    current_match->match_id = match_number;
    current_match->room_id = room_number;
    current_match->players_num = number_of_players;
    mysql_timestamp_to_string(&match_start_countdown, current_match->match_start_countdown);
    current_match->match_status = state;
  }

out:
  mysql_stmt_free_result(get_match_details_procedure);
  mysql_stmt_reset(get_match_details_procedure);
}

PlayersList* get_match_players(void) {
  MYSQL_BIND param[1];
  MYSQL_BIND in_param[1];
  int status;
  int row = 0;
  int players_count = 0;
  PlayersList* players_list;
  char player[USERNAME_SIZE];
  int current_match_number = current_match->match_id;

  if (current_match == NULL) {
    return NULL;
  }

  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &current_match_number, sizeof(current_match_number));

  if (mysql_stmt_bind_param(get_match_players_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_match_players_procedure, "Could not bind parameters for get_match_players_procedure!");
    goto out;
  }

  if (mysql_stmt_execute(get_match_players_procedure) != 0) {
    print_stmt_error(get_match_players_procedure, "Could not execute get_match_players_procedure");
    goto out;
  }

  mysql_stmt_store_result(get_match_players_procedure);

  players_count = mysql_stmt_num_rows(get_match_players_procedure);
  players_list = malloc(sizeof(PlayersList));
  players_list->players_count = players_count;

  set_binding_param(&param[0], MYSQL_TYPE_VAR_STRING, &player, USERNAME_SIZE);


  if (mysql_stmt_bind_result(get_match_players_procedure, param)) {
    print_stmt_error(get_match_players_procedure, "Unable to bind output parameters for get_match_players_procedure\n");
    goto out;
  }

  while (true) {
    status = mysql_stmt_fetch(get_match_players_procedure);
    if (status == 1 || status == MYSQL_NO_DATA)
      break;
    strcpy(players_list->players[row], player);
    row++;
  }

out:
  mysql_stmt_free_result(get_match_players_procedure);
  mysql_stmt_reset(get_match_players_procedure);

  return players_list;
}

Turn* get_latest_turn(void) {
  MYSQL_BIND param[4];
  MYSQL_BIND in_param[1];
  int status;
  int match_number;
  int turn_number;
  char player[USERNAME_SIZE];
  MYSQL_TIME turn_start_time;
  Turn* turn;
  int current_match_number = current_match->match_id;

  if (current_match == NULL) {
    return NULL;
  }

  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &current_match_number, sizeof(current_match_number));

  if (mysql_stmt_bind_param(get_latest_turn_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_latest_turn_procedure, "Could not bind parameters for get_latest_turn_procedure!");
    goto out;
  }

  if (mysql_stmt_execute(get_latest_turn_procedure) != 0) {
    print_stmt_error(get_latest_turn_procedure, "Could not execute get_latest_turn_procedure");
    goto out;
  }

  mysql_stmt_store_result(get_latest_turn_procedure);

  turn = malloc(sizeof(Turn));

  set_binding_param(&param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &turn_number, sizeof(turn_number));
  set_binding_param(&param[2], MYSQL_TYPE_VAR_STRING, &player, USERNAME_SIZE);
  set_binding_param(&param[3], MYSQL_TYPE_TIMESTAMP, &turn_start_time, TIMESTAMP_SIZE);

  if (mysql_stmt_bind_result(get_latest_turn_procedure, param)) {
    print_stmt_error(get_latest_turn_procedure, "Unable to bind output parameters for get_latest_turn_procedure\n");
    goto out;
  }

  while (true) {
    status = mysql_stmt_fetch(get_latest_turn_procedure);
    if (status == 1 || status == MYSQL_NO_DATA)
      break;
    turn->match_id = match_number;
    turn->turn_id = turn_number;
    strcpy(turn->player, player);
    mysql_timestamp_to_string(&turn_start_time, turn->turn_start_time);
  }

out:
  mysql_stmt_free_result(get_latest_turn_procedure);
  mysql_stmt_reset(get_latest_turn_procedure);

  return turn;
}

bool does_turn_have_action(Turn* turn) {
  MYSQL_BIND in_param[3];
  MYSQL_BIND param[1];
  int result = -1;

  if (current_match == NULL || current_user == NULL) {
    return -1;
  }

  // Prepare parameters
  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &turn->match_id, sizeof(turn->match_id));
  set_binding_param(&in_param[1], MYSQL_TYPE_LONG, &turn->turn_id, sizeof(turn->turn_id));
  set_binding_param(&in_param[2], MYSQL_TYPE_LONG, &result, sizeof(result));


  if (mysql_stmt_bind_param(does_turn_have_action_procedure, in_param) != 0) { // Note _param
    print_stmt_error(does_turn_have_action_procedure, "Could not bind parameters for does_turn_have_action_procedure");
    goto out;
  }

  if (mysql_stmt_execute(does_turn_have_action_procedure) != 0) {
    print_stmt_error(does_turn_have_action_procedure, "Could not execute does_turn_have_action_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &result, sizeof(result));
  if (mysql_stmt_bind_result(does_turn_have_action_procedure, param)) {
    print_stmt_error(does_turn_have_action_procedure, "Unable to bind output parameters does_turn_have_action_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(does_turn_have_action_procedure)) {
    print_stmt_error(does_turn_have_action_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(does_turn_have_action_procedure);
  mysql_stmt_reset(does_turn_have_action_procedure);

  if (result <= 0) {
    return false;
  }

  return true;
}

player_status_t did_player_win_or_lose(void) {
  MYSQL_BIND in_param[3];
  MYSQL_BIND param[1];
  int result = -1;

  if (current_match == NULL || current_user == NULL) {
    return -1;
  }

  // Prepare parameters
  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &current_match->match_id, sizeof(current_match->match_id));
  set_binding_param(&in_param[1], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));
  set_binding_param(&in_param[2], MYSQL_TYPE_LONG, &result, sizeof(result));


  if (mysql_stmt_bind_param(did_player_win_or_lose_procedure, in_param) != 0) { // Note _param
    print_stmt_error(did_player_win_or_lose_procedure, "Could not bind parameters for did_player_win_or_lose_procedure");
    goto out;
  }

  if (mysql_stmt_execute(did_player_win_or_lose_procedure) != 0) {
    print_stmt_error(did_player_win_or_lose_procedure, "Could not execute did_player_win_or_lose_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &result, sizeof(result));
  if (mysql_stmt_bind_result(did_player_win_or_lose_procedure, param)) {
    print_stmt_error(did_player_win_or_lose_procedure, "Unable to bind output parameters did_player_win_or_lose_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(did_player_win_or_lose_procedure)) {
    print_stmt_error(did_player_win_or_lose_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(did_player_win_or_lose_procedure);
  mysql_stmt_reset(did_player_win_or_lose_procedure);

  return result;
}

int get_player_unplaced_tanks(void) {
  MYSQL_BIND in_param[3];
  MYSQL_BIND param[1];
  int unplacedTanks = -1;

  if (current_match == NULL || current_user == NULL) {
    return -1;
  }

  // Prepare parameters
  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &current_match->match_id, sizeof(current_match->match_id));
  set_binding_param(&in_param[1], MYSQL_TYPE_VAR_STRING, current_user, strlen(current_user));
  set_binding_param(&in_param[2], MYSQL_TYPE_LONG, &unplacedTanks, sizeof(unplacedTanks));


  if (mysql_stmt_bind_param(get_unplaced_tanks_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_unplaced_tanks_procedure, "Could not bind parameters for get_unplaced_tanks_procedure");
    goto out;
  }

  if (mysql_stmt_execute(get_unplaced_tanks_procedure) != 0) {
    print_stmt_error(get_unplaced_tanks_procedure, "Could not execute get_unplaced_tanks_procedure procedure");
    goto out;
  }

  // Output Parameters
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &unplacedTanks, sizeof(unplacedTanks));
  if (mysql_stmt_bind_result(get_unplaced_tanks_procedure, param)) {
    print_stmt_error(get_unplaced_tanks_procedure, "Unable to bind output parameters get_unplaced_tanks_procedure\n");
    goto out;
  }


  // Retrieve output parameter
  if (mysql_stmt_fetch(get_unplaced_tanks_procedure)) {
    print_stmt_error(get_unplaced_tanks_procedure, "Could not buffer results");
    goto out;
  }

out:
  mysql_stmt_free_result(get_unplaced_tanks_procedure);
  mysql_stmt_reset(get_unplaced_tanks_procedure);

  return unplacedTanks;
}

Action* get_turn_action(Turn* turn) {
  MYSQL_BIND param[7];
  MYSQL_BIND in_param[2];
  int status;
  int match_number;
  int turn_number;
  int action_number;
  char player[USERNAME_SIZE];
  char nation[NATION_NAME_SIZE];
  int tanks_number;
  int action_type;
  Action* action;

  if (current_match == NULL) {
    return NULL;
  }

  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &turn->match_id, sizeof(turn->match_id));
  set_binding_param(&in_param[1], MYSQL_TYPE_LONG, &turn->turn_id, sizeof(turn->turn_id));

  if (mysql_stmt_bind_param(get_turn_action_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_turn_action_procedure, "Could not bind parameters for get_turn_action_procedure!");
    goto out;
  }

  if (mysql_stmt_execute(get_turn_action_procedure) != 0) {
    print_stmt_error(get_turn_action_procedure, "Could not execute get_turn_action_procedure");
    goto out;
  }

  mysql_stmt_store_result(get_turn_action_procedure);

  action = malloc(sizeof(Action));
  action->details = malloc(sizeof(ActionDetails));
  set_binding_param(&param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
  set_binding_param(&param[1], MYSQL_TYPE_LONG, &turn_number, sizeof(turn_number));
  set_binding_param(&param[2], MYSQL_TYPE_LONG, &action_number, sizeof(action_number));
  set_binding_param(&param[3], MYSQL_TYPE_VAR_STRING, &player, USERNAME_SIZE);
  set_binding_param(&param[4], MYSQL_TYPE_VAR_STRING, &nation, NATION_NAME_SIZE);
  set_binding_param(&param[5], MYSQL_TYPE_LONG, &tanks_number, sizeof(tanks_number));
  set_binding_param(&param[6], MYSQL_TYPE_LONG, &action_type, sizeof(action_type));


  if (mysql_stmt_bind_result(get_turn_action_procedure, param)) {
    print_stmt_error(get_turn_action_procedure, "Unable to bind output parameters for get_turn_action_procedure\n");
    goto out;
  }

  printffn("Breakpoint 1");
  while (true) {
    status = mysql_stmt_fetch(get_turn_action_procedure);
    printffn("Breakpoint 2");
    if (status == 1 || status == MYSQL_NO_DATA)
      break;

    action->match_id = match_number;
    action->turn_id = turn_number;
    action->action_id = action_number;
    strcpy(action->player, player);
    strcpy(action->target_nation, nation);
    action->tanks_number = tanks_number;
    action->details->action_type = action_type;
  }

out:
  mysql_stmt_free_result(get_turn_action_procedure);
  mysql_stmt_reset(get_turn_action_procedure);

  return action;
}

void get_action_details(Action* action) {
  MYSQL_BIND in_param[4];
  int status;
  int match_number;
  int turn_number;
  int action_number;
  char player[USERNAME_SIZE];
  char source_nation[NATION_NAME_SIZE];
  char target_nation[NATION_NAME_SIZE];
  int tanks_number;

  // As Placement doesn't require any extra details
  if (action == NULL || action->details->action_type == PLACEMENT) {
    return;
  }

  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &action->match_id, sizeof(action->match_id));
  set_binding_param(&in_param[1], MYSQL_TYPE_LONG, &action->turn_id, sizeof(action->turn_id));
  set_binding_param(&in_param[2], MYSQL_TYPE_LONG, &action->action_id, sizeof(action->action_id));
  set_binding_param(&in_param[3], MYSQL_TYPE_LONG, &action->details->action_type, sizeof(action->details->action_type));


  if (mysql_stmt_bind_param(get_action_details_procedure, in_param) != 0) { // Note _param
    print_stmt_error(get_action_details_procedure, "Could not bind parameters for get_action_details_procedure!");
    goto out;
  }

  if (mysql_stmt_execute(get_action_details_procedure) != 0) {
    print_stmt_error(get_action_details_procedure, "Could not execute get_action_details_procedure");
    goto out;
  }

  mysql_stmt_store_result(get_action_details_procedure);

  switch (action->details->action_type) {
    case MOVEMENT:{
      MYSQL_BIND movement_param[7];
      Movement* movement = malloc(sizeof(Movement));
      set_binding_param(&movement_param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
      set_binding_param(&movement_param[1], MYSQL_TYPE_LONG, &turn_number, sizeof(turn_number));
      set_binding_param(&movement_param[2], MYSQL_TYPE_LONG, &action_number, sizeof(action_number));
      set_binding_param(&movement_param[3], MYSQL_TYPE_VAR_STRING, &player, USERNAME_SIZE);
      set_binding_param(&movement_param[4], MYSQL_TYPE_VAR_STRING, &source_nation, NATION_NAME_SIZE);
      set_binding_param(&movement_param[5], MYSQL_TYPE_VAR_STRING, &target_nation, NATION_NAME_SIZE);
      set_binding_param(&movement_param[6], MYSQL_TYPE_LONG, &tanks_number, sizeof(tanks_number));

      if (mysql_stmt_bind_result(get_action_details_procedure, movement_param)) {
        print_stmt_error(get_action_details_procedure, "Unable to bind output parameters for get_action_details_procedure\n");
        goto out;
      }

      printffn("Breakpoint 1");
      while (true) {
        status = mysql_stmt_fetch(get_action_details_procedure);
        printffn("Breakpoint 2");
        if (status == 1 || status == MYSQL_NO_DATA)
          break;

        action->match_id = match_number;
        action->turn_id = turn_number;
        action->action_id = action_number;
        strcpy(action->player, "player");
        strcpy(movement->source_nation, source_nation);
        strcpy(action->target_nation, target_nation);
        action->tanks_number = tanks_number;
        action->details->content = (void*) movement;
      }
    }

    printffn("Source Nation: %s", source_nation);
    printffn("Target Nation: %s", target_nation);
    break;
    case COMBAT:{
      MYSQL_BIND combat_param[12];
      int attacker_lost_tanks;
      char defender_player[USERNAME_SIZE];
      int defender_tanks_number;
      int defender_lost_tanks;
      int nation_occupied;
      Combat* combat = malloc(sizeof(Combat));
      set_binding_param(&combat_param[0], MYSQL_TYPE_LONG, &match_number, sizeof(match_number));
      set_binding_param(&combat_param[1], MYSQL_TYPE_LONG, &turn_number, sizeof(turn_number));
      set_binding_param(&combat_param[2], MYSQL_TYPE_LONG, &action_number, sizeof(action_number));
      set_binding_param(&combat_param[3], MYSQL_TYPE_VAR_STRING, &player, USERNAME_SIZE);
      set_binding_param(&combat_param[4], MYSQL_TYPE_VAR_STRING, &source_nation, NATION_NAME_SIZE);
      set_binding_param(&combat_param[5], MYSQL_TYPE_LONG, &tanks_number, sizeof(tanks_number));
      set_binding_param(&combat_param[6], MYSQL_TYPE_LONG, &attacker_lost_tanks, sizeof(attacker_lost_tanks));
      set_binding_param(&combat_param[7], MYSQL_TYPE_VAR_STRING, &defender_player, USERNAME_SIZE);
      set_binding_param(&combat_param[8], MYSQL_TYPE_VAR_STRING, &target_nation, NATION_NAME_SIZE);
      set_binding_param(&combat_param[9], MYSQL_TYPE_LONG, &defender_tanks_number, sizeof(defender_tanks_number));
      set_binding_param(&combat_param[10], MYSQL_TYPE_LONG, &defender_lost_tanks, sizeof(defender_lost_tanks));
      set_binding_param(&combat_param[11], MYSQL_TYPE_LONG, &nation_occupied, sizeof(nation_occupied));


      if (mysql_stmt_bind_result(get_action_details_procedure, combat_param)) {
        print_stmt_error(get_action_details_procedure, "Unable to bind output parameters for get_action_details_procedure\n");
        goto out;
      }

      printffn("Breakpoint 1");
      while (true) {
        status = mysql_stmt_fetch(get_action_details_procedure);
        printffn("Breakpoint 2");
        if (status == 1 || status == MYSQL_NO_DATA)
          break;

        action->match_id = match_number;
        action->turn_id = turn_number;
        action->action_id = action_number;
        
        strcpy(action->player, player);
        strcpy(combat->attacker_nation, source_nation);
        action->tanks_number = tanks_number;
        combat->attacker_lost_tanks = attacker_lost_tanks;
        
        strcpy(combat->defender_player, defender_player);
        strcpy(action->target_nation, target_nation);
        combat->defender_tanks_number = defender_tanks_number;
        combat->defender_lost_tanks = defender_lost_tanks;
        if(nation_occupied == 1){
            combat->succeded = true;
        }else{
          combat->succeded = false;
        }
        action->details->content = (void*) combat;
      }
    }
    break;
  }


out:
  mysql_stmt_free_result(get_action_details_procedure);
  mysql_stmt_reset(get_action_details_procedure);

}

//For Placement (Ally Territories)
Territories* get_personal_territories(void) {}

Territories* get_scoreboard(void) {}

//Nations with tanks number > 1 (Ally Territories)
Territories* get_actionable_territories(void) {}

//For Movement (Ally Territories)
Territories* get_neighbour_territories(void) {}

//For Combat (Enemy Territories)
Territories* get_attackable_territories(void) {}

void action_placement(char nation[NATION_NAME_SIZE], int tanks_number) {}

void action_movement(void) {}

void action_combat(void) {}


