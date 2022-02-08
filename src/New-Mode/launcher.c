#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include "utils/dotenv.h"
// #include "utils/io.h"
// #include "utils/validation.h"

// #define check_env_failing(varname)                                       \
//     if (getenv((varname)) == NULL)                                       \
//     {                                                                    \
//         fprintf(stderr, "[FATAL] env variable %s not set\n", (varname)); \
//         ret = false;                                                     \
//     }
// static bool validate_dotenv(void)
// {
//     bool ret = true;

//     check_env_failing("HOST");
//     check_env_failing("DB");
//     check_env_failing("GUEST_USER");
//     check_env_failing("GUEST_PASS");
//     check_env_failing("MODERATOR_USER");
//     check_env_failing("MODERATOR_PASS");
//     check_env_failing("PLAYER_USER");
//     check_env_failing("PLAYER_PASS");

//     return ret;
// }
// #undef set_env_failing

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
    } else if (argc = 2 && strcmp(argv[1], MOD_FLAG) == 0)
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