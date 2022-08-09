#!/bin/bash -e
# This script builds and runs the serial and OpenMP multi-threaded versions of the codes
# gathering runtimes and printing a table with the corresponding speedups.
# Either gcc or clang can be used to build; it can chosen through the CC variable.

# Check that all required commands are available
for cmd in ${CC:-cc} make exec printf make grep cut tr bc; do
    command -v $cmd >/dev/null 2>&1 || { echo >&2 "$cmd is required but it's not installed. Aborting."; exit 1; }
done

# Set locate for decimal point separator and disable stderr output to filter out compiler warnings
LC_NUMERIC=C
exec 2> /dev/null

# Print CPU information if the command is available
if command -v lscpu >/dev/null 2>&1; then
    lscpu
    printf "\n"
fi

# Print compiler information
${CC:-cc} --version
printf "\n"


printf "Cleaning ... \n"
make clean -C ATMUX
make clean -C CANNY
make clean -C COULOMB
make clean -C HACCmk
make clean -C MATMUL
make clean -C NPB_CG
make clean -C PI

printf "Executing 1/7: ATMUX... "
ATMUX_SERIAL=$(make run -C ATMUX/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
ATMUX_OMP_MULTI=$(make run -C ATMUX/pwa-omp-multi | grep "time (s)=" | cut -b 11-)
printf ", multi-threaded done.\n"

printf "Executing 2/7: CANNY... "
CANNY_SERIAL=$(make run -C CANNY/serial | grep "Total time:" | cut -b 13-)
printf "serial done"
CANNY_OMP_MULTI=$(make run -C CANNY/pwa-omp-multi | grep "Total time:" | cut -b 13-)
printf ", multi-threaded done.\n"

printf "Executing 3/7: COULOMB... "
COULOMB_SERIAL=$(make run -C COULOMB/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
COULOMB_OMP_MULTI=$(make run -C COULOMB/pwa-omp-multi | grep "time (s)=" | cut -b 11-)
printf ", multi-threaded done.\n"

printf "Executing 4/7: HACCmk... "
HACC_SERIAL=$(make run -C HACCmk/serial | grep "Kernel elapsed time, s:" | tr -s ' ' | cut -d ' ' -f 5)
printf "serial done"
HACC_OMP_MULTI=$(make run -C HACCmk/pwa-omp-multi | grep "Kernel elapsed time, s:" | tr -s ' ' | cut -d ' ' -f 5)
printf ", multi-threaded done.\n"

printf "Executing 5/7: MATMUL... "
MATMUL_SERIAL=$(make run -C MATMUL/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
MATMUL_OMP_MULTI=$(make run -C MATMUL/pwa-omp-multi | grep "time (s)=" | cut -b 11-)
printf ", multi-threaded done.\n"

printf "Executing 6/7: NPB_CG... "
NPB_CG_SERIAL=$(make run -C NPB_CG/serial | grep "Time in seconds" | tr -s ' ' | cut -d ' ' -f 6)
printf "serial done"
NPB_CG_OMP_MULTI=$(make run -C NPB_CG/pwa-omp-multi | grep "Time in seconds" | tr -s ' ' | cut -d ' ' -f 6)
printf ", multi-threaded done.\n"

printf "Executing 7/7: PI... "
PI_SERIAL=$(make run -C PI/serial | grep "time (s)=" | cut -b 11-)
printf "serial done"
PI_OMP_MULTI=$(make run -C PI/pwa-omp-multi | grep "time (s)=" | cut -b 11-)
printf ", multi-threaded done.\n"


printf "Cleaning ... \n"
make clean -C ATMUX
make clean -C CANNY
make clean -C COULOMB
make clean -C HACCmk
make clean -C MATMUL
make clean -C NPB_CG
make clean -C PI

printf "\nCode           \tSerial \tMulti  \tSpeedup\tTime reduced\n"
printf "===============\t=======\t=======\t=======\t============\n"

printRow() { # Params: Code, Serial, Multi
    local SPEEDUP=$(bc -l <<< "$2/$3")
    local REDUCTION=$(bc -l <<< "($2-$3)/$2*100")
    local EXTRA_TAB="" && (( ${#1} < 8 )) && EXTRA_TAB="\t"
    printf "%s\t$EXTRA_TAB%.2f\t%.2f\t%.2fx\t%.2f%%\n" $1 $2 $3 $SPEEDUP $REDUCTION
}

printRow "ATMUX" $ATMUX_SERIAL $ATMUX_OMP_MULTI
printRow "CANNY" $CANNY_SERIAL $CANNY_OMP_MULTI
printRow "COULOMB" $COULOMB_SERIAL $COULOMB_OMP_MULTI
printRow "HACCmk" $HACC_SERIAL $HACC_OMP_MULTI
printRow "MATMUL" $MATMUL_SERIAL $MATMUL_OMP_MULTI
printRow "NPB_CG" $NPB_CG_SERIAL $NPB_CG_OMP_MULTI
printRow "PI" $PI_SERIAL $PI_OMP_MULTI
