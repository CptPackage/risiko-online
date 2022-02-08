CC = gcc
OTPS = `mysql_config --cflags --include --libs`

all: 
	$(CC) -Wall -Wextra *.c -o client $(OTPS)

clean:
	rm *.o client
