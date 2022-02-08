#include "initiator.h"

int initApp(AppConfig config)
{
    initscr();
    printw("Hello World!");
    refresh();
    getch();
    endwin();
    return 0;
}