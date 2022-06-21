#pragma once
#include <setjmp.h>
#include <stdarg.h>
#include <stdbool.h>
#include <time.h>

extern jmp_buf leave_buff;
extern bool io_initialized;

#define initialize_io()                                                        \
  __extension__({                                                              \
    io_initialized = true;                                                     \
    int __ret = setjmp(leave_buff);                                            \
    __ret == 0;                                                                \
  })

extern char *get_input(char *question, int len, char *buff, bool hide,
                       bool prefix);
extern bool yes_or_no(char *question, char yes, char no, bool default_answer,
                      bool insensitive);
extern char multi_choice(char *question, const char choices[], int num);
extern void clear_screen(void);
extern void press_anykey(void);
extern void init_choices_array(char **choices_array, int choices_num);
extern void printff(const char *format, ...);
extern void printffn(const char *format, ...);

extern time_t last_exit_attempt_time;
extern int *can_exit_flag;

extern void exit_interrupt_handler(int sigNo);
extern void setup_exit_interrupt_handler();
