LD = $(CC)
LIBS = -L$(HOME)/lib -lm
CFLAGS_KERNEL =  -g -O3 -mavx2 -Wall
CFLAGS_MAIN   = -g -O0 -fopenmp -Wall
LDFLAGS       = -O0 -fopenmp


OBJ = main.o Step10_orig.o mysecond.o

all: run

main.o : main.c
	$(CC) $(CFLAGS_MAIN) -c $< -o $@

mysecond.o : mysecond.c
	$(CC) -O0 -c -o mysecond.o mysecond.c

Step10_orig.o : Step10_orig.c
	$(CC) $(CFLAGS_KERNEL) -c $< -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $(INCLUDE) $<

%.o : %.s
	$(FF) $(FFLAGS) -c $(INCLUDE) $<


main: clean $(OBJ)
	$(LD) $(LDFLAGS) -o HACCmk $(OBJ) $(LIBS)

clean:
	rm -f $(OBJ) HACCmk *.lst *.error *.cobaltlog
 
run: main
	./HACCmk


