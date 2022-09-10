#include "view.h"
#include <ctype.h>
#include <setjmp.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include "../model/db.h"
#include "./view.h"
#include "./mem.h"
#include <errno.h>

#ifdef __unix__
#include <termios.h>
#endif

#include "io.h"

jmp_buf leave_buff;
bool io_initialized;

static void leave(void) {
  if (io_initialized)
    longjmp(leave_buff, 1);
  else
    exit(EXIT_SUCCESS);
}

char *get_input(char *question, int len, char *buff, bool hide, bool prefix) {
  if (question != NULL) {
    printff("%s", question);
    if (prefix) {
      printff("#>");
    }
  } else {
    if (prefix) {
      printff("\r#>");
    }
  }
#ifdef __unix__
  struct termios term, oterm;

  if (hide) {
    fflush(stdout);
    if (tcgetattr(fileno(stdin), &oterm) == 0) {
      memcpy(&term, &oterm, sizeof(struct termios));
      term.c_lflag &= ~(ECHO | ECHONL);
      tcsetattr(fileno(stdin), TCSAFLUSH, &term);
    } else {
      memset(&term, 0, sizeof(struct termios));
      memset(&oterm, 0, sizeof(struct termios));
    }
  }
#else
  // Look at termio.h on MSDN to implement similar functionality on Windows
  (void)hide;
#endif

  if (fgets(buff, len, stdin) != NULL) {
    buff[strcspn(buff, "\n")] = 0;
  } else {
    printf("EOF received, leaving...\n");
    fflush(stdout);
    leave();
  }

  // Empty stdin
  if (strlen(buff) + 1 == len) {
    int ch;
    while (((ch = getchar()) != EOF) && (ch != '\n'))
      ;
    if (ch == EOF) {
      printf("EOF received, leaving...\n");
      fflush(stdout);
      leave();
    }
  }

#ifdef __unix__
  if (hide) {
    fwrite("\n", 1, 1, stdout);
    tcsetattr(fileno(stdin), TCSAFLUSH, &oterm);
  }
#endif

  return buff;
}

bool yes_or_no(char *question, char yes, char no, bool default_answer,
               bool insensitive) {
  int extra;

  // yes and no characters should be lowercase by default
  yes = (char)tolower(yes);
  no = (char)tolower(no);

  // Which of the two is the default?
  char s, n;
  if (default_answer) {
    s = (char)toupper(yes);
    n = no;
  } else {
    s = yes;
    n = (char)toupper(no);
  }

  while (true) {
    printf("%s [%c/%c]:> ", question, s, n);
    extra = 0;

    char c = (char)getchar();
    char ch = 0;
    if (c != '\n') {
      while (((ch = (char)getchar()) != EOF) && (ch != '\n'))
        extra++;
    }
    if (c == EOF || ch == EOF) {
      printf("EOF received, leaving...\n");
      fflush(stdout);
      leave();
    }
    if (extra > 0)
      continue;

    // Check the answer
    if (c == '\n') {
      return default_answer;
    } else if (c == yes) {
      return true;
    } else if (c == no) {
      return false;
    } else if (c == toupper(yes)) {
      if (default_answer || insensitive)
        return true;
    } else if (c == toupper(no)) {
      if (!default_answer || insensitive)
        return false;
    }
  }
}

char multi_choice(char *question, const char choices[], int num) {
  set_color(STYLE_BOLD);
  char possibilities[2 * num * sizeof(char)];
  int i, j = 0, extra;
  for (i = 0; i < num; i++) {
    possibilities[j++] = choices[i];
    possibilities[j++] = '/';
  }
  possibilities[j - 1] = '\0'; // Remove last '/'

  while (true) {
    if (question != NULL) {
      printf("%s [%s]:> ", question, possibilities);
    } else {
      printf("[%s]:> ", possibilities);
    }

    extra = 0;
    char c = (char)getchar();
    if (c == '\n')
      continue;
    char ch;
    while (((ch = (char)getchar()) != EOF) && (ch != '\n'))
      extra++;
    if (c == EOF || ch == EOF) {
      printf("EOF received, leaving...\n");
      fflush(stdout);
      leave();
    }
    if (extra > 1) // Need exactly one character on stdin
      continue;

    // Check if the choice is valid
    for (i = 0; i < num; i++) {
      if (c == choices[i])
        return c;
    }
  }

  set_color(STYLE_NORMAL);
}

int get_input_number(char *question){
  char input_buffer[TINY_MEM];
  char* end_pointer;
  int input_number;
  while(true){
    if(question != NULL && strlen(question) > 0){
      printff(question);
    }
    scanf("%s[^\n]", input_buffer);
    getchar();
    
    input_number = strtol(input_buffer,&end_pointer,10);

    if(input_buffer != end_pointer && errno != ERANGE && errno != EINVAL){
      break;
    }
    fflush(stdin);
  }

  return input_number;
}

