#include <stdio.h>
#include "clients/initiator.h"

#define CLIENT_TYPE_PLAYER

AppConfig player_app_config = {
    .serverHostUrl = "", .serverUsername = "", .serverPasssword = "", .serverPort = 883};

int main(int argc, char **argv)
{
    return initApp(player_app_config);
}
