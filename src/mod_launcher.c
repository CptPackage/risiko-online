#include <stdio.h>
#include <stdlib.h>
#include "clients/initiator.h"

#define CLIENT_TYPE_MODERATOR

AppConfig mod_app_config = {
    "", "", "", 883};

int main(int argc, char **argv)
{
    initApp(mod_app_config);
    return 0;
}
