#pragma once

#define TEXT_LINE_MEM 87
#define TINY_MEM 32
#define SMALL_MEM 128
#define MID_MEM 256
#define BIG_MEM 512
#define LARGE_MEM 1024

void init_allocs();
int init_semaphore(int *sem);
