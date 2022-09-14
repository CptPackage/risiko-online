#include "mem.h"
#include <sys/sem.h>
#include "./io.h"

void init_allocs() {}

int init_semaphore(int sem) {
  sem = semget(IPC_PRIVATE, 1, IPC_CREAT | 0660);
  if (sem == -1) {
    printffn("Error: [init_semaphore] failed to allocate sempahore!");
  }
  return sem;
}


bool free_safe(void* ptr){
  if(ptr != NULL){
    free(ptr);
    return true;
  }
  return false;
}