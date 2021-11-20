#include <stdio.h>
#include "clients/initiator.h"

#define CLIENT_TYPE_PLAYER

AppConfig player_app_config = {
    "", "", "", 883};

int main(int argc, char **argv)
{
    initApp(player_app_config);
    return 0;
}
