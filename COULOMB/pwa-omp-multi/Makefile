SOURCES = Vector.c Matrix2D.c coulomb.c
TARGET = coulomb
CFLAGS = -fopenmp -O3 -lm

default: run

clean:
	rm -f $(TARGET)

build: clean
	$(CC) $(SOURCES) $(CFLAGS) -o $(TARGET)

run: build
	./$(TARGET) 400
