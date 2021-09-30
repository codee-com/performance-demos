SOURCES = atmux.c lib/Matrix2D.c lib/Vector.c lib/CRSMatrix.c
TARGET = atmux
CFLAGS = -std=c99 -O3 -Ilib -fopenmp

default: run

clean:
	rm -f $(TARGET)

build: clean
	$(CC) $(SOURCES) $(CFLAGS) -o $(TARGET)

run: build
	./$(TARGET) 10000
