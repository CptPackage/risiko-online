#include "p_match.h"
#include <stdlib.h>

extern char *match_status_strings[MATCH_STATUS_NUM];

char *get_match_status_string(match_status_t match_status) {
  if (*match_status_strings == NULL) {
    match_status_strings[0] = "LOBBY";
    match_status_strings[1] = "COUNTDOWN";
    match_status_strings[2] = "STARTED";
    match_status_strings[3] = "ENDED";
  }

  return match_status_strings[match_status];
}
