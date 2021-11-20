#include <stdio.h>
#include <stdlib.h>
#include "clients/initiator.h"

#define CLIENT_TYPE_MODERATOR

AppConfig mod_app_config = {
    .serverHostUrl = "", .serverUsername = "", .serverPasssword = "", .serverPort = 883};

int main(int argc, char **argv)
{
    return initApp(mod_app_config);
}
