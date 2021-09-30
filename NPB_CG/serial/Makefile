TARGET := bin
CLASS := B

default: run

clean:
	rm -fr $(TARGET)

build: clean
	mkdir -p $(TARGET)
	$(MAKE) -C CG CLASS=$(CLASS)

run: build
	./$(TARGET)/cg.$(CLASS).x
