#ifndef INITIATOR_H
#define INITIATOR_H

#include "player/p_client.h"
#include "moderator/m_client.h"
#include <curses.h>

typedef struct _appConfig
{
    char *serverHostUrl;
    char *serverUsername;
    char *serverPasssword;
    int serverPort;
} AppConfig;

int initApp(AppConfig config);
#endif