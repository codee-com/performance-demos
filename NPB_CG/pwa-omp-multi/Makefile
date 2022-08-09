TARGET := bin
CLASS := B

default: run

clean:
	rm -fr $(TARGET)
	rm -f common/*.o CG/*.o

build: clean
	mkdir -p $(TARGET)
	$(MAKE) -C CG CLASS=$(CLASS)

run: build
	./$(TARGET)/cg.$(CLASS).x
