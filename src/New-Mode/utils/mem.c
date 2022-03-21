#include "mem.h"
#include <semaphore.h>

void init_allocs() {}

int init_semaphore(int *sem) {
  // *sem = semget(IPC_PRIVATE, 1, IPC_CREAT | 0660);
  // if (*sem == -1) {
  //   printffn("Error: [init_semaphore] failed to allocate sempahore!");
  // }
  // return *sem;
  return *sem;
}
