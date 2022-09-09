#include "../utils/db.h"
#include "../utils/io.h"
#include "../utils/mem.h"
#include "p_match.h"
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
/*                                  Player Statements                                  */
static MYSQL_STMT* get_joinable_rooms_procedure;

/*                                 Moderator Statements                                */
static MYSQL_STMT* get_active_players_count_procedure;
static MYSQL_STMT* create_room_procedure;
static MYSQL_STMT* get_started_matches_and_players_procedure;
static MYSQL_STMT* get_recently_active_players_procedure;
static MYSQL_STMT* get_rooms_count_procedure;



static void close_prepared_stmts(void) {
  if (login_procedure) {
    mysql_stmt_close(login_procedure);
    login_procedure = NULL;
  }

  if (get_joinable_rooms_procedure) {
    mysql_stmt_close(get_joinable_rooms_procedure);
    get_joinable_rooms_procedure = NULL;
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
        "Unable to initialize get joinable rooms procedure\n");
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
    print_stmt_error(logout_procedure, "Could not execute login procedure");
    goto out;
  }


  // Consume the possibly-returned table for the output parameter
  while (mysql_stmt_next_result(logout_procedure) != -1) {
  }


out:
  mysql_stmt_free_result(logout_procedure);
  mysql_stmt_reset(logout_procedure);
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


  set_binding_param(&in_param[0], MYSQL_TYPE_LONG, &page_size,
    sizeof(page_size));


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
    free(matches);
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