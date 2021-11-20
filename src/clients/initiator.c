#include "initiator.h"
#include "player/p_client.h"
#include "moderator/m_client.h"
#include <curses.h>

int initApp(AppConfig config)
{
    initscr();
    printw("Hello World!");
    refresh();
    getch();
    endwin();
    return 0;
}