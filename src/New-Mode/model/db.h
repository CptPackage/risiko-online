#pragma once
#include <stdbool.h>
#include <stdlib.h>

extern bool init_db(void);
extern void fini_db(void);

#define USERNAME_LEN 45
#define PASSWORD_LEN 45

typedef struct _credentials {
  char username[USERNAME_LEN];
  char password[PASSWORD_LEN];
} Credentials;

typedef enum { LOGIN_ROLE, AMMINISTRATORE, AGENZIA, FAILED_LOGIN } role_t;

extern void db_switch_to_login(void);
extern role_t attempt_login(Credentials *cred);
extern void db_switch_to_administrator(void);

#define DATE_LEN 11
#define TIME_LEN 6
#define DATETIME_LEN (DATE_LEN + TIME_LEN)
#define ID_LEN 45
#define CITTA_LEN 45
#define TIPO_LEN 45
struct flight {
  char idVolo[ID_LEN];
  char giorno[DATE_LEN];
  char cittaPart[CITTA_LEN];
  char oraPart[TIME_LEN];
  char cittaArr[CITTA_LEN];
  char oraArr[TIME_LEN];
  char tipoAereo[TIPO_LEN];
};

extern void do_register_flight(struct flight *flight);

struct occupancy_entry {
  char idVolo[ID_LEN];
  char cittaPart[CITTA_LEN];
  char partenza[DATETIME_LEN];
  char cittaArr[CITTA_LEN];
  char arrivo[DATETIME_LEN];
  unsigned prenotati;
  unsigned disponibili;
  double occupazione;
};
struct occupancy {
  unsigned num_entries;
  struct occupancy_entry occupancy[];
};

extern struct occupancy *do_get_occupancy(void);
extern void occupancy_dispose(struct occupancy *occupancy);

extern void db_switch_to_agency(void);

#define NAME_SURNAME_LEN 45
struct booking {
  char idVolo[ID_LEN];
  char giorno[DATE_LEN];
  char name[NAME_SURNAME_LEN];
  char surname[NAME_SURNAME_LEN];
};

extern int do_booking(struct booking *info);

struct booking_info {
  char name[NAME_SURNAME_LEN];
  char surname[NAME_SURNAME_LEN];
};

struct flight_info {
  char idVolo[ID_LEN];
  char cittaPart[CITTA_LEN];
  char cittaArr[CITTA_LEN];
  char giorno[DATE_LEN];
  size_t num_bookings;
  struct booking_info *bookings;
};

struct booking_report {
  size_t num_flights;
  struct flight_info flights[];
};

extern struct booking_report *do_booking_report(void);
extern void booking_report_dispose(struct booking_report *report);
