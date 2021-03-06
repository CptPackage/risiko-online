#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.c"

#define PLAYER_MODE "P-MODE"
#define MODERATOR_MODE "M-MODE"
#define MOD_FLAG "--moderator"

void initApp(char* gameMode);

int main(int argc, char** argv)
{
    // if (env_load(".", false) != 0)
    //     return 1;
    // if (!validate_dotenv())
    //     return 1;
    // if (!init_validation())
    //     return 1;
    // if (!init_db())
    //     return 1;

    // if (initialize_io()) {
    if (argc < 2)
    {
        initApp(PLAYER_MODE);
    } else if (argc == 2 && strcmp(argv[1], MOD_FLAG) == 0)
    {
        initApp(MODERATOR_MODE);
    } else
    {
        return -1;
    }
    // }

    // fini_db();
    // fini_validation();

    return 0;
}

void initApp(char* gameMode)
{
    if (strcmp(gameMode, MODERATOR_MODE) == 0) {
        view_m_login(); //Attempt login, if successful then switch user to Moderator Mode
    } else {
        view_p_login(); //Attempt login, if successful then switch user to Player Mode
    }
}