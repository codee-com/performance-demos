TOPDIR=..

default: native

PROGRAM = predict
SRCFILES = predict.c test_bench.c
HDRFILES = predict.h vms_const.h vms_tb.h

DEPS = $(SRCFILES) $(HDRFILES) Makefile

native: $(PROGRAM)
	./$(PROGRAM) 10 10000

CFLAGS   = -O3 -march=native -g

$(PROGRAM): $(DEPS)
	        $(CC) $(CFLAGS) $(SRCFILES) -o $@ $(LDFLAGS)

.PHONY: clean

clean:
	rm -f *.o $(PROGRAM)

run: native

build: $(PROGRAM)