void clear_screen(void) {
  // To whom it may interest: this "magic" is a sequence of escape codes from
  // VT100 terminals: https://www.csie.ntu.edu.tw/~r92094/c++/VT100.html
  printf("\033[2J\033[H");
}

void press_anykey(void) {
  char c;
  puts("\nPress any key to continue...");
  while ((c = (char)getchar()) != '\n');
    (void)c;
}

void printff(const char *format, ...) {
  va_list args;
  va_start(args, format);
  vprintf(format, args);
  fflush(stdout);
  va_end(args);
}

void printffn(const char *format, ...) {
  va_list args;
  va_start(args, format);
  vprintf(format, args);
  printf("\n");
  fflush(stdout);
  va_end(args);
}

void init_choices_array(char **choices_array, int choices_num, int start_num) {
  *choices_array = malloc(sizeof(char) * choices_num);
  if (*choices_array == NULL) {
    print_error_text("Failed to allocate choices array!");
    return;
  }

  for (int i = start_num; i < choices_num; i++) {
    *(*choices_array + i) = i  + '0';
  }
}

time_t last_exit_attempt_time = 0;
int *can_exit_flag; // 1 = Exit Handler can Exit | 0 = Exit Handler can't Exit + Info Message
char* cannot_exit_flag_message;

// char* message -> Message displayed when someone tries to exit
void set_can_exit_flag(int new_flag_status, char* message){
  if(new_flag_status < 0 || new_flag_status > 1){
    print_warning_text("[set_can_exit_flag] Flag changing failed! (SOLUTION: new_flag_status = 0 | 1) ");
    return;
  }
  
  if(can_exit_flag == NULL){
    print_warning_text("[set_can_exit_flag] Flag changing failed! (REASON: can_exit_flag == NULL)");
    return;
  }

  if(message != NULL){
    sprintf(cannot_exit_flag_message,"%s",message);
  }

  *can_exit_flag = new_flag_status;

}

void exit_interrupt_handler(int sigNo) {
  if (*can_exit_flag == 0) {
    if(cannot_exit_flag_message != NULL && strlen(cannot_exit_flag_message)){
      print_info_text(cannot_exit_flag_message);
      return;
    }
    
    print_info_text("Can't quit the game at this moment!");
    return;
  }

  time_t current_time;
  current_time = time(NULL);
  if (current_time - last_exit_attempt_time < 2) {
    logout();
    reset_color();
    printff("\n");
    exit(10);
  } else {
    print_framed_text_left(" [Notice] Press CTRL + C again to quit the game!",
                           '*', true, WHITE_TXT || WHITE_BG, RED_TXT);
  }
  last_exit_attempt_time = current_time;
}

void setup_exit_interrupt_handler() {
  if (can_exit_flag == NULL) {
    can_exit_flag = mmap(NULL, sizeof(can_exit_flag), PROT_WRITE | PROT_READ, MAP_SHARED | MAP_ANONYMOUS , -1, 0);
    cannot_exit_flag_message= mmap(NULL, sizeof(char) * SMALL_MEM, PROT_WRITE | PROT_READ, MAP_SHARED | MAP_ANONYMOUS , -1, 0);

    if (can_exit_flag == NULL) {
      print_error_text("Failed to allocate can_exit_flag!");
      exit(-1);
    }

    *can_exit_flag = 1;

    signal(SIGINT, exit_interrupt_handler);
    return;
  }

  print_warning_text(
      "Exit Interrupt Handler already setup!"); // As only one should be setup,
                                                // on the Parent process only.
}

void cleanup_interrupt_handler(int sigNo) {
    if(sigNo == SIGSEGV){
      print_framed_text_left(" [Error Handler] Exiting game...",
      '*', true, WHITE_TXT || WHITE_BG, RED_TXT); 
      goto cleanup;
    }

    print_framed_text_left(" [Cleanup Handler] Exiting game...",
                           '*', true, WHITE_TXT || WHITE_BG, RED_TXT);
  cleanup:
    logout();
    reset_color();
    exit(-10);
}

int cleanup_handler_setup = 0;

void setup_cleanup_interrupt_handler(void) {
  if (cleanup_handler_setup == 0) {   
    signal(SIGSEGV, cleanup_interrupt_handler);
    signal(SIGTERM, cleanup_interrupt_handler);
    signal(SIGHUP, cleanup_interrupt_handler);
    signal(SIGQUIT, cleanup_interrupt_handler);
    signal(SIGABRT, cleanup_interrupt_handler);
    signal(SIGSTOP, cleanup_interrupt_handler);
    signal(SIGTSTP, cleanup_interrupt_handler);

    cleanup_handler_setup = 1;
    return;
  }

  print_warning_text(
      "Cleanup Interrupt Handler already setup!"); // As only one should be setup,
                                                // on the Parent process only.
}