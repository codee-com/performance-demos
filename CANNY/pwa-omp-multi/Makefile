SOURCES = canny.c
TARGET = canny
CFLAGS = -fopenmp -O3 -lm

default: run

clean:
	rm -fr $(TARGET) testvecs

build: clean
	$(CC) $(SOURCES) $(CFLAGS) -o $(TARGET)

run: build
	unzip ../15360_8640.zip
	./$(TARGET) testvecs/input/15360_8640.pgm 0.5 0.7 0.9
