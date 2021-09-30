
SOURCES := matrix.c clock.c main.c
TARGET  := matmul
CFLAGS   := -acc -I include -O3
CC := nvc

default: run

clean:
	rm -f *.o $(TARGET)

build: clean
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET)

run: build
	./$(TARGET) 1500
