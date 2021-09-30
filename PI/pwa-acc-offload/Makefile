SOURCES = pi.c
TARGET = pi
CFLAGS = -acc -O3 -lm
CC = nvc

default: run

clean:
	rm -f $(TARGET)

build: clean
	$(CC) $(SOURCES) $(CFLAGS) -o $(TARGET)

run: build
	./$(TARGET) 1000000000
