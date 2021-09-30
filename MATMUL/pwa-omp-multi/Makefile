
SOURCES := matrix.c clock.c main.c
TARGET  := matmul
CFLAGS   := -I include -fopenmp -O3

default: run

clean:
	rm -f *.o $(TARGET)

build: clean
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET)

run: build
	./$(TARGET) 1500